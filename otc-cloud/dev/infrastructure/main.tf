module "vpc" {
  source             = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/vpc"
  version            = "6.0.2"
  name               = "${var.context}-${var.stage}-vpc"
  cidr_block         = var.vpc_cidr
  enable_shared_snat = false
  tags               = local.tags
}

module "snat" {
  source      = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/snat"
  version     = "6.0.2"
  name_prefix = "${var.context}-${var.stage}"
  subnet_id   = module.vpc.subnets["kubernetes-subnet"].id
  vpc_id      = module.vpc.vpc.id
  tags        = local.tags
}

module "cce" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/cce"
  version = "6.0.2"

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

resource "null_resource" "get_kube_config" {
  depends_on = [module.cce]
  provisioner "local-exec" {
    command = "../stage-dependent-env.sh"
  }
}

module "cce_gpu_node_pool" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/cce_gpu_node_pool"
  version = "6.0.2"

  name_prefix             = module.cce.cluster_name
  cce_cluster_id          = module.cce.cluster_id
  node_availability_zones = [var.availability_zones[0]]
  node_os                 = var.gpu_node_config.node_os
  node_flavor             = var.gpu_node_config.node_flavor
  node_storage_type       = var.gpu_node_config.node_storage_type
  node_storage_size       = var.gpu_node_config.node_storage_size
  node_scaling_enabled    = var.gpu_node_config.enable_scaling
  node_count              = var.gpu_node_config.node_count
  autoscaler_node_max     = var.gpu_node_config.nodes_max
  gpu_driver_url          = var.gpu_node_config.gpu_driver_url

  tags = local.tags
}

module "loadbalancer" {
  source       = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/loadbalancer"
  version      = "6.0.2"
  context_name = var.context
  subnet_id    = module.vpc.subnets["kubernetes-subnet"].subnet_id
  stage_name   = var.stage
  bandwidth    = 500
}

module "private_dns" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/private_dns"
  version = "6.0.2"
  domain  = "vpc.private"
  a_records = {
    kubernetes = [split(":", trimprefix(module.cce.cluster_private_ip, "https://"))[0]]
  }
  vpc_id = module.vpc.vpc.id
}

module "public_dns" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/public_dns"
  version = "6.0.2"
  domain  = var.domain_name
  email   = var.email
  a_records = {
    (var.domain_name) = [module.loadbalancer.elb_public_ip]
    ollama            = [module.loadbalancer.elb_public_ip]
    llm               = [module.loadbalancer.elb_public_ip]
  }
}