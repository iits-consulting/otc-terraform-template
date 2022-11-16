terraform {
  required_version = "v1.3.4"
  #TODO Add Backend Config here

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.29.5"
    }
  }
}