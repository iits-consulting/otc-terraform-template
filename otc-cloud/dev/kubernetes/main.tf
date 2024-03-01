module "tf_state_bucket" {
  source  = "registry.terraform.io/iits-consulting/project-factory/opentelekomcloud//modules/state_bucket"
  version     = "5.8.4"
  tf_state_bucket_name = "${var.context}-${var.stage}-kubernetes-tfstate"
  providers = {
    opentelekomcloud = opentelekomcloud.top_level_project
  }
}

output "terraform_state_backend_configs" {
  value = module.tf_state_bucket.terraform_state_backend_config
}