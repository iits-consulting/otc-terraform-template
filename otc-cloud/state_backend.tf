terraform {
  required_version = "v1.9.0"
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.36.12"
    }
  }
}

provider "opentelekomcloud" {
  auth_url       = "https://iam.${var.region}.otc.t-systems.com/v3"
  tenant_name    = var.region
  security_token = var.ak_sk_security_token
}

resource "random_id" "kms_key_unique_suffix" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "remote_state_bucket_kms_key" {
  key_alias       = "${local.tf_state_bucket_name}-key-${random_id.kms_key_unique_suffix.hex}"
  key_description = "${local.tf_state_bucket_name} encryption key"
  pending_days    = 7
  is_enabled      = "true"
}

resource "opentelekomcloud_obs_bucket" "remote_state_bucket" {
  bucket     = local.tf_state_bucket_name
  acl        = "private"
  versioning = true
  server_side_encryption {
    algorithm  = "kms"
    kms_key_id = opentelekomcloud_kms_key_v1.remote_state_bucket_kms_key.id
  }
  lifecycle {
    prevent_destroy = true
  }
}

output "terraform_state_backend_config" {
  value = [for path in local.terraform_paths : <<EOT

Place this this under otc-cloud/${var.stage}/${path}/settings.tf under TODO !
    backend "s3" {
      bucket                      = "${opentelekomcloud_obs_bucket.remote_state_bucket.bucket}"
      key                         = "tfstate-${split("_", path)[1]}"
      region                      = "${opentelekomcloud_obs_bucket.remote_state_bucket.region}"
      endpoints = {
        s3 = "https://obs.${opentelekomcloud_obs_bucket.remote_state_bucket.region}.otc.t-systems.com"
      }
      skip_region_validation      = true
      skip_credentials_validation = true
      skip_requesting_account_id  = true
      skip_s3_checksum            = true
    }
  EOT
  ]
}
