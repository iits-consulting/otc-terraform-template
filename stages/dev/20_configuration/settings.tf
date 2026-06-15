terraform {
  required_version = "1.9.0"

  ##### STATE BACKEND CONFIGURATION #####
  backend "s3" {
    bucket                      = "${var.context}-${var.stage}-tfstate"
    key                         = "tfstate-${split("_", basename(abspath(path.module)))[1]}"
    region                      = var.region
    endpoints = {
      s3 = "https://obs.${var.region}.otc.t-systems.com"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.36"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}
