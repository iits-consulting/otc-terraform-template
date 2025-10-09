module "crds" {
  source     = "iits-consulting/crd-installer/kubernetes"
  version    = "v7.5.1"
  apply_only = false
  default_chart_overrides = {
    traefik = {
      version = "35.2.0"
    }
    kyverno = {
      version = "2.4.0"
    }
    cert-manager = {
      version = "1.17.4"
    }
    prometheus-stack = {
      version = "63.1.4"
    }
  }
}
