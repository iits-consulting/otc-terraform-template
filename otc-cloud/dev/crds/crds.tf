module "crds" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/crd_installer"
  version = "7.4.1"
  apply_only = false
  default_chart_overrides = {
    traefik = {
      version = "28.1.0"
    }
    kyverno = {
      version = "2.4.0"
    }
  }
}
