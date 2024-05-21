resource "helm_release" "ollama" {
  depends_on       = [helm_release.otc_storage_classes, helm_release.traefik]
  repository       = "https://charts.iits.tech"
  name             = "ollama"
  chart            = "ollama"
  version          = local.chart_versions.ollama
  namespace        = "llm"
  create_namespace = true
  values           = [
    yamlencode({
      ollama = {
        ingress = {
          host = "ollama.${var.domain_name}"
        }
      }
      webui = {
        env = {
          OLLAMA_BASE_URL = "https://ollama.${var.domain_name}"
        }
        ingress = {
          host = "llm.${var.domain_name}"
        }
      }
    })
  ]
}