data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket                      = "${var.context}-${var.stage}-tfstate"
    key                         = "tfstate-infra"
    region                      = var.region
    endpoint                    = "https://obs.${var.region}.otc.t-systems.com"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
