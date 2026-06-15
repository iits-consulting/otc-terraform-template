module "public_dns" {
  source  = "iits-consulting/public-dns/opentelekomcloud"
  version = "7.4.2"

  domain = var.domain_name
  email  = var.email
  a_records = {
    (var.domain_name) = [module.public_loadbalancer.elb_public_ip]
    admin             = [module.public_loadbalancer.elb_public_ip]
  }
  caa_records = {
    (var.domain_name) = ["0 issue \"letsencrypt.org;validationmethods=dns-01\""]
  }
  tags = local.tags
}

module "private_dns_vpc" {
  source  = "iits-consulting/private-dns/opentelekomcloud"
  version = "7.4.2"

  vpc_id = module.vpc.vpc.id
  domain = "vpc.private"
  a_records = {
    kubernetes = [split(":", trimprefix(module.cce_cluster.cluster_private_ip, "https://"))[0]]
  }
  tags = local.tags
}
