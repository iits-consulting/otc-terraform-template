terraform {
  required_version = "v1.3.5"
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.34.4"
    }
  }
}