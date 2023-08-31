provider "opentelekomcloud" {
  auth_url    = "https://iam.${var.region}.otc.t-systems.com/v3"
  security_token = var.ak_sk_security_token
}