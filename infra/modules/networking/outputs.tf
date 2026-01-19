# modules/networking/outputs.tf

# ============================================================================
# VNet Outputs
# ============================================================================

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.vnet.address_space
}

# ============================================================================
# Subnet Outputs
# ============================================================================

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "subnet_names" {
  description = "Map of subnet keys to their full names"
  value       = { for k, v in azurerm_subnet.subnet : k => v.name }
}
