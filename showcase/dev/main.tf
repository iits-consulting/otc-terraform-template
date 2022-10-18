data "opentelekomcloud_identity_project_v3" "current" {}

module "vpc" {
  source     = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/vpc"
  version    = "4.2.2"
  name       = "${var.context}-${var.stage}-vpc"
  cidr_block = var.vpc_cidr
  subnets = {
    "kubernetes-subnet" = cidrsubnet(var.vpc_cidr, 1, 0)
  }
  tags = local.tags
}

module "snat" {
  // This module is necessary for internet access if the VPC is not in eu-de region.
  count         = var.region == "eu-de" ? 0 : 1
  source        = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/snat"
  version       = "4.2.2"
  name_prefix   = "${var.context}-${var.stage}"
  subnet_id   = module.vpc.subnets["kubernetes-subnet"].id
  vpc_id        = module.vpc.vpc.id
  tags          = local.tags
}

module "cce" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/cce"
  version = "4.2.2"
  name    = "${var.context}-${var.stage}"

  cluster_config = {
    vpc_id            = module.vpc.vpc.id
    subnet_id         = module.vpc.subnets["kubernetes-subnet"].id
    cluster_version   = "v1.21"
    high_availability = var.cluster_config.high_availability
    enable_scaling    = var.cluster_config.enable_scaling
  }
  node_config = {
    availability_zones = [
      "${var.region}-03",
      "${var.region}-01"
    ]
    node_count        = var.cluster_config.nodes_count
    node_flavor       = var.cluster_config.node_flavor
    node_storage_type = var.cluster_config.node_storage_type
    node_storage_size = var.cluster_config.node_storage_size
  }
  autoscaling_config = {
    nodes_max = var.cluster_config.nodes_max
  }
  tags = local.tags
}

module "loadbalancer" {
  source       = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/loadbalancer"
  version      = "4.2.2"
  context_name = var.context
  subnet_id    = module.vpc.subnets["kubernetes-subnet"].subnet_id
  stage_name   = var.stage
  bandwidth    = 500
}

module "private_dns" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/private_dns"
  version = "4.2.2"
  domain  = "internal.${var.context}.de"
  a_records = {
    elb_private_ip = [module.loadbalancer.elb_private_ip]
  }
  vpc_id = module.vpc.vpc.id
}


/*
Requires this two ns records in your domain provider config (config depends on domain provider)

ns1.open-telekom-cloud.com
ns2.open-telekom-cloud.com

*/
module "public_dns" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/public_dns"
  version = "4.2.2"
  domain  = var.domain_name
  email   = var.email
  a_records = {
    admin = [module.loadbalancer.elb_public_ip]
  }
}


module "encyrpted_secrets_bucket" {
  providers         = { opentelekomcloud = opentelekomcloud.top_level_project }
  source            = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/obs_secrets_writer"
  version           = "4.2.2"
  bucket_name       = replace(lower("${data.opentelekomcloud_identity_project_v3.current.name}-${var.context}-${var.stage}-stage-secrets"), "_", "-")
  bucket_object_key = "terraform-secrets"
  secrets = {
    elb_id                  = module.loadbalancer.elb_id
    elb_public_ip           = module.loadbalancer.elb_public_ip
    kubectl_config          = module.cce.cluster_credentials.kubectl_config
    kubernetes_ca_cert      = module.cce.cluster_credentials.cluster_certificate_authority_data
    client_certificate_data = module.cce.cluster_credentials.client_certificate_data
    kube_api_endpoint       = module.cce.cluster_credentials.kubectl_external_server
    client_key_data         = module.cce.cluster_credentials.client_key_data
    cce_id                  = module.cce.cluster_id
    cce_name                = module.cce.cluster_name
  }
  tags = local.tags
}