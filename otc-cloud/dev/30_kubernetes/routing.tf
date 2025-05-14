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
          annotations = {
            "kubernetes.io/elb.id"                    = data.terraform_remote_state.infrastructure.outputs.elb["id"]
            "kubernetes.io/elb.transparent-client-ip" = "true"
          }
        }
      }
    })
  ]
  depends_on = [helm_release.kyverno]
}

resource "opentelekomcloud_identity_credential_v3" "cert_manager_ak_sk" {
  user_id = var.otc_user_id
}

resource "helm_release" "cert_manager" {
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

  dynamic "set_sensitive" {
    for_each = {
      "clusterIssuers.otcDNS.accessKey" = opentelekomcloud_identity_credential_v3.cert_manager_ak_sk.access
      "clusterIssuers.otcDNS.secretKey" = opentelekomcloud_identity_credential_v3.cert_manager_ak_sk.secret
    }
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }
  values = concat([
    yamlencode({
      clusterIssuers = {
        email = var.email
        otcDNS = {
          region = var.region
        }
      }
    })
  ])
  depends_on = [helm_release.kyverno]
}