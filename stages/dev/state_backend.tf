terraform {
  required_version = "1.10.2"

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.36"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    errorcheck = {
      source  = "iits-consulting/errorcheck"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

provider "opentelekomcloud" {
  auth_url       = "https://iam.${var.region}.otc.t-systems.com/v3"
  tenant_name    = var.region
  security_token = var.ak_sk_security_token
}

module "state_bucket" {
  source               = "iits-consulting/state-bucket/opentelekomcloud"
  version              = "7.4.5"
  tf_state_bucket_name = "${var.context}-${var.stage}-tfstate"
}

output "terraform_state_backend_config" {
  value = <<EOT
Place the following state backend configuration in the section marked with \"TODO Add backend config S3 here\" in files:
${yamlencode(formatlist("stages/${var.stage}/%s", fileset(path.root, "*/settings.tf")))}

##### STATE BACKEND CONFIGURATION #####
    backend "s3" {
      bucket                      = "$${var.context}-$${var.stage}-tfstate"
      key                         = "tfstate-$${split("_", basename(abspath(path.module)))[1]}"
      region                      = var.region
      endpoints = {
        s3 = "https://obs.$${var.region}.otc.t-systems.com"
      }
      skip_region_validation      = true
      skip_credentials_validation = true
      skip_requesting_account_id  = true
      skip_s3_checksum            = true
    }
  EOT
}
