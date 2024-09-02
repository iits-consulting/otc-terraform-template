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
        dashboard = {
          middlewares = [{
            name      = "oidc-forward-auth"
            namespace = "routing"
          }]
        }
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
      }
    })
  ]
}


resource opentelekomcloud_identity_credential_v3 cert_manager_ak_sk {
  user_id = var.otc_user_id
}

resource "helm_release" "cert-manager" {
  name                  = "cert-manager"
  chart                 = "cert-manager"
  repository            = "https://charts.iits.tech"
  version               = "1.14.5"
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
          accessKey = opentelekomcloud_identity_credential_v3.cert_manager_ak_sk.access
          secretKey = opentelekomcloud_identity_credential_v3.cert_manager_ak_sk.secret
        }
      }
    })
  ])
  depends_on = [helm_release.traefik]
}