terraform {
  required_version = "v1.3.5"

  backend "s3" {
    bucket = "eu-de-victor-dev-tfstate"
    kms_key_id = "arn:aws:kms:eu-de:d32336fe26ec415caa04e17e9adfb6a8:key/12077fa3-582f-4757-a078-f704c3e9a501"
    key = "tfstate-kubernetes"
    region = "eu-de"
    endpoint = "obs.eu-de.otc.t-systems.com"
    encrypt = true
    skip_region_validation = true
    skip_credentials_validation = true
  }
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "1.29.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.10.0"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}
