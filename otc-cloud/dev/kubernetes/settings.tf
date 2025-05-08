terraform {
  required_version = "v1.9.0"

  backend "s3" {
    bucket                      = "mercury-dev-tfstate"
    key                         = "tfstate-kubernetes"
    region                      = "eu-de"
    endpoints = {
      s3 = "https://obs.eu-de.otc.t-systems.com"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }



  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.35.6"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}