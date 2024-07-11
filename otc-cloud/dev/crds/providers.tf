
provider "kubectl" {
  host                   = data.terraform_remote_state.infrastructure.outputs.kubernetes["api_endpoint"]
  client_certificate     = base64decode(data.terraform_remote_state.infrastructure.outputs.kubernetes["client_certificate"])
  client_key             = base64decode(data.terraform_remote_state.infrastructure.outputs.kubernetes["client_key"])
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.kubernetes["certificate_authority"])
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.infrastructure.outputs.kubernetes["api_endpoint"]
    client_certificate     = base64decode(data.terraform_remote_state.infrastructure.outputs.kubernetes["client_certificate"])
    client_key             = base64decode(data.terraform_remote_state.infrastructure.outputs.kubernetes["client_key"])
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.kubernetes["certificate_authority"])
  }
}