provider "opentelekomcloud" {
  cloud = "${var.os_domain_name}_${var.region}_${var.context}"
}

provider "kubernetes" {
  host                   = module.terraform_secrets_from_encrypted_s3_bucket.secrets["kube_api_endpoint"]
  client_certificate     = base64decode(module.terraform_secrets_from_encrypted_s3_bucket.secrets["client_certificate_data"])
  client_key             = base64decode(module.terraform_secrets_from_encrypted_s3_bucket.secrets["client_key_data"])
  cluster_ca_certificate = base64decode(module.terraform_secrets_from_encrypted_s3_bucket.secrets["kubernetes_ca_cert"])
}

provider "helm" {
  kubernetes {
    host                   = module.terraform_secrets_from_encrypted_s3_bucket.secrets["kube_api_endpoint"]
    client_certificate     = base64decode(module.terraform_secrets_from_encrypted_s3_bucket.secrets["client_certificate_data"])
    client_key             = base64decode(module.terraform_secrets_from_encrypted_s3_bucket.secrets["client_key_data"])
    cluster_ca_certificate = base64decode(module.terraform_secrets_from_encrypted_s3_bucket.secrets["kubernetes_ca_cert"])
  }
}
