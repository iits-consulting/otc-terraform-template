module "vpc" {
  source             = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/vpc"
  version            = "7.1.0"
  name               = "${var.context}-${var.stage}-vpc"
  cidr_block         = var.vpc_cidr
  tags               = local.tags
}

module "snat" {
  source      = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/snat"
  version     = "7.1.0"
  name_prefix = "${var.context}-${var.stage}"
  subnet_id   = module.vpc.subnets["kubernetes-subnet"].id
  vpc_id      = module.vpc.vpc.id
  tags        = local.tags
}

module "cce" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/cce"
  version = "7.1.0"

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
  version      = "7.1.0"
  context_name = var.context
  subnet_id    = module.vpc.subnets["kubernetes-subnet"].subnet_id
  stage_name   = var.stage
  bandwidth    = 500
}

module "private_dns" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/private_dns"
  version = "7.1.0"

  domain = "vpc.private"
  a_records = {
    kubernetes = [split(":", trimprefix(module.cce.cluster_private_ip, "https://"))[0]]
  }
  vpc_id = module.vpc.vpc.id
}

module "public_dns" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/public_dns"
  version = "7.1.0"

  domain = var.domain_name
  email  = var.email
  a_records = {
    (var.domain_name) = [module.loadbalancer.elb_public_ip]
    admin             = [module.loadbalancer.elb_public_ip]
  }
}