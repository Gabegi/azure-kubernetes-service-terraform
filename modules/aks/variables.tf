# modules/aks/variables.tf

# ============================================================================
# Naming Variables (for internal naming module)
# ============================================================================

variable "workload" {
  type        = string
  description = "Workload or application name"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., 'dev', 'prod', 'staging')"
}

variable "location" {
  type        = string
  description = "Azure region for the AKS cluster"
  default     = "eastus"
}

variable "instance" {
  type        = string
  description = "Instance number (e.g., '001', '002')"
  default     = "001"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to merge with module-generated tags"
  default     = {}
}

# ============================================================================
# Resource Group
# ============================================================================

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for AKS cluster"
}

# ============================================================================
# AKS Cluster Configuration
# ============================================================================

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the cluster"
  default     = "1.28"
}

variable "sku_tier" {
  type        = string
  description = "SKU tier for the AKS cluster (Free, Standard, Premium)"
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be Free, Standard, or Premium"
  }
}

variable "private_cluster_enabled" {
  type        = bool
  description = "Enable private cluster (API server accessible only via private network)"
  default     = false
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "Automatic upgrade channel (patch, stable, rapid, node-image, none)"
  default     = "stable"

  validation {
    condition     = contains(["patch", "stable", "rapid", "node-image", "none"], var.automatic_channel_upgrade)
    error_message = "Must be one of: patch, stable, rapid, node-image, none"
  }
}

# ============================================================================
# System Node Pool Configuration
# ============================================================================

variable "system_node_pool_name" {
  type        = string
  description = "Name of the system node pool"
  default     = "system"
}

variable "system_node_pool_vm_size" {
  type        = string
  description = "VM size for system node pool"
  default     = "Standard_D4s_v3"
}

variable "system_node_pool_node_count" {
  type        = number
  description = "Initial number of nodes in system node pool"
  default     = 3
}

variable "system_node_pool_min_count" {
  type        = number
  description = "Minimum number of nodes for autoscaling"
  default     = 3
}

variable "system_node_pool_max_count" {
  type        = number
  description = "Maximum number of nodes for autoscaling"
  default     = 6
}

variable "system_node_pool_max_pods" {
  type        = number
  description = "Maximum number of pods per node"
  default     = 30
}

variable "system_node_pool_os_disk_size_gb" {
  type        = number
  description = "OS disk size in GB"
  default     = 128
}

variable "system_node_pool_zones" {
  type        = list(string)
  description = "Availability zones for system node pool"
  default     = ["1", "2", "3"]
}

# ============================================================================
# User Node Pools
# ============================================================================

variable "user_node_pools" {
  type = map(object({
    vm_size            = string
    node_count         = number
    min_count          = number
    max_count          = number
    max_pods           = number
    os_disk_size_gb    = number
    zones              = list(string)
    node_labels        = map(string)
    node_taints        = list(string)
  }))
  description = "Configuration for additional user node pools"
  default     = {}
}

# ============================================================================
# Networking
# ============================================================================

variable "vnet_subnet_id" {
  type        = string
  description = "Subnet ID for AKS nodes"
}

variable "network_plugin" {
  type        = string
  description = "Network plugin (azure or kubenet)"
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be azure or kubenet"
  }
}

variable "network_policy" {
  type        = string
  description = "Network policy (azure, calico, or null)"
  default     = "azure"
}

variable "service_cidr" {
  type        = string
  description = "CIDR for Kubernetes services"
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  type        = string
  description = "IP address for Kubernetes DNS service"
  default     = "10.0.0.10"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR for pods (only for kubenet)"
  default     = null
}

variable "load_balancer_sku" {
  type        = string
  description = "SKU for load balancer (basic or standard)"
  default     = "standard"

  validation {
    condition     = contains(["basic", "standard"], var.load_balancer_sku)
    error_message = "Load balancer SKU must be basic or standard"
  }
}

# ============================================================================
# Identity & RBAC
# ============================================================================

variable "identity_type" {
  type        = string
  description = "Identity type (SystemAssigned or UserAssigned)"
  default     = "SystemAssigned"
}

variable "identity_ids" {
  type        = list(string)
  description = "User assigned identity IDs (required if identity_type is UserAssigned)"
  default     = null
}

variable "role_based_access_control_enabled" {
  type        = bool
  description = "Enable Kubernetes RBAC"
  default     = true
}

variable "azure_rbac_enabled" {
  type        = bool
  description = "Enable Azure RBAC for Kubernetes authorization"
  default     = false
}

variable "admin_group_object_ids" {
  type        = list(string)
  description = "Azure AD group object IDs for cluster admin access"
  default     = []
}

# ============================================================================
# Monitoring & Logging
# ============================================================================

variable "enable_monitoring" {
  type        = bool
  description = "Enable Azure Monitor for containers"
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for monitoring"
  default     = null
}

variable "oms_agent_enabled" {
  type        = bool
  description = "Enable OMS agent for monitoring"
  default     = true
}

# ============================================================================
# Add-ons
# ============================================================================

variable "enable_http_application_routing" {
  type        = bool
  description = "Enable HTTP application routing add-on"
  default     = false
}

variable "enable_azure_policy" {
  type        = bool
  description = "Enable Azure Policy add-on"
  default     = false
}

variable "enable_kube_dashboard" {
  type        = bool
  description = "Enable Kubernetes dashboard (deprecated)"
  default     = false
}

# ============================================================================
# Maintenance Window
# ============================================================================

variable "maintenance_window" {
  type = object({
    allowed = list(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = list(object({
      start = string
      end   = string
    }))
  })
  description = "Maintenance window configuration"
  default     = null
}
