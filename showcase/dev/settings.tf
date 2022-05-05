terraform {
  required_version = "v1.1.4"
  #TODO Add Backend Config here

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.28.2"
    }
  }
}