resource "helm_release" "kyverno" {
  wait_for_jobs         = true
  name                  = "kyverno"
  repository            = "https://charts.iits.tech"
  version               = "2.1.0"
  chart                 = "kyverno"
  namespace             = "kyverno"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 300 // 5 Minutes
  render_subchart_notes = true
  dependency_update     = true
  skip_crds             = true

  set_sensitive {
    name  = "autoInjectDockerPullSecrets.secrets.dockerhub.password"
    value = var.dockerhub_password
  }

  values = [
    yamlencode({
      ingress = {
        host = "admin.${var.domain_name}"
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

  depends_on = [helm_release.cce_storage_classes]
}