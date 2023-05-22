resource "helm_release" "kyverno" {
  name                  = "kyverno"
  repository            = "https://charts.iits.tech"
  version               = local.charts.kyverno_version
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
  # The entrypoint to your cluster highly depends on your local setup
  values                = [
    yamlencode({
      route = {
        enabled = true
      }
    })
  ]
}

resource "helm_release" "iits_kyverno_policies" {
  wait_for_jobs         = true
  depends_on            = [helm_release.kyverno]
  name                  = "iits-kyverno-policies"
  repository            = "https://charts.iits.tech"
  version               = local.charts.iits_kyverno_policies_version
  chart                 = "iits-kyverno-policies"
  namespace             = "kyverno"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
}