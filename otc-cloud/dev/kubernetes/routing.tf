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
  values = [
    yamlencode({
      ingressRoute = {
        rootDomain  = var.domain_name
        adminDomain = "admin.${var.domain_name}"
      }
      traefik = {
        additionalArguments = [
          "--ping",
          "--entryPoints.web.forwardedHeaders.trustedIPs=100.125.0.0/16",
          "--entryPoints.websecure.forwardedHeaders.trustedIPs=100.125.0.0/16",
        ]
        providers = {
          kubernetesCRD = {
            enabled                   = true
            allowExternalNameServices = true
            allowCrossNamespace       = true
          }
          kubernetesIngress = {
            enabled                   = true
            allowExternalNameServices = true
            publishedService = {
              enabled = true
            }
          }
        }
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

resource "helm_release" "cert-manager" {
  name                  = "cert-manager"
  chart                 = "cert-manager"
  repository            = "https://charts.iits.tech"
  version               = local.chart_versions.cert-manager
  namespace             = "cert-manager"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  values = [yamlencode({
    cert-manager = {
      replicaCount = 2
    }
    clusterIssuer = {
      http = {
        name  = "letsencrypt"
        email = var.email
      }
    }
  })]
  depends_on = [helm_release.traefik]
}