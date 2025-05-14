resource "random_id" "cce_autoencryption_kms_id" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "cce_autoencryption_kms_key" {
  key_alias       = "${data.terraform_remote_state.infrastructure.outputs.kubernetes["cce_name"]}-pv-key-${random_id.cce_autoencryption_kms_id.hex}"
  key_description = "${data.terraform_remote_state.infrastructure.outputs.kubernetes["cce_name"]}-cluster persistent volume encryption key"
  pending_days    = 7
  is_enabled      = "true"
}

resource "helm_release" "otc_storage_classes" {
  name                  = "otc-storage-classes"
  repository            = "https://charts.iits.tech"
  chart                 = "otc-storage-classes"
  version               = local.chart_versions.otc_storage_classes
  namespace             = "storage"
  create_namespace      = true
  wait                  = true
  atomic                = true
  render_subchart_notes = true
  dependency_update     = true
  values = [
    yamlencode({
      kmsId = opentelekomcloud_kms_key_v1.cce_autoencryption_kms_key.id
    })
  ]
}