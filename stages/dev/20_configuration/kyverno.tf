resource "helm_release" "kyverno" {
  name                  = "kyverno"
  repository            = "https://charts.iits.tech"
  version               = var.chart_versions.kyverno
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

  set_sensitive = [for name, value in {
    "autoInjectDockerPullSecrets.secrets.dockerhub.username" = var.dockerhub_username
    "autoInjectDockerPullSecrets.secrets.dockerhub.password" = var.dockerhub_password
    } : {
    name  = name
    value = value
  }]

  values = [
    yamlencode({
      ingress = {
        host = "admin.${var.domain_name}"
        annotations = {
          "traefik.ingress.kubernetes.io/router.middlewares" = "routing-oidc-forward-auth@kubernetescrd,kyverno-strip-prefix-kyverno@kubernetescrd"
        }
      }
      kyverno = {
        config = {
          resourceFiltersIncludeNamespaces = ["kube-system"]
        }
      }
      enforceSecurityContext = {
        enabled = false
      }
      autoInjectDockerPullSecrets = {
        secrets = {
          dockerhub = {
            registryUrl      = "docker.io"
            registryWildcard = "*"
          }
        }
      }
    })
  ]
  depends_on = [module.crds]
}
