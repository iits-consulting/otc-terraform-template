data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket                      = "${var.context}-${var.stage}-tfstate"
    key                         = "tfstate-infrastructure"
    region                      = var.region
    endpoint                    = "obs.${var.region}.otc.t-systems.com"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  chart_versions = {
    otc_storage_classes   = "2.0.2"
    crds                  = "1.6.3"
    argo                  = "15.0.1"
    kyverno               = "1.3.2"
    iits_kyverno_policies = "1.5.1"
    traefik               = "21.2.1"
    cert-manager          = "1.0.0"
    ollama                = "0.6.14"
    iits_llm_fullstack    = "0.2.6"
  }
}

variable "region" {
  type        = string
  description = "OTC region for the project: eu-de(default) or eu-nl"
  default     = "eu-de"
  validation {
    condition     = contains(["eu-de", "eu-nl"], var.region)
    error_message = "Currently only this regions are supported: \"eu-de\", \"eu-nl\"."
  }
}

variable "context" {
  type        = string
  description = "Project context for resource naming and tagging."
}

variable "stage" {
  type        = string
  description = "Project stage for resource naming and tagging."
}

variable "git_registry_username" {
  type        = string
  description = "Username of Container Registry Credentials"
  sensitive   = true
}

variable "git_registry_password" {
  type        = string
  description = "Password of Container Registry Credentials"
  sensitive   = true
}

variable "domain_name" {
  type        = string
  description = "The public domain to create public DNS zone for."
}

variable "email" {
  description = "E-mail contact address for DNS zone."
  type        = string
}

variable "ak_sk_security_token" {
  type        = string
  description = "Security Token for temporary AK/SK"
}