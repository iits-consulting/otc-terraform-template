terraform {
  required_version = "v1.9.5"

  //TODO Add backend config S3 here

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