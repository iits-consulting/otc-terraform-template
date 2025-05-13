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
              name      = "basic-auth"
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

resource "helm_release" "cert-manager" {
  name                  = "cert-manager"
  chart                 = "cert-manager"
  repository            = "https://charts.iits.tech"
  version               = "1.17.2"
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