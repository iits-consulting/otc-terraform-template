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
    cluster_version        = string // CCE version for the cluster
    high_availability      = bool   // Create the cluster in highly available mode
    container_network_type = string // Container network type: vpc-router or overlay_l2
    container_cidr         = string // Kubernetes pod network CIDR range
    service_cidr           = string // Kubernetes service network CIDR range
    cluster_public_access  = bool   // Assign public EIP for the cluster for direct access over the internet
  })
}

variable "node_pool_config" {
  description = "CCE cluster and node pool configuration parameters"
  type = object({
    node_pool_os             = string // Node pool operating system
    node_pool_flavor         = string // Node specifications in otc flavor format
    node_pool_enable_scaling = bool   // Enable autoscaling of the cluster
    node_pool_node_count     = number // Number of nodes to create
    node_pool_node_count_max = number // Maximum number of nodes for scale-out
    node_pool_storage_type   = string // Type of node storage SATA, SAS or SSD
    node_pool_storage_size   = string // Size of the node system disk in GB
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
