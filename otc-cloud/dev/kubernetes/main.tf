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
    name   = "argocd"
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
  depends_on                        = [module.crds]
}

resource "helm_release" "argocd" {
  name                  = "argocd"
  repository            = "https://victorgetz.github.io/common-infrastructure-charts"
  chart                 = "argocd"
  version               = "5.22.1-default-values"
  namespace             = "argocd"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  values                = [
    yamlencode({
      global = {
        terraformValues = {
          stage        = var.stage
          traefikElbId = module.terraform_secrets_from_encrypted_s3_bucket.secrets["elb_id"]
          dnsHost      = "admin.${var.domain_name}"
        }
      }
      projects = {
        infrastructure = {
          repoUrl         = var.argocd_bootstrap_project_url
          allowedUrls     = ["https://victorgetz.github.io/common-infrastructure-charts"]
        }
        gitToken = {
          password = var.git_token
        }
        repoPrivateKeyBase64Encoded = ""
      }
    }
    )
  ]
}
