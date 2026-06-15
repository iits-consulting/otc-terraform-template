module "cce_cluster" {
  source  = "iits-consulting/cce-cluster/opentelekomcloud"
  version = "1.0.0"

  cluster_name                   = "${var.context}-${var.stage}"
  cluster_version                = var.cluster_config.cluster_version
  cluster_vpc_id                 = module.vpc.vpc.id
  cluster_subnet_id              = module.vpc.subnets["kubernetes-subnet"].id
  cluster_high_availability      = var.cluster_config.high_availability
  cluster_container_network_type = var.cluster_config.container_network_type
  cluster_container_cidr         = var.cluster_config.container_cidr
  cluster_service_cidr           = var.cluster_config.service_cidr
  cluster_public_access          = var.cluster_config.cluster_public_access
}

module "cce_node_pool" {
  source   = "iits-consulting/cce-node-pool/opentelekomcloud"
  version  = "1.0.0"
  for_each = toset(var.availability_zones)

  cluster_id                  = module.cce_cluster.cluster_id
  node_pool_availability_zone = each.key
  node_pool_os                = var.node_pool_config.node_pool_os
  node_pool_flavor            = var.node_pool_config.node_pool_flavor
  node_pool_enable_scaling    = var.node_pool_config.node_pool_enable_scaling
  node_pool_node_count        = var.node_pool_config.node_pool_node_count
  node_pool_node_count_max    = var.node_pool_config.node_pool_node_count_max
  node_pool_storage_type      = var.node_pool_config.node_pool_storage_type
  node_pool_storage_size      = var.node_pool_config.node_pool_storage_size
}

resource "null_resource" "get_kube_config" {
  triggers = {
    trigger = timestamp()
  }
  depends_on = [module.cce_cluster]
  provisioner "local-exec" {
    command = "otc-auth cce get-kube-config"
  }
}

output "kubernetes" {
  sensitive   = true
  description = "CCE Cluster related parameters to be passed down on subsequent substages."
  value = {
    cce_name              = module.cce_cluster.cluster_name
    cce_id                = module.cce_cluster.cluster_id
    api_endpoint          = module.cce_cluster.cluster_public_ip
    api_private_endpoint  = module.cce_cluster.cluster_private_ip
    certificate_authority = module.cce_cluster.cluster_credentials.cluster_certificate_authority_data
    client_certificate    = module.cce_cluster.cluster_credentials.client_certificate_data
    client_key            = module.cce_cluster.cluster_credentials.client_key_data
  }
}
