// ArgoCD only accepts the admin password as a bcrypt hash, and bcrypt() returns a
// different hash on every run. terraform_data keeps one hash in the state and rehashes
// only when the password itself changes.
resource "terraform_data" "argocd_admin_password" {
  triggers_replace = [var.admin_website_password]
  input            = bcrypt(var.admin_website_password)

  lifecycle {
    ignore_changes = [input]
  }
}

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

  // login is admin / TF_VAR_admin_website_password
  set_sensitive = [{
    name  = "argo-cd.configs.secret.argocdServerAdminPassword"
    value = terraform_data.argocd_admin_password.output
  }]

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
