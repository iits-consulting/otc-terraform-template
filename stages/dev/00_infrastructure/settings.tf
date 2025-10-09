terraform {
  required_version = "~> v1.10.2"

  //TODO Add backend config S3 here

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.36"
    }
    errorcheck = {
      source  = "iits-consulting/errorcheck"
      version = "~> 3.0"
    }
  }
}
