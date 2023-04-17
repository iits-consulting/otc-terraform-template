provider "opentelekomcloud" {
  cloud = "${var.os_domain_name}_${var.region}_${var.context}"
}

provider "opentelekomcloud" {
  cloud = "${var.os_domain_name}_${var.region}"
  alias       = "top_level_project"
}