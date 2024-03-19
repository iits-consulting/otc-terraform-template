terraform {
  required_version = ">=v1.4.6"

  #  backend "s3" {
  #    //TODO
  #  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.0"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}
