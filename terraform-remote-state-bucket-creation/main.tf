locals {
  bucket_name = "${var.region}-${var.context}-${var.stage}-tfstate"
  statefiles  = tomap({
    infrastructure = {
      fileName     = "tfstate-infrastructure"
      settingsPath = "otc-cloud/${var.stage}/settings.tf"
    },
    kubernetes = {
      fileName     = "tfstate-kubernetes"
      settingsPath = "otc-cloud/${var.stage}/kubernetes/settings.tf"
    }
  })
}

resource "opentelekomcloud_obs_bucket" "tf_remote_state" {
  bucket     = local.bucket_name
  acl        = "private"
  versioning = true
  server_side_encryption {
    algorithm  = "kms"
    kms_key_id = opentelekomcloud_kms_key_v1.tf_remote_state_bucket_kms_key.id
  }
}

resource "random_id" "id" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "tf_remote_state_bucket_kms_key" {
  key_alias       = "${local.bucket_name}-key-${random_id.id.hex}"
  key_description = "${local.bucket_name} encryption key"
  pending_days    = 7
  is_enabled      = "true"
}

resource "opentelekomcloud_s3_bucket_object" "state_files" {
  for_each     = local.statefiles
  bucket       = opentelekomcloud_obs_bucket.tf_remote_state.bucket
  key          = each.value.fileName
  source       = "empty_tfstate"
  content_type = "application/json;charset=UTF-8"
}

output "backend_config" {
  value = <<EOT

      Put this under otc-cloud/${var.stage}/settings.tf under TODO !

      backend "s3" {
        bucket = "${opentelekomcloud_obs_bucket.tf_remote_state.bucket}"
        kms_key_id = "${opentelekomcloud_s3_bucket_object.state_files["infrastructure"].sse_kms_key_id}"
        key = "${opentelekomcloud_s3_bucket_object.state_files["infrastructure"].key}"
        region = "${opentelekomcloud_obs_bucket.tf_remote_state.region}"
        endpoint = "obs.${var.region}.otc.t-systems.com"
        encrypt = true
        skip_region_validation = true
        skip_credentials_validation = true
      }

      Put this under otc-cloud/${var.stage}/kubernetes/settings.tf under TODO !

      backend "s3" {
        bucket = "${opentelekomcloud_obs_bucket.tf_remote_state.bucket}"
        kms_key_id = "${opentelekomcloud_s3_bucket_object.state_files["kubernetes"].sse_kms_key_id}"
        key = "${opentelekomcloud_s3_bucket_object.state_files["kubernetes"].key}"
        region = "${opentelekomcloud_obs_bucket.tf_remote_state.region}"
        endpoint = "obs.${var.region}.otc.t-systems.com"
        encrypt = true
        skip_region_validation = true
        skip_credentials_validation = true
      }
  EOT
}
