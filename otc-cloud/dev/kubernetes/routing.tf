resource "helm_release" "traefik" {
  name                  = "traefik"
  chart                 = "traefik"
  repository            = "https://charts.iits.tech"
  version               = "28.2.0"
  namespace             = "routing"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 300
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
      ingressRoute = {
        healthcheck = {
          enabled = true
        }
      }
      traefik = {
        additionalArguments = [
          "--ping",
          "--entryPoints.web.forwardedHeaders.trustedIPs=100.125.0.0/16",
          "--entryPoints.websecure.forwardedHeaders.trustedIPs=100.125.0.0/16",
        ]
        service = {
          annotations = {
            "kubernetes.io/elb.id" = data.terraform_remote_state.infrastructure.outputs.elb["id"]
          }
        }
      }
    })
  ]
}


resource "helm_release" "cert-manager" {
  name                  = "cert-manager"
  chart                 = "cert-manager"
  repository            = "https://charts.iits.tech"
  version               = "1.0.1"
  namespace             = "cert-manager"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  values = concat([
    yamlencode({
      clusterIssuers = {
        email = var.email
        otcDNS = {
          region    = var.region
          accessKey = var.cert_manager_access_key
          secretKey = var.cert_manager_secret_key
        }
      }
    })
  ])
  depends_on = [helm_release.traefik]
}