resource "helm_release" "kyverno" {
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

  set_sensitive {
    name  = "autoInjectDockerPullSecrets.secrets.dockerhub.password"
    value = var.dockerhub_password
  }
  values = [
    yamlencode({
      ingress = {
        host = "admin.${var.domain_name}"
      }
      enforceSecurityContext = {
        enabled = false
      }
      autoInjectDockerPullSecrets = {
        secrets = {
          dockerhub = {
            username         = var.dockerhub_username
            registryUrl      = "docker.io"
            registryWildcard = "*"
          }
        }
      }
    })
  ]
}
