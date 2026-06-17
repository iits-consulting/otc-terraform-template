resource "opentelekomcloud_identity_credential_v3" "cert_manager_ak_sk" {
  user_id = var.otc_user_id
}

resource "helm_release" "cert_manager" {
  name                  = "cert-manager"
  chart                 = "cert-manager"
  repository            = "https://charts.iits.tech"
  version               = var.chart_versions.cert-manager
  namespace             = "cert-manager"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true

  set_sensitive = [for name, value in {
    "clusterIssuers.otcDNS.accessKey" = opentelekomcloud_identity_credential_v3.cert_manager_ak_sk.access
    "clusterIssuers.otcDNS.secretKey" = opentelekomcloud_identity_credential_v3.cert_manager_ak_sk.secret
    } : {
    name  = name
    value = value
  }]

  values = [
    yamlencode({
      clusterIssuers = {
        email = var.email
        otcDNS = {
          region = var.region
        }
      }
    })
  ]
  depends_on = [helm_release.kyverno]
}
