# modules/aks/main.tf
# Azure Kubernetes Service (AKS) module for East US region
# Provisions a production-ready managed Kubernetes cluster

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
# Generates consistent resource names following Azure naming conventions
# ============================================================================

module "aks_naming" {
  source = "../naming"

  workload    = var.workload    # Application/workload identifier
  environment = var.environment # dev, staging, prod, etc.
  location    = var.location    # Azure region (eastus)
  instance    = var.instance    # Instance number for multiple clusters
}

# ============================================================================
# Tags
# Standard tags applied to all resources for cost tracking and organization
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
# Main Kubernetes cluster resource with control plane configuration
# ============================================================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = module.aks_naming.kubernetes_cluster # Cluster name from naming module
  location            = var.location                         # Azure region (eastus)
  resource_group_name = var.resource_group_name              # Resource group to deploy into
  dns_prefix          = "${var.workload}-${var.environment}" # DNS prefix for cluster FQDN
  kubernetes_version  = var.kubernetes_version               # K8s version (e.g., 1.28)
  sku_tier            = var.sku_tier                         # Free, Standard, or Premium

  # Security & Access Settings
  private_cluster_enabled           = var.private_cluster_enabled           # If true, API server is private only
  automatic_upgrade_channel         = var.automatic_channel_upgrade         # Auto-upgrade: patch, stable, rapid, node-image
  role_based_access_control_enabled = var.role_based_access_control_enabled # Enable Kubernetes RBAC

  # ---------------------------------------------------------------------------
  # System Node Pool (Default)
  # Runs critical system pods: CoreDNS, metrics-server, kube-proxy, etc.
  # Always keep this pool dedicated to system workloads
  # ---------------------------------------------------------------------------
  default_node_pool {
    name                = var.system_node_pool_name       # Pool name (max 12 chars)
    vm_size             = var.system_node_pool_vm_size    # VM size (e.g., Standard_D4s_v3)
    node_count          = var.system_node_pool_node_count # Initial node count
    enable_auto_scaling = true                            # Enable cluster autoscaler
    min_count           = var.system_node_pool_min_count  # Minimum nodes when scaling down
    max_count           = var.system_node_pool_max_count  # Maximum nodes when scaling up
    max_pods            = var.system_node_pool_max_pods   # Max pods per node (Azure CNI limit)
    os_disk_size_gb     = var.system_node_pool_os_disk_size_gb # OS disk size
    vnet_subnet_id      = var.vnet_subnet_id              # Subnet for node IPs
    zones               = var.system_node_pool_zones      # Availability zones for HA

    # Labels to identify system nodes for scheduling
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
    }

    # Rolling upgrade settings - max 10% of nodes upgraded at once
    upgrade_settings {
      max_surge = "10%"
    }
  }

  # ---------------------------------------------------------------------------
  # Managed Identity
  # Used by AKS to manage Azure resources (load balancers, disks, etc.)
  # SystemAssigned = Azure manages the identity automatically
  # ---------------------------------------------------------------------------
  identity {
    type         = var.identity_type # SystemAssigned or UserAssigned
    identity_ids = var.identity_ids  # Required if UserAssigned
  }

  # ---------------------------------------------------------------------------
  # Network Configuration
  # Defines how pods and services communicate
  # ---------------------------------------------------------------------------
  network_profile {
    network_plugin    = var.network_plugin    # azure (CNI) or kubenet
    network_policy    = var.network_policy    # azure or calico for pod network policies
    load_balancer_sku = var.load_balancer_sku # standard or basic
    service_cidr      = var.service_cidr      # IP range for K8s services
    dns_service_ip    = var.dns_service_ip    # IP for kube-dns (must be in service_cidr)
    pod_cidr          = var.pod_cidr          # Pod IP range (only for kubenet)
  }

  # ---------------------------------------------------------------------------
  # Azure AD Integration (Optional)
  # Enables Azure AD users/groups to access the cluster via kubectl
  # Only created if admin_group_object_ids is provided
  # ---------------------------------------------------------------------------
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = length(var.admin_group_object_ids) > 0 ? [1] : []

    content {
      azure_rbac_enabled     = var.azure_rbac_enabled     # Use Azure RBAC for K8s authz
      admin_group_object_ids = var.admin_group_object_ids # AAD groups with admin access
    }
  }

  # ---------------------------------------------------------------------------
  # Azure Monitor Integration (Optional)
  # Enables Container Insights for monitoring pods, nodes, and containers
  # Requires Log Analytics workspace
  # ---------------------------------------------------------------------------
  dynamic "oms_agent" {
    for_each = var.oms_agent_enabled && var.log_analytics_workspace_id != null ? [1] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Add-ons
  http_application_routing_enabled = var.enable_http_application_routing # Dev/test ingress (not for prod)
  azure_policy_enabled             = var.enable_azure_policy             # Enforce policies on cluster

  # ---------------------------------------------------------------------------
  # Maintenance Window (Optional)
  # Define when Azure can perform automatic maintenance on the cluster
  # ---------------------------------------------------------------------------
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []

    content {
      # Days/hours when maintenance is allowed
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed

        content {
          day   = allowed.value.day   # Day of week
          hours = allowed.value.hours # Hours (0-23)
        }
      }

      # Blackout periods when maintenance is blocked
      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed

        content {
          start = not_allowed.value.start # Start datetime
          end   = not_allowed.value.end   # End datetime
        }
      }
    }
  }

  tags = local.tags

  # Ignore changes that are managed externally (autoscaler, manual upgrades)
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count, # Managed by autoscaler
      kubernetes_version               # Managed by auto-upgrade
    ]
  }
}

# ============================================================================
# User Node Pools (Optional)
# Additional node pools for application workloads
# Separate from system pool to isolate app traffic and enable independent scaling
# ============================================================================

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.user_node_pools # Create one pool per map entry

  name                  = each.key                         # Pool name from map key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size               # VM size for this pool
  node_count            = each.value.node_count            # Initial node count
  enable_auto_scaling   = true                             # Enable autoscaler
  min_count             = each.value.min_count             # Min nodes
  max_count             = each.value.max_count             # Max nodes
  max_pods              = each.value.max_pods              # Max pods per node
  os_disk_size_gb       = each.value.os_disk_size_gb       # OS disk size
  vnet_subnet_id        = var.vnet_subnet_id               # Same subnet as system pool
  zones                 = each.value.zones                 # Availability zones

  # Merge custom labels with standard labels
  node_labels = merge(each.value.node_labels, {
    "nodepool-type" = "user"
    "environment"   = var.environment
  })

  # Taints to control pod scheduling (e.g., dedicated pools)
  node_taints = each.value.node_taints

  upgrade_settings {
    max_surge = "10%"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      node_count # Managed by autoscaler
    ]
  }
}

# ============================================================================
# Diagnostic Settings (Optional)
# Sends control plane logs to Log Analytics for troubleshooting
# Critical for debugging cluster issues and security auditing
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "aks" {
  count = var.enable_monitoring && var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${module.aks_naming.kubernetes_cluster}-diag"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # API Server logs - requests to the Kubernetes API
  enabled_log {
    category = "kube-apiserver"
  }

  # Audit logs - who did what and when (security)
  enabled_log {
    category = "kube-audit"
  }

  # Controller Manager logs - replication controllers, endpoints, etc.
  enabled_log {
    category = "kube-controller-manager"
  }

  # Scheduler logs - pod scheduling decisions
  enabled_log {
    category = "kube-scheduler"
  }

  # Autoscaler logs - scale up/down events
  enabled_log {
    category = "cluster-autoscaler"
  }

  # Collect all metrics for dashboards and alerts
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
