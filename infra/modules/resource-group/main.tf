# modules/resource-group/main.tf
# Resource Group module - Azure resource container

# ============================================================================
# Internal Naming Module
# ============================================================================

module "rg_naming" {
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
# Resource Group
# ============================================================================

resource "azurerm_resource_group" "rg" {
  name     = module.rg_naming.resource_group
  location = var.location
  tags     = local.tags

  # Prevent accidental deletion in production
  lifecycle {
    prevent_destroy = false # Set to true for production
    ignore_changes = [tags]
  }
}

# # Optional: Apply resource lock to prevent deletion
resource "azurerm_management_lock" "rg_lock" {
  count = var.enable_resource_lock ? 1 : 0

  name       = "${module.rg_naming.resource_group}-lock"
  scope      = azurerm_resource_group.rg.id
  lock_level = var.lock_level # CanNotDelete or ReadOnly
  notes      = var.lock_notes

  depends_on = [azurerm_resource_group.rg]
}
