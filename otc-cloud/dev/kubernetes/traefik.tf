resource "helm_release" "traefik" {
  name                  = "traefik"
  chart                 = "traefik"
  repository            = "https://charts.iits.tech"
  version               = local.chart_versions.traefik
  namespace             = "routing"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  values = [yamlencode({
    ingress = {
      host = var.domain_name
    }
    defaultCert = {
      dnsNames = {
        rootDomain  = var.domain_name
        adminDomain = "admin.${var.domain_name}"
      }

    }
    traefik = {
      service = {
        annotations = {
          "kubernetes.io/elb.id" = data.terraform_remote_state.infrastructure.outputs.elb["id"]
        }
      }
    }
    })
  ]
  depends_on = [helm_release.custom_resource_definitions]
}