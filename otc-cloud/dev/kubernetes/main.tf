module "tf_state_bucket" {
  source               = "../../../modules/state_bucket"
  tf_state_bucket_name = "${var.context}-${var.stage}-kubernetes-tfstate"
  providers = {
    opentelekomcloud = opentelekomcloud.top_level_project
  }
}

output "terraform_state_backend_configs" {
  value = module.tf_state_bucket.terraform_state_backend_config
}