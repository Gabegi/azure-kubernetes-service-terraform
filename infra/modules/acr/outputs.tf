# modules/acr/outputs.tf

output "id" {
  description = "ACR resource ID"
  value       = azurerm_container_registry.acr.id
}

output "name" {
  description = "ACR name"
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "ACR admin username (if admin enabled)"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
}

output "admin_password" {
  description = "ACR admin password (if admin enabled)"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  sensitive   = true
}
