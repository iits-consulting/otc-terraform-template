resource "helm_release" "ollama" {
  depends_on = [helm_release.otc_storage_classes,helm_release.traefik]
  name       = "ollama"
  repository = "https://charts.iits.tech"
  chart      = "ollama"
  version    = local.chart_versions.ollama
  namespace  = "llm"
  create_namespace = true

  values = [
    templatefile("ollama-values.yaml", {
      domain_name = var.domain_name
    })
  ]
}