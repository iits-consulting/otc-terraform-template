terraform {
  required_version = "1.10.2"

  //TODO Add backend config S3 here

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.36"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    errorcheck = {
      source  = "iits-consulting/errorcheck"
      version = "~> 3.0"
    }
  }
}
