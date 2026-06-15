locals {
  crd_charts = {
    cert-manager = {
      version = var.chart_versions.cert-manager
      values = {
        cert-manager = {
          crds = {
            enabled = true
          }
        }
      }
    }
    kyverno = {
      version = var.chart_versions.kyverno
      values = {
        kyverno = {
          crds = {
            install = true
          }
        }
      }
    }
    prometheus-stack = {
      version = var.chart_versions.prometheus-stack
      values = {
        prometheusStack = {
          crds = {
            enabled = true
          }
        }
      }
    }
  }
}

module "crds" {
  source  = "iits-consulting/crd-installer/kubernetes"
  version = "8.0.1"

  for_each = local.crd_charts

  chart_name    = each.key
  chart_version = each.value.version
  chart_values  = [yamlencode(each.value.values)]
  apply_only    = true
}
