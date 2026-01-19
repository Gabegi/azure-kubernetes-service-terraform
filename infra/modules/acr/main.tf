# modules/acr/main.tf
# Azure Container Registry module

# ============================================================================
# Internal Naming Module
# ============================================================================

module "acr_naming" {
  source = "../naming"

  workload    = var.workload
  environment = var.environment
  location    = var.location
  instance    = var.instance
}

# ============================================================================
# Tags
# ============================================================================

locals {
  default_tags = {
    Environment = var.environment
    Workload    = var.workload
    ManagedBy   = "Terraform"
    Location    = var.location
  }

  tags = merge(local.default_tags, var.common_tags)
}

# ============================================================================
# Azure Container Registry
# ============================================================================

resource "azurerm_container_registry" "acr" {
  name                = module.acr_naming.container_registry # ACR names must be alphanumeric only
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  tags = local.tags
}
