# Leading underscore so this prints first (outputs are listed alphabetically).
output "_security_warning" {
  description = "Security disclaimer for the workshop-only plaintext outputs."
  value       = "SECURITY HACK — WORKSHOP ONLY! THE PASSWORD BELOW IS PRINTED IN PLAINTEXT FOR CONVENIENCE. NORMALLY SENSITIVE VALUES MUST NOT BE OUTPUTTED."
}

output "admin_dashboard_url" {
  description = "URL of the admin dashboard."
  value       = "https://admin.${var.domain_name}"
}

output "admin_dashboard_username" {
  description = "Username for the admin dashboard basic auth."
  value       = "admin"
}

# **SECURITY HACK — WORKSHOP ONLY!**
# **THIS OUTPUTS A SENSITIVE VALUE IN PLAINTEXT FOR CONVENIENCE DURING THE**
# **WORKSHOP. NORMALLY SENSITIVE VALUES MUST NOT BE OUTPUTTED. IN A REAL**
# **SETUP MARK THIS OUTPUT `sensitive = true` (OR DO NOT OUTPUT IT AT ALL).**
output "admin_dashboard_password" {
  description = "Password for the admin dashboard basic auth."
  value       = var.admin_website_password
}

output "argocd_url" {
  description = "URL of the ArgoCD UI (user: admin)."
  value       = "https://admin.${var.domain_name}/argocd"
}

# Tofu sets the ArgoCD admin password to the same value as the dashboard password,
# so there is only one login to remember.
output "argocd_credentials" {
  description = "Login for the ArgoCD UI."
  value       = "user: admin, password: same as admin_dashboard_password"
}
