// ArgoCD server
resource "helm_release" "argocd" {
  name                  = "argocd"
  repository            = "https://charts.iits.tech"
  chart                 = "argocd"
  version               = var.chart_versions.argocd
  namespace             = "argocd"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true

  values = [
    yamlencode({
      argo-cd = {
        global = {
          domain = "admin.${var.domain_name}"
        }
        server = {
          configs = {
            "oidc.config" = ""
            cm = {
              "resource.customizations.ignoreDifferences.argoproj.io_Application" = <<-EOT
jqPathExpressions:
- '. | select(.metadata.annotations.globalParametersChecksum) | .spec.sources[] | select(.helm.parameters) | .helm.parameters'
- '. | select(.metadata.annotations.chartParametersChecksum) | .spec.sources[] | select(.helm.parameters) | .helm.parameters'
- '. | select(.metadata.annotations.valueFileChecksum) | .spec.sources[] | select(.helm.values) | .helm.values'
EOT
            }
          }
          ingress = {
            hostname = "admin.${var.domain_name}"
          }
        }
      }
    })
  ]
  depends_on = [helm_release.kyverno]
}
// ArgoCD app(s)
resource "helm_release" "argocd_apps" {
  name                  = "argocd-apps"
  chart                 = "argocd-apps"
  repository            = "https://charts.iits.tech"
  version               = var.chart_versions.argocd_apps
  namespace             = helm_release.argocd.namespace
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 120 // 2 minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true

  set_sensitive = [for name, value in {
    "projects.infrastructure-charts.git.repoUrl"                                = var.argocd_repo_url
    "projects.infrastructure-charts.git.password"                               = var.git_token
    "projects.infrastructure-charts.tofuValues.projectValues.basicAuthPassword" = var.admin_website_password
    } : {
    name  = name
    value = value
  }]

  values = [
    yamlencode({
      projects = {
        infrastructure-charts = {
          tofuValues = {
            projectValues = {
              context     = var.context
              stage       = var.stage
              stageDomain = var.domain_name
              region      = var.region
            }
          }
          git = {
            branch = "main"
          }
        }
      }
    })
  ]
  depends_on = [helm_release.argocd]
}
