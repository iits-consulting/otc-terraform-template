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
  depends_on            = [helm_release.custom_resource_definitions, helm_release.registry_credentials, helm_release.iits_kyverno_policies]
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
            stage                = var.stage
            traefikElbId         = module.terraform_secrets_from_encrypted_s3_bucket.secrets["elb_id"]
            adminDomain          = "admin.${var.domain_name}"
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