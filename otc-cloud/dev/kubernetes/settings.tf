terraform {
  required_version = "v1.9.0"

  //TODO Add backend config S3 here

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