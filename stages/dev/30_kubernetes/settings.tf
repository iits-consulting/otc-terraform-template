terraform {
  required_version = "~> v1.10.2"

  //TODO Add backend config S3 here

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
