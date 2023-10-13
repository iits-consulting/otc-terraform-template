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

resource "random_password" "basic_auth_password" {
  length      = 32
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

resource "helm_release" "argocd" {
  depends_on = [
    helm_release.custom_resource_definitions, helm_release.otc_storage_classes, helm_release.iits_kyverno_policies
  ]
  name                  = "argocd"
  repository            = "https://charts.iits.tech"
  chart                 = "argocd"
  version               = local.chart_versions.argo
  namespace             = "argocd"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  values = [
    yamlencode({
      projects = {
        infrastructure-charts = {
          projectValues = {
            # Set this to enable stage $STAGE-values.yaml
            stage             = var.stage
            traefikElbId      = module.terraform_secrets_from_encrypted_s3_bucket.secrets["elb_id"]
            rootDomain        = var.domain_name
            basicAuthPassword = random_password.basic_auth_password.result
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

resource "local_file" "basic_auth_password" {
  filename = "basic-auth-password.txt"
  content  = "The basic auth credentials for the admin domain are username=admin and password=${random_password.basic_auth_password.result}"
}