// ArgoCD server
resource "helm_release" "argocd" {
  name                  = "argocd"
  repository            = "https://charts.iits.tech"
  chart                 = "argocd"
  version               = local.chart_versions.argocd
  namespace             = "argocd"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 120 // 2 minutes
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
    })
  ]
}
// ArgoCD app(s)
resource "helm_release" "argocd_apps" {
  name                  = "argocd-apps"
  chart                 = "argocd-apps"
  repository            = "https://charts.iits.tech"
  version               = local.chart_versions.argocd_apps
  namespace             = helm_release.argocd.namespace
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 120 // 2 minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true

  values = [
    yamlencode({
      projects = {
        infrastructure-charts = {
          tofuValues = {
            projectValues = {
              # Set this to enable stage values-$STAGE.yaml
              stage             = var.stage
              rootDomain        = var.domain_name
              basicAuthPassword = var.admin_website_password
            }
          }
          git = {
            password = var.git_token
            repoUrl  = var.argocd_repo_url
            branch   = "main"
          }
        }
      }
    })
  ]
}
