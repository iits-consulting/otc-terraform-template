terraform {
  required_version = "v1.5.7"

  backend "s3" {
    bucket                      = "forrester-dev-tfstate"
    key                         = "tfstate-crds"
    region                      = "eu-de"
    endpoint                    = "obs.eu-de.otc.t-systems.com"
    skip_region_validation      = true
    skip_credentials_validation = true
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