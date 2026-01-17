# basic-aks-cluster.tf
# Deploys a simple AKS cluster in East US using our modules

# ============================================================================
# Local Variables
# ============================================================================

locals {
  workload    = "demo"
  environment = "dev"
  location    = "eastus"
  instance    = "001"

  common_tags = {
    Project   = "SimpleAKS"
    Owner     = "Platform Team"
    ManagedBy = "Terraform"
  }
}

# ============================================================================
# Resource Group
# ============================================================================

module "resource_group" {
  source = "./modules/resource-group"

  workload    = local.workload
  environment = local.environment
  location    = local.location
  instance    = local.instance
  common_tags = local.common_tags
}

# ============================================================================
# Networking (VNet + Subnet)
# ============================================================================

module "networking" {
  source = "./modules/networking"

  workload            = local.workload
  environment         = local.environment
  location            = local.location
  instance            = local.instance
  resource_group_name = module.resource_group.rg_name
  common_tags         = local.common_tags

  vnet_address_space = ["10.0.0.0/16"]

  subnets = {
    aks = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

# ============================================================================
# Log Analytics Workspace (for monitoring)
# ============================================================================

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "log-${local.workload}-${local.environment}-eus-${local.instance}"
  location            = local.location
  resource_group_name = module.resource_group.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

# ============================================================================
# AKS Cluster
# ============================================================================

module "aks" {
  source = "./modules/aks"

  workload            = local.workload
  environment         = local.environment
  location            = local.location
  instance            = local.instance
  resource_group_name = module.resource_group.rg_name
  common_tags         = local.common_tags

  # Cluster config
  # kubernetes_version not set - Azure will use default supported version
  sku_tier = "Free" # Use "Standard" for production

  # System node pool
  system_node_pool_name       = "system"
  system_node_pool_vm_size    = "Standard_D2s_v3"
  system_node_pool_node_count = 3
  system_node_pool_min_count  = 3
  system_node_pool_max_count  = 5
  system_node_pool_zones      = ["1"]

  # Networking
  vnet_subnet_id = module.networking.subnet_ids["aks"]
  network_plugin = "azure"
  network_policy = "azure"
  service_cidr   = "10.1.0.0/16"
  dns_service_ip = "10.1.0.10"

  # Monitoring
  enable_monitoring          = true
  oms_agent_enabled          = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  # Keep it simple - no Azure AD integration for dev
  admin_group_object_ids = []
}

# ============================================================================
# Outputs
# ============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.rg_name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.fqdn
}

