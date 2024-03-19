availability_zones = [
  "eu-de-03",
]

vpc_cidr = "10.8.0.0/20"

cluster_config = {
  enable_scaling         = false
  high_availability      = false
  container_network_type = "overlay_l2"
  node_flavor            = "s3.xlarge.8"
  node_storage_type      = "SSD"
  node_storage_size      = 100
  nodes_count            = 3
  nodes_max              = 3
  container_cidr         = "172.16.0.0/16"
  service_cidr           = "172.17.0.0/16"
}
