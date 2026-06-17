terraform {
  required_version = "1.10.2"

  //TODO Add backend config S3 here

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.36"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
  }
}
