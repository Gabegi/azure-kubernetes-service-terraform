# modules/networking/main.tf
# Networking module - VNet and Subnets for East US

# ============================================================================
# Internal Naming Module
# ============================================================================

module "networking_naming" {
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
# Virtual Network
# ============================================================================

resource "azurerm_virtual_network" "vnet" {
  name                = module.networking_naming.virtual_network
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = local.tags
}

# ============================================================================
# Subnets
# ============================================================================

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = "${module.networking_naming.subnet}-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}
