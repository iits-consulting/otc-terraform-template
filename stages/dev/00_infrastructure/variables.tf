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
  description = "CCE cluster and node pool configuration parameters"
  type = object({
    enable_scaling         = bool   // Enable autoscaling of the cluster
    high_availability      = bool   // Create the cluster in highly available mode
    container_network_type = string // Container network type: vpc-router or overlay_l2
    node_os                = string // Node operating system
    node_flavor            = string // Node specifications in otc flavor format
    node_storage_type      = string // Type of node storage SATA, SAS or SSD
    node_storage_size      = number // Size of the node system disk in GB
    nodes_count            = number // Number of nodes to create
    nodes_max              = number // Maximum limit of servers to create
    container_cidr         = string // Kubernetes pod network CIDR range
    service_cidr           = string // Kubernetes service network CIDR range
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

variable "domain_name" {
  type        = string
  description = "The public domain to create public DNS zone for."
}

variable "email" {
  description = "E mail contact address for DNS zone."
  type        = string
}

variable "ak_sk_security_token" {
  type        = string
  description = "Security Token for temporary AK/SK"
}

locals {
  tags = {
    Stage   = var.stage
    Context = var.context
  }
}

