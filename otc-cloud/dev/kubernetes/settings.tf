terraform {
  required_version = "v1.3.5"

  backend "s3" {
    //TODO
  }
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.32.4"
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
