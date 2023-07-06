resource "helm_release" "kyverno" {
  depends_on = [helm_release.custom_resource_definitions]
  name                  = "kyverno"
  repository            = "https://charts.iits.tech"
  version               = local.chart_versions.kyverno
  chart                 = "kyverno"
  namespace             = "kyverno"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  skip_crds             = false
  # The entrypoint to your cluster highly depends on your local setup
  values                = [
    yamlencode({
      ingressRoute = {
        enabled     = true
        adminDomain = "admin.${var.domain_name}"
      }
    })
  ]
}

resource "helm_release" "iits_kyverno_policies" {
  depends_on            = [helm_release.kyverno]
  wait_for_jobs         = true
  name                  = "iits-kyverno-policies"
  repository            = "https://charts.iits.tech"
  version               = local.chart_versions.iits_kyverno_policies
  chart                 = "iits-kyverno-policies"
  namespace             = "kyverno"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  values                = sensitive([yamlencode({
    autoInjectDockerPullSecrets = {
      enabled = true
      secrets = {
        dockerhub = {
          username         = var.dockerhub_username
          password         = var.dockerhub_password
          registryUrl      = "https://index.docker.io/v1"
          registryWildcard = "*"
        }
      }
    }
  })])
}