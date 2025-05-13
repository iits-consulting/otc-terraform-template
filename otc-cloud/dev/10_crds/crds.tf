module "crds" {
  source     = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/crd_installer"
  version    = "7.5.0"
  apply_only = false
  default_chart_overrides = {
    traefik = {
      version = "35.2.0"
    }
    kyverno = {
      version = "2.4.0"
    }
    cert-manager = {
      version = "1.17.2"
    }
    prometheus-stack = {
      version = "63.1.0"
    }
  }
}
