# modules/aks/outputs.tf

# ============================================================================
# AKS Cluster Outputs
# ============================================================================

output "id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "fqdn" {
  description = "AKS cluster FQDN"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "private_fqdn" {
  description = "AKS cluster private FQDN"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = azurerm_kubernetes_cluster.aks.kubernetes_version
}

# ============================================================================
# Kube Config
# ============================================================================

output "kube_config" {
  description = "Raw Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_admin_config" {
  description = "Raw Kubernetes admin configuration"
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive   = true
}

output "client_certificate" {
  description = "Base64 encoded client certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Base64 encoded client key"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "Kubernetes API server endpoint"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive   = true
}

# ============================================================================
# Identity
# ============================================================================

output "identity_principal_id" {
  description = "Principal ID of the system assigned identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "Tenant ID of the system assigned identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
}

output "kubelet_identity" {
  description = "Kubelet identity object"
  value = {
    client_id                 = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
    object_id                 = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].user_assigned_identity_id
  }
}

# ============================================================================
# Network
# ============================================================================

output "node_resource_group" {
  description = "Auto-generated resource group for AKS resources"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "network_profile" {
  description = "Network profile configuration"
  value = {
    network_plugin    = azurerm_kubernetes_cluster.aks.network_profile[0].network_plugin
    network_policy    = azurerm_kubernetes_cluster.aks.network_profile[0].network_policy
    service_cidr      = azurerm_kubernetes_cluster.aks.network_profile[0].service_cidr
    dns_service_ip    = azurerm_kubernetes_cluster.aks.network_profile[0].dns_service_ip
    load_balancer_sku = azurerm_kubernetes_cluster.aks.network_profile[0].load_balancer_sku
  }
}

# ============================================================================
# Tags
# ============================================================================

output "tags" {
  description = "Tags applied to the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.tags
}

# ============================================================================
# Node Pools
# ============================================================================

output "system_node_pool" {
  description = "System node pool configuration"
  value = {
    name       = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
    vm_size    = azurerm_kubernetes_cluster.aks.default_node_pool[0].vm_size
    node_count = azurerm_kubernetes_cluster.aks.default_node_pool[0].node_count
    min_count  = azurerm_kubernetes_cluster.aks.default_node_pool[0].min_count
    max_count  = azurerm_kubernetes_cluster.aks.default_node_pool[0].max_count
  }
}

output "user_node_pools" {
  description = "User node pools configuration"
  value = {
    for k, v in azurerm_kubernetes_cluster_node_pool.user : k => {
      id         = v.id
      name       = v.name
      vm_size    = v.vm_size
      node_count = v.node_count
      min_count  = v.min_count
      max_count  = v.max_count
    }
  }
}

# ============================================================================
# Portal URL
# ============================================================================

output "portal_url" {
  description = "Azure Portal URL for the AKS cluster"
  value       = "https://portal.azure.com/#resource${azurerm_kubernetes_cluster.aks.id}"
}

# ============================================================================
# AGIC / Application Gateway
# ============================================================================

output "ingress_application_gateway" {
  description = "AGIC add-on details"
  value = var.enable_ingress_application_gateway ? {
    effective_gateway_id = try(azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].effective_gateway_id, null)
    ingress_application_gateway_identity = try(azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity, null)
  } : null
}
