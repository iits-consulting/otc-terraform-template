resource "random_password" "basic_auth_password" {
  length      = 32
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

resource "helm_release" "argocd" {
  depends_on            = [helm_release.cce_storage_classes]
  name                  = "argocd"
  repository            = "https://charts.iits.tech"
  chart                 = "argocd"
  version               = "16.3.3"
  namespace             = "argocd"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 300 // 5 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  values = [
    yamlencode({
      argo-cd = {
        server = {
          config = {
            "oidc.config" = ""
          }
          ingress = {
            hostname = "admin.${var.domain_name}"
          }
        }
      }
      projects = {
        infrastructure-charts = {
          projectValues = {
            # Set this to enable stage $STAGE-values.yaml
            stage             = var.stage
            rootDomain        = var.domain_name
            basicAuthPassword = var.admin_website_password
          }
          git = {
            password = var.git_token
            repoUrl  = var.argocd_bootstrap_project_url
            branch   = "main"
          }
        }
      }
    })
  ]
}