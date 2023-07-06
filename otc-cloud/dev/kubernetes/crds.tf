resource "helm_release" "custom_resource_definitions" {
  name                  = "crds"
  repository            = "https://charts.iits.tech"
  chart                 = "crds"
  version               = local.chart_versions.crds
  namespace             = "crds"
  create_namespace      = true
  render_subchart_notes = true
  dependency_update     = true
}