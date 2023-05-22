data "opentelekomcloud_identity_project_v3" "current" {}

module "terraform_secrets_from_encrypted_s3_bucket" {
  source            = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/obs_secrets_reader"
  version           = "5.1.0"
  bucket_name       = replace(lower("${data.opentelekomcloud_identity_project_v3.current.name}-${var.context}-${var.stage}-stage-secrets"), "_", "-")
  bucket_object_key = "terraform-secrets"
  required_secrets  = [
    "elb_id",
    "elb_public_ip",
    "kubectl_config",
    "kubernetes_ca_cert",
    "client_certificate_data",
    "kube_api_endpoint",
    "client_key_data",
    "cce_id",
    "cce_name",
    "storage_class_kms_key_id"
  ]
}

locals {
  charts = {
    registry_creds_version        = "1.1.3-bugfix-user"
    crds_version                  = "1.5.0"
    argo_version                  = "5.30.1-fix-proj-generation"
    kyverno_version               = "1.0.1"
    iits_kyverno_policies_version = "1.3.0"
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
}

variable "domain_name" {
  type        = string
  description = "The public domain to create public DNS zone for."
}

variable "email" {
  description = "E-mail contact address for DNS zone."
  type        = string
}

variable "os_domain_name" {
  type        = string
  description = "Current Cloud you are working on for example: OTC-EU-DE-000000000010...."
}