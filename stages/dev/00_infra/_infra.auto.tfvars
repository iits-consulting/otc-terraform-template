availability_zones = [
  "eu-de-03",
]

vpc_cidr = "10.8.0.0/20"

cluster_config = {
  cluster_version        = "v1.33"
  high_availability      = false
  container_network_type = "overlay_l2"
  container_cidr         = "172.16.0.0/16"
  service_cidr           = "172.17.0.0/16"
  cluster_public_access  = true
}

node_pool_config = {
  node_pool_os             = "HCE OS 2.0"
  node_pool_flavor         = "c9.xlarge.4"
  node_pool_enable_scaling = true
  node_pool_node_count     = 3
  node_pool_node_count_max = 3
  node_pool_storage_type   = "SSD"
  node_pool_storage_size   = 100
}
