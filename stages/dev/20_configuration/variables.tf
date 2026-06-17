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

variable "email" {
  description = "E-mail contact address for cert-manager issuer."
  type        = string
}

variable "domain_name" {
  type        = string
  description = "The public domain name for routing and certificate configuration."
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

variable "argocd_repo_url" {
  type        = string
  description = "URL to the git project where the ArgoCD infrastructure Apps are stored"
}

variable "otc_user_id" {
  type        = string
  description = "User ID for the IAM user. Used to create a temp AK/SK for cert-manager"
}

variable "admin_website_password" {
  type        = string
  description = "Password for the admin website"
}

variable "ak_sk_security_token" {
  type        = string
  description = "Security Token for temporary AK/SK"
}
variable "chart_versions" {
  type = object({
    traefik             = string
    cert-manager        = string
    prometheus-stack    = string
    cce_storage_classes = string
    argocd              = string
    argocd_apps         = string
    kyverno             = string
  })
  description = "Versions of the charts bootstrapped by Tofu."
}
