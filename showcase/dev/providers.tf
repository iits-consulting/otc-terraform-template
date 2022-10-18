provider "opentelekomcloud" {
  auth_url = "https://iam.${var.region}.otc.t-systems.com/v3"
}

provider "opentelekomcloud" {
  auth_url    = "https://iam.${var.region}.otc.t-systems.com/v3"
  tenant_name = var.region
  alias       = "top_level_project"
}
