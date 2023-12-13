module "tf_state_bucket" {
  source = "../../modules/state_bucket"
  tf_state_bucket_name = "${var.context}-${var.stage}-tfstate"
  providers = {
    opentelekomcloud = opentelekomcloud.top_level_project
  }
}

output "terraform_state_backend_configs" {
  value = module.tf_state_bucket.terraform_state_backend_config
}

module "vpc" {
  source             = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/vpc"
  version            = "5.7.1"
  name               = "${var.context}-${var.stage}-vpc"
  cidr_block         = var.vpc_cidr
  enable_shared_snat = false
  tags = local.tags
}

module "snat" {
  source      = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/snat"
  version     = "5.7.1"
  name_prefix = "${var.context}-${var.stage}"
  subnet_id   = module.vpc.subnets["kubernetes-subnet"].id
  vpc_id      = module.vpc.vpc.id
  tags        = local.tags
}

module "cce" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/cce"
  version     = "5.7.1"

  name                           = "${var.context}-${var.stage}"
  cluster_vpc_id                 = module.vpc.vpc.id
  cluster_subnet_id              = module.vpc.subnets["kubernetes-subnet"].id
  cluster_high_availability      = var.cluster_config.high_availability
  cluster_enable_scaling         = var.cluster_config.enable_scaling
  cluster_container_network_type = var.cluster_config.container_network_type
  cluster_container_cidr         = var.cluster_config.container_cidr
  cluster_service_cidr           = var.cluster_config.service_cidr
  cluster_public_access          = true

  node_availability_zones         = var.availability_zones
  node_count                      = var.cluster_config.nodes_count
  node_flavor                     = var.cluster_config.node_flavor
  node_storage_type               = var.cluster_config.node_storage_type
  node_storage_size               = var.cluster_config.node_storage_size
  node_storage_encryption_enabled = true

  autoscaler_node_min = var.cluster_config.nodes_count
  autoscaler_node_max = var.cluster_config.nodes_max

  tags = local.tags
}

module "loadbalancer" {
  source       = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/loadbalancer"
  version     = "5.7.1"
  context_name = var.context
  subnet_id    = module.vpc.subnets["kubernetes-subnet"].subnet_id
  stage_name   = var.stage
  bandwidth    = 500
}

module "private_dns" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/private_dns"
  version     = "5.7.1"
  domain  = "vpc.private"
  a_records = {
    kubernetes = [split(":", trimprefix(module.cce.cluster_private_ip, "https://"))[0]]
  }
  vpc_id = module.vpc.vpc.id
}

module "public_dns" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/public_dns"
  version     = "5.7.1"
  domain  = var.domain_name
  email   = var.email
  a_records = {
    (var.domain_name) = [module.loadbalancer.elb_public_ip]
    admin             = [module.loadbalancer.elb_public_ip]
  }
}

module "encyrpted_secrets_bucket" {
  providers         = { opentelekomcloud = opentelekomcloud.top_level_project }
  source            = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/obs_secrets_writer"
  version           = "5.7.1"
  bucket_name       = replace(lower("${var.region}-${var.context}-${var.stage}-stage-secrets"), "_", "-")
  bucket_object_key = "terraform-secrets"
  secrets = {
    elb_id                  = module.loadbalancer.elb_id
    elb_public_ip           = module.loadbalancer.elb_public_ip
    kubectl_config          = module.cce.kubeconfig
    kubernetes_ca_cert      = module.cce.cluster_credentials.cluster_certificate_authority_data
    client_certificate_data = module.cce.cluster_credentials.client_certificate_data
    kube_api_endpoint       = module.cce.cluster_credentials.kubectl_external_server
    client_key_data         = module.cce.cluster_credentials.client_key_data
    cce_id                  = module.cce.cluster_id
    cce_name                = module.cce.cluster_name
  }
  tags = local.tags
}

resource "null_resource" "get_kube_config" {
  depends_on = [module.cce]
  provisioner "local-exec" {
    command = "./stage-dependent-env.sh"
  }
}