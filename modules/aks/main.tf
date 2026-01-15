# modules/aks/main.tf
# Azure Kubernetes Service (AKS) module

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# ============================================================================
# Internal Naming Module
# ============================================================================

module "aks_naming" {
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
# AKS Cluster
# ============================================================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = module.aks_naming.kubernetes_cluster
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.workload}-${var.environment}"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  private_cluster_enabled             = var.private_cluster_enabled
  automatic_upgrade_channel           = var.automatic_channel_upgrade
  role_based_access_control_enabled   = var.role_based_access_control_enabled

  # Default/System Node Pool
  default_node_pool {
    name                = var.system_node_pool_name
    vm_size             = var.system_node_pool_vm_size
    node_count          = var.system_node_pool_node_count
    enable_auto_scaling = true
    min_count           = var.system_node_pool_min_count
    max_count           = var.system_node_pool_max_count
    max_pods            = var.system_node_pool_max_pods
    os_disk_size_gb     = var.system_node_pool_os_disk_size_gb
    vnet_subnet_id      = var.vnet_subnet_id
    zones               = var.system_node_pool_zones

    # Node labels for system node pool
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
    }

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Identity
  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  # Network Profile
  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    load_balancer_sku  = var.load_balancer_sku
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    pod_cidr           = var.pod_cidr
  }

  # Azure AD Integration
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = length(var.admin_group_object_ids) > 0 ? [1] : []

    content {
      managed                = true
      azure_rbac_enabled     = var.azure_rbac_enabled
      admin_group_object_ids = var.admin_group_object_ids
    }
  }

  # OMS Agent (Azure Monitor)
  dynamic "oms_agent" {
    for_each = var.oms_agent_enabled && var.log_analytics_workspace_id != null ? [1] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # HTTP Application Routing
  http_application_routing_enabled = var.enable_http_application_routing

  # Azure Policy
  azure_policy_enabled = var.enable_azure_policy

  # Maintenance Window
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []

    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed

        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }

      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed

        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version
    ]
  }
}

# ============================================================================
# Additional User Node Pools
# ============================================================================

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  enable_auto_scaling   = true
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  vnet_subnet_id        = var.vnet_subnet_id
  zones                 = each.value.zones
  node_labels           = merge(each.value.node_labels, {
    "nodepool-type" = "user"
    "environment"   = var.environment
  })
  node_taints = each.value.node_taints

  upgrade_settings {
    max_surge = "10%"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}

# ============================================================================
# Diagnostic Settings (Optional)
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "aks" {
  count = var.enable_monitoring && var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${module.aks_naming.name}-diag"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
