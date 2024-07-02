terraform {
  required_version = ">=v1.4.6"

  #  backend "s3" {
  #    //TODO
  #  }

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

