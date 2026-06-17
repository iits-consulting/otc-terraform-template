module "vpc" {
  source     = "iits-consulting/vpc/opentelekomcloud"
  version    = "7.4.2"
  name       = "${var.context}-${var.stage}-vpc"
  cidr_block = var.vpc_cidr
  subnets = {
    "kubernetes-subnet" = cidrsubnet(var.vpc_cidr, 2, 0) // 10.8.0.0/22
    "gateway-subnet"    = cidrsubnet(var.vpc_cidr, 3, 2) // 10.8.4.0/23
    "database-subnet"   = cidrsubnet(var.vpc_cidr, 3, 3) // 10.8.6.0/23
  }
  tags = local.tags
}

module "snat" {
  source        = "iits-consulting/snat/opentelekomcloud"
  version       = "7.4.2"
  name_prefix   = "${var.context}-${var.stage}"
  subnet_id     = module.vpc.subnets["gateway-subnet"].id
  vpc_id        = module.vpc.vpc.id
  network_cidrs = [var.vpc_cidr]
}

module "public_loadbalancer" {
  source       = "iits-consulting/loadbalancer/opentelekomcloud"
  version      = "7.5.0"
  context_name = var.context
  subnet_id    = module.vpc.subnets["gateway-subnet"].subnet_id
  stage_name   = var.stage
  bandwidth    = 500
}

output "public_loadbalancer" {
  sensitive   = true
  description = "Parameters related to the public loadbalancer intended to be used by the ingress controller (Traefik)."
  value = {
    id         = module.public_loadbalancer.elb_id
    public_ip  = module.public_loadbalancer.elb_public_ip
    private_ip = module.public_loadbalancer.elb_private_ip
  }
}
