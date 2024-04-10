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

variable "git_token" {
  type        = string
  description = "Git Access Token for ArgoCD"
  sensitive   = true
}

variable "argocd_bootstrap_project_url" {
  type        = string
  description = "Link to the git project which is a fork of this project here: https://github.com/iits-consulting/terraform-opentelekomcloud-project-factory"
  validation {
    condition     = !can(regex("iits-consulting", var.argocd_bootstrap_project_url))
    error_message = "TF_VAR_argocd_bootstrap_project_url is set wrong. Please use your fork and not the iits-consulting repo!"
  }
  validation {
    condition     = can(regex("https://", var.argocd_bootstrap_project_url))
    error_message = "TF_VAR_argocd_bootstrap_project_url is set wrong. Please use the https link from you fork!"
  }
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

locals {
  chart_versions = {
    otc_storage_classes   = "2.0.2"
    crds                  = "1.7.0"
    argo                  = "15.0.1"
    kyverno               = "1.5.2"
    iits_kyverno_policies = "1.6.0"
    traefik               = "21.3.1"
    cert-manager          = "1.0.1"
  }
}