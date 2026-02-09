# resource-group.tf
# Use existing resource group instead of creating it

data "azurerm_resource_group" "main" {
  name = "rg-${local.workload}-${local.environment}-eus-${local.instance}"
}

# Create locals that mimic the module outputs for backward compatibility
locals {
  rg_id       = data.azurerm_resource_group.main.id
  rg_name     = data.azurerm_resource_group.main.name
  rg_location = data.azurerm_resource_group.main.location
}
