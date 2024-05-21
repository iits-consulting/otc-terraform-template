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

variable "dockerhub_username" {
  type        = string
  description = "Username of Docker Registry Credentials for ArgoCD"
  sensitive   = true
}

variable "dockerhub_password" {
  type        = string
  description = "Password of Docker Registry Credentials for ArgoCD"
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

variable "cert_manager_access_key" {
  type = string
  validation {
    condition     = var.cert_manager_access_key != ""
    error_message = "cert_manager_access_key is mandatory"
  }
}

variable "cert_manager_secret_key" {
  type = string
  validation {
    condition     = var.cert_manager_secret_key != ""
    error_message = "cert_manager_secret_key is mandatory"
  }
}

locals {
  chart_versions = {
    cce_storage_classes   = "2.0.2"
    kyverno               = "2.0.1"
    traefik               = "28.1.0"
    cert-manager          = "1.14.4"
    ollama                = "0.8.2"
  }
}