terraform {
  required_version = "v1.9.0"

  backend "s3" {
    bucket                      = "mercury-dev-tfstate"
    key                         = "tfstate-crds"
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
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">=1.14.0"
    }
  }
}