variable "region" {
  type        = string
  description = "OTC region for the project: eu-de(default) or eu-nl"
  default     = "eu-de"
}

variable "context" {
  type        = string
  description = "Project context for resource naming and tagging."
}

variable "stage" {
  type        = string
  description = "Project stage for resource naming and tagging."
}

variable "ak_sk_security_token" {
  type        = string
  description = "Security Token for temporary AK/SK"
}

locals {
  tf_state_bucket_name = "${var.context}-${var.stage}-tfstate"
  terraform_paths = [
    "infrastructure",
    "kubernetes",
  ]
}