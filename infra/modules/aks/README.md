# AKS Module

## Purpose

This Terraform module is designed to provision and manage Azure Kubernetes Service (AKS) clusters in the East US region using Infrastructure as Code principles. It automates the deployment of production-ready Kubernetes clusters with enterprise-grade configuration, eliminating manual setup and ensuring consistent, repeatable deployments.

## Overview

This module creates an Azure Kubernetes Service (AKS) cluster with enterprise-grade configuration for East US region.

## Features

- **Managed Kubernetes**: Fully managed AKS cluster with automatic upgrades
- **High Availability**: Multi-zone deployment across availability zones
- **Auto-scaling**: Cluster autoscaler for system and user node pools
- **Azure CNI Networking**: Advanced networking with VNet integration
- **Network Policies**: Azure or Calico network policy support
- **Monitoring**: Azure Monitor integration with Log Analytics
- **RBAC**: Azure AD integration with role-based access control
- **Security**: Private cluster support, managed identity
- **Diagnostics**: Comprehensive logging for control plane components

## Usage Example

```hcl
module "aks_cluster" {
  source = "./modules/aks"

  # Naming
  workload    = "myapp"
  environment = "prod"
  location    = "eastus"
  instance    = "001"

  # Resource Group
  resource_group_name = azurerm_resource_group.aks.name

  # Cluster Configuration
  kubernetes_version = "1.28"
  sku_tier          = "Standard"

  # System Node Pool
  system_node_pool_vm_size    = "Standard_D4s_v3"
  system_node_pool_node_count = 3
  system_node_pool_min_count  = 3
  system_node_pool_max_count  = 6

  # Additional User Node Pools
  user_node_pools = {
    workload = {
      vm_size         = "Standard_D8s_v3"
      node_count      = 2
      min_count       = 2
      max_count       = 10
      max_pods        = 50
      os_disk_size_gb = 256
      zones           = ["1", "2", "3"]
      node_labels = {
        workload = "application"
      }
      node_taints = []
    }
  }

  # Networking
  vnet_subnet_id   = azurerm_subnet.aks.id
  network_plugin   = "azure"
  network_policy   = "azure"
  service_cidr     = "10.0.0.0/16"
  dns_service_ip   = "10.0.0.10"

  # Monitoring
  enable_monitoring          = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  # Tags
  common_tags = {
    Project     = "MyProject"
    CostCenter  = "Engineering"
  }
}
```

## Node Pool Configuration

### System Node Pool
- Dedicated for system pods (CoreDNS, metrics-server, etc.)
- Always deployed across availability zones for HA
- Auto-scaling enabled by default

### User Node Pools
- For application workloads
- Supports custom labels and taints
- Can be scaled independently

## Network Configuration

### Azure CNI (Recommended)
- Each pod gets an IP from the VNet subnet
- Better performance and security
- Requires adequate IP address space

### Kubenet
- Pods use private IP space (10.244.0.0/16)
- More IP address efficient
- Limited network policy support

## Monitoring & Diagnostics

The module enables comprehensive monitoring:
- **Control Plane Logs**: API server, scheduler, controller manager
- **Audit Logs**: Kubernetes audit events
- **Metrics**: Cluster and node metrics
- **Container Insights**: Container-level monitoring

## Security Features

- **Managed Identity**: No stored credentials
- **RBAC**: Kubernetes and Azure RBAC support
- **Network Policies**: Control pod-to-pod traffic
- **Private Cluster**: API server accessible only via private network
- **Azure Policy**: Enforce organizational standards

## Region Configuration

This module is configured for **East US** by default with:
- Location: `eastus`
- Availability Zones: 1, 2, 3
- Location abbreviation: `eus`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| workload | Workload or application name | string | - | yes |
| environment | Environment (dev/staging/prod) | string | - | yes |
| location | Azure region | string | eastus | no |
| resource_group_name | Resource group name | string | - | yes |
| vnet_subnet_id | Subnet ID for AKS nodes | string | - | yes |
| kubernetes_version | Kubernetes version | string | 1.28 | no |

See [variables.tf](./variables.tf) for all available inputs.

## Outputs

| Name | Description |
|------|-------------|
| id | AKS cluster ID |
| name | AKS cluster name |
| fqdn | AKS cluster FQDN |
| kube_config | Kubernetes configuration (sensitive) |
| identity_principal_id | Managed identity principal ID |
| portal_url | Azure Portal URL |

See [outputs.tf](./outputs.tf) for all available outputs.

## Requirements

- Terraform >= 1.0
- Azure Provider >= 3.0
- Valid Azure subscription
- VNet with adequate IP space for Azure CNI

## Cost Optimization

- Use `Free` SKU tier for dev/test environments
- Use `Standard_B` series VMs for non-production
- Enable cluster autoscaler to scale down during off-hours
- Consider spot instances for fault-tolerant workloads

## Best Practices

1. **Use Standard SKU**: For production workloads
2. **Enable Auto-scaling**: On all node pools
3. **Deploy Multi-zone**: For high availability
4. **Use Azure CNI**: For better networking performance
5. **Enable Monitoring**: Essential for troubleshooting
6. **Regular Updates**: Keep Kubernetes version current
7. **Resource Limits**: Set CPU/memory limits on pods
8. **Network Policies**: Control traffic between pods

## Maintenance

The module supports automatic upgrades:
- `patch`: Automatically updates to latest patch version
- `stable`: Updates to latest stable minor version
- `rapid`: Updates to latest release quickly
- `node-image`: Only updates node images

## License

MIT
