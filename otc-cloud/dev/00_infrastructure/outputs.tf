output "kubernetes" {
  sensitive = true
  value = {
    certificate_authority = module.cce.cluster_credentials.cluster_certificate_authority_data
    client_certificate    = module.cce.cluster_credentials.client_certificate_data
    api_endpoint          = module.cce.cluster_public_ip
    api_private_endpoint  = module.cce.cluster_private_ip
    client_key            = module.cce.cluster_credentials.client_key_data
    cce_id                = module.cce.cluster_id
    cce_name              = module.cce.cluster_name
    kubectl_config        = module.cce.kubeconfig
  }
}

output "elb" {
  sensitive = true
  value = {
    id         = module.loadbalancer.elb_id
    public_ip  = module.loadbalancer.elb_public_ip
    private_ip = module.loadbalancer.elb_private_ip
  }
}

resource "null_resource" "get_kube_config" {
  depends_on = [module.cce]
  provisioner "local-exec" {
    command = "../.envrc"
  }
}