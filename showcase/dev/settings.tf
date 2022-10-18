terraform {
  required_version = "v1.1.7"
  #TODO Add Backend Config here

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.29.5"
    }
  }
}