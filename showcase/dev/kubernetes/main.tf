data "opentelekomcloud_identity_project_v3" "current" {}

module "terraform_secrets_from_encrypted_s3_bucket" {
  source            = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/obs_secrets_reader"
  version           = "5.1.0"
  bucket_name       = replace(lower("${data.opentelekomcloud_identity_project_v3.current.name}-${var.context}-${var.stage}-stage-secrets"), "_", "-")
  bucket_object_key = "terraform-secrets"
  required_secrets = [
    "elb_id",
    "elb_public_ip",
    "kubectl_config",
    "kubernetes_ca_cert",
    "client_certificate_data",
    "kube_api_endpoint",
    "client_key_data",
    "cce_id",
    "cce_name",
  ]
}

locals {
  dockerhubconfigjsonbase64 = base64encode(jsonencode({
    auths = {
      "https://index.docker.io/v1/" = {
        username = var.dockerhub_username
        password = var.dockerhub_password
        auth     = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
      }
    }
  }))
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      optimized-by-cce = true
    }
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }
}

module "crds" {
  source  = "iits-consulting/crds/helm"
  version = "0.0.2"
}

module "credentials" {
  source                            = "iits-consulting/registry-credentials/helm"
  version                           = "0.0.2"
  registry_credentials_dockerconfig = local.dockerhubconfigjsonbase64
  depends_on = [module.crds]
}

module "argocd" {
  source  = "registry.terraform.io/iits-consulting/bootstrap/argocd"
  version = "5.6.1"

  custom_resource_definitions_enabled = false
  registry_credentials_enabled        = false

  ### ArgoCD Configuration
  argocd_namespace                 = "argocd"
  argocd_project_name              = "infrastructure-charts"
  argocd_git_access_token_username = "argocd"
  argocd_git_access_token          = var.git_token
  argocd_project_source_repo_url   = "https://github.com/iits-consulting/cloudastro-infrastructure-charts.git"
  argocd_project_source_path       = "stages/${var.stage}"
  argocd_application_values = {
    global = {
      stage = var.stage
      helmValues = [
        {
          name  = "dns.host"
          value = "admin.${var.domain_name}"
        }
      ]
    }
    traefik = {
      terraformValues = [
        {
          name  = "traefik.service.annotations.kubernetes\\.io\\/elb\\.id"
          value = module.terraform_secrets_from_encrypted_s3_bucket.secrets["elb_id"]
        }
      ]
    }
  }
  depends_on = [module.credentials]
}