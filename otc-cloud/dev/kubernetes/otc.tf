resource "random_id" "storage_class_kms_id" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "storage_class_kms_key" {
  key_alias       = "${var.context}-${var.stage}-cce-pv-key-${random_id.storage_class_kms_id.hex}"
  key_description = "${var.context}-${var.stage}-cce-cluster persistent volume encryption key"
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
  render_subchart_notes = true
  dependency_update     = true
  values = sensitive([yamlencode({
    kmsId = opentelekomcloud_kms_key_v1.storage_class_kms_key.id
  })])
}