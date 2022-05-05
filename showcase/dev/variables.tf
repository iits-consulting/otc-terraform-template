variable "region" {
  type        = string
  description = "OTC region for the project: eu-de(default) or eu-nl"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for the OTC resources."
}

variable "vpc_cidr" {
  type        = string
  description = "IP range of the VPC"
}

variable "cluster_config" {
  description = "Cluster node configuration parameters"
  type = object({
    enable_scaling    = bool   // Enable autoscaling of the cluster
    high_availability = bool   // Create the cluster in highly available mode
    node_flavor       = string // Node specifications in otc flavor format
    node_storage_type = string // Type of node storage SATA, SAS or SSD
    node_storage_size = number // Size of the node system disk in GB
    nodes_count       = number // Number of nodes to create
    nodes_max         = number // Maximum limit of servers to create
  })
}

variable "context" {
  type        = string
  description = "Project context for resource naming and tagging."
}

variable "stage" {
  type        = string
  description = "Project stage for resource naming and tagging."
}
locals {
  prefix = replace(join("-", [lower(var.context), lower(var.stage)]), "_", "-")
  tags = {
    Stage   = var.stage
    Context = var.context
  }
}