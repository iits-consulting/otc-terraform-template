terraform {
  required_version = "v1.3.5"
  backend "s3" {
    bucket = "eu-de-victor-dev-tfstate"
    kms_key_id = "arn:aws:kms:eu-de:d32336fe26ec415caa04e17e9adfb6a8:key/6fbbeab3-3443-45d0-86fe-116a1ba40144"
    key = "tfstate"
    region = "eu-de"
    endpoint = "obs.eu-de.otc.t-systems.com"
    encrypt = true
    skip_region_validation = true
    skip_credentials_validation = true
  }

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.32.4"
    }
  }
}