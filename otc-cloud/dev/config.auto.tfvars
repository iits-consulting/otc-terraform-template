availability_zones = [
  "eu-de-03",
]

vpc_cidr = "10.8.0.0/20"

cluster_config = {
  enable_scaling         = true
  high_availability      = false
  container_network_type = "overlay_l2"
  service_cidr           = "172.17.0.0/16"
  node_flavor            = "s3.xlarge.4"
  node_storage_type      = "SSD"
  node_storage_size      = 100
  nodes_count            = 2
  nodes_max              = 8
  container_cidr         = "172.16.0.0/16"
  service_cidr           = "172.17.0.0/16"
}