resource "helm_release" "traefik" {
  name                  = "traefik"
  chart                 = "traefik"
  repository            = "https://charts.iits.tech"
  version               = var.chart_versions.traefik
  namespace             = "routing"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true

  values = [
    yamlencode({
      defaultCert = {
        dnsNames = [
          var.domain_name,
          "*.${var.domain_name}",
        ]
      }
      traefik = {
        ingressRoute = {
          dashboard = {
            matchRule = "Host(`admin.${var.domain_name}`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))"
            middlewares = [{
              name      = "oidc-forward-auth"
              namespace = "routing"
            }]
          }
          healthcheck = {
            enabled = true
          }
        }
        service = {
          spec = {
            externalTrafficPolicy = "Local"
          }
          annotations = {
            "kubernetes.io/elb.id"                    = data.terraform_remote_state.infrastructure.outputs.public_loadbalancer["id"]
            "kubernetes.io/elb.transparent-client-ip" = "true"
          }
        }
      }
    })
  ]
  depends_on = [helm_release.kyverno]
}
