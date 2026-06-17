output "admin_dashboard_url" {
  description = "URL of the admin dashboard."
  value       = "https://admin.${var.domain_name}"
}

output "admin_dashboard_username" {
  description = "Username for the admin dashboard basic auth."
  value       = "admin"
}

output "admin_dashboard_password" {
  description = "Password for the admin dashboard basic auth."
  value       = var.admin_website_password
}

output "argocd_url" {
  description = "URL of the ArgoCD UI (user: admin)."
  value       = "https://admin.${var.domain_name}/argocd"
}

# ArgoCD generates its initial admin password at boot and stores it in a
# cluster secret. Run this command to read it (user: admin).
output "argocd_password_command" {
  description = "Command to fetch the initial ArgoCD admin password (user: admin)."
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
