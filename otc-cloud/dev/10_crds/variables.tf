variable "region" {
  type        = string
  description = "OTC region for the project: eu-de(default) or eu-nl"
  default     = "eu-de"
}

variable "stage" {
  type        = string
  description = "Project stage for resource naming and tagging."
}

variable "context" {
  type        = string
  description = "Project context for resource naming and tagging."
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "${var.context}-${var.stage}-tfstate"
    key    = "tfstate-infrastructure"
    region = var.region
    endpoints = {
      s3 = "https://obs.${var.region}.otc.t-systems.com"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
