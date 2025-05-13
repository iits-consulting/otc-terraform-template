module "vpc" {
  source     = "iits-consulting/vpc/opentelekomcloud"
  version    = "7.4.1"
  name       = "${var.context}-${var.stage}-vpc"
  cidr_block = var.vpc_cidr
  tags       = local.tags
}

module "snat" {
  source        = "iits-consulting/snat/opentelekomcloud"
  version       = "7.4.1"
  name_prefix   = "${var.context}-${var.stage}"
  subnet_id     = module.vpc.subnets["kubernetes-subnet"].id
  vpc_id        = module.vpc.vpc.id
  network_cidrs = [var.vpc_cidr]
}

module "cce" {
  source  = "iits-consulting/cce/opentelekomcloud"
  version = "7.4.4"

  name                             = "${var.context}-${var.stage}"
  cluster_vpc_id                   = module.vpc.vpc.id
  cluster_subnet_id                = module.vpc.subnets["kubernetes-subnet"].id
  cluster_version                  = "v1.30"
  cluster_high_availability        = var.cluster_config.high_availability
  cluster_enable_scaling           = var.cluster_config.enable_scaling
  cluster_container_network_type   = var.cluster_config.container_network_type
  cluster_container_cidr           = var.cluster_config.container_cidr
  cluster_service_cidr             = var.cluster_config.service_cidr
  cluster_public_access            = true
  cluster_enable_volume_encryption = false

  node_availability_zones         = var.availability_zones
  node_count                      = var.cluster_config.nodes_count
  node_os                         = var.cluster_config.node_os
  node_flavor                     = var.cluster_config.node_flavor
  node_storage_type               = var.cluster_config.node_storage_type
  node_storage_size               = var.cluster_config.node_storage_size
  node_container_runtime          = "containerd"
  node_storage_encryption_enabled = true

  autoscaler_node_min = var.cluster_config.nodes_count
  autoscaler_node_max = var.cluster_config.nodes_max

  tags = local.tags
}

module "loadbalancer" {
  source       = "iits-consulting/loadbalancer/opentelekomcloud"
  version      = "7.4.1"
  context_name = var.context
  subnet_id    = module.vpc.subnets["kubernetes-subnet"].subnet_id
  stage_name   = var.stage
  bandwidth    = 500
}

module "public_dns" {
  source  = "iits-consulting/public-dns/opentelekomcloud"
  version = "7.4.1"

  domain = var.domain_name
  email  = var.email
  a_records = {
    (var.domain_name) = [module.loadbalancer.elb_public_ip]
    admin             = [module.loadbalancer.elb_public_ip]
  }
}

module "private_dns_vpc" {
  source  = "iits-consulting/private-dns/opentelekomcloud"
  version = "7.4.1"

  domain = "vpc.private"
  a_records = {
    kubernetes = [split(":", trimprefix(module.cce.cluster_private_ip, "https://"))[0]]
  }
  vpc_id = module.vpc.vpc.id
}