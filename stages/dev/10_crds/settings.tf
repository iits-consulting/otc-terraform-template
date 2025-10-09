terraform {
  required_version = "~> v1.10.2"

  //TODO Add backend config S3 here

  required_providers {
    helm = {
      source = "hashicorp/helm"
      //TODO: Check if works
      //version = "~> 2.17"
      version = "~> 3.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}
