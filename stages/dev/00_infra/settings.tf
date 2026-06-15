terraform {
  required_version = "1.10.2"

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
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.36"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    errorcheck = {
      source  = "iits-consulting/errorcheck"
      version = "~> 3.0"
    }
  }
}
