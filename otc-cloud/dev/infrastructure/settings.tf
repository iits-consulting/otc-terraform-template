terraform {
  required_version = ">=v1.4.6"

  #  backend "s3" {
  #    //TODO
  #  }

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.35.6"
    }
  }
}