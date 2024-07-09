terraform {
  required_version = "v1.9.0"

  //TODO Add backend config S3 here

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.35.6"
    }
  }
}