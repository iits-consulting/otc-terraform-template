resource "helm_release" "custom_resource_definitions" {
  name                  = "crds"
  repository            = "https://charts.iits.tech"
  chart                 = "crds"
  version               = local.charts.crds_version
  namespace             = "crds"
  create_namespace      = true
  render_subchart_notes = true
  dependency_update     = true
}