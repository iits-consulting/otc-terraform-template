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

variable "git_token" {
  type        = string
  description = "Git Access Token for ArgoCD"
  sensitive   = true
}

variable "argocd_bootstrap_project_url" {
  type        = string
  description = "Link to the git project where the ArgoCD infrastructure Apps are stored"
  default     = "https://github.com/iits-consulting/otc-infrastructure-charts-template.git"
}

variable "argocd_bootstrap_project_branch" {
  type        = string
  description = "Your branch which you are working on"
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

variable "otc_user_id" {
  type        = string
  description = "Id of the username we need it to create a temp AK/SK for cert-manager"
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
