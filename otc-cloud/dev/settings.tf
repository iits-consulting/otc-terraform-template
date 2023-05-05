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
  }
}