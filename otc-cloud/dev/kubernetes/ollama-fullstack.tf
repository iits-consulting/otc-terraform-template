resource "helm_release" "ollama_fullstack" {
  name       = "iits-ollama-fullstack"
  repository = "https://charts.iits.tech"
  chart      = "iits-ollama-fullstack"
  version    = local.chart_versions.iits_llm_fullstack
  namespace  = "llm"
  create_namespace = true

  values = [
    templatefile("ollama-fullstack-values.yaml", {
      domain_name = var.domain_name
    })
  ]
}