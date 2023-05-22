resource "helm_release" "registry_credentials" {
  depends_on            = [helm_release.custom_resource_definitions,helm_release.iits_kyverno_policies]
  name                  = "registry-creds"
  repository            = "https://charts.iits.tech"
  chart                 = "registry-creds"
  version               = local.charts.registry_creds_version
  namespace             = "registry-creds"
  create_namespace      = true
  atomic                = true
  render_subchart_notes = true
  dependency_update     = true
  set_sensitive {
    name  = "defaultClusterPullSecret.dockerConfigJsonBase64Encoded"
    value = base64encode(jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          username = var.dockerhub_username
          password = var.dockerhub_password
          auth     = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
        }
      }
    }))
  }
}
