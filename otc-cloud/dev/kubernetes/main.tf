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
    registry_creds_version = "1.1.3-bugfix-user"
    crds_version           = "1.5.0"
    argo_version           = "5.30.1-fix-proj-generation"
  }
}

resource "helm_release" "custom_resource_definitions" {
  name                  = "crds"
  repository            = "https://charts.iits.tech"
  chart                 = "crds"
  version               = local.charts.crds_version
  namespace             = "crds"
  create_namespace      = true
  render_subchart_notes = true
  dependency_update     = true
}

resource "helm_release" "registry_credentials" {
  depends_on = [helm_release.custom_resource_definitions]
  name                  = "registry-creds"
  repository            = "https://charts.iits.tech"
  chart                 = "registry-creds"
  version               = local.charts.registry_creds_version
  namespace             = "registry-creds"
  create_namespace      = true
  atomic                = true
  render_subchart_notes = true
  dependency_update     = true
  set_sensitive {
    name  = "defaultClusterPullSecret.dockerConfigJsonBase64Encoded"
    value = base64encode(jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          username = var.dockerhub_username
          password = var.dockerhub_password
          auth     = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
        }
      }
    }))
  }
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

resource "helm_release" "argocd" {
  depends_on = [helm_release.custom_resource_definitions,helm_release.registry_credentials]
  name                  = "argocd"
  repository            = "https://charts.iits.tech"
  chart                 = "argocd"
  version               = local.charts.argo_version
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
      projects = {
        infrastructure-charts = {
          projectValues = {
            # Set this to enable stage $STAGE-values.yaml
            stage        = var.stage
            traefikElbId = module.terraform_secrets_from_encrypted_s3_bucket.secrets["elb_id"]
            adminDomain  = "admin.${var.domain_name}"
            storageClassKmsKeyId = module.terraform_secrets_from_encrypted_s3_bucket.secrets["storage_class_kms_key_id"]
          }

          git = {
            password = var.git_token
            repoUrl  = var.argocd_bootstrap_project_url
          }
        }
      }
    }
    )
  ]
}