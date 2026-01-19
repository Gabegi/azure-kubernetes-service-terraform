# Naming Module

This module generates Azure resource names following Microsoft Cloud Adoption Framework (CAF) naming conventions.

## Naming Convention

Format: `<resource-type>-<workload>-<environment>-<region>-<instance>`

Example: `aks-myapp-prod-weu-001`

## Usage

```hcl
module "naming" {
  source = "./modules/naming"

  workload    = "myapp"
  environment = "prod"
  location    = "westeurope"
  instance    = "001"
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = module.naming.kubernetes_cluster
  location            = "westeurope"
  resource_group_name = module.naming.resource_group
  # ... other configuration
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| workload | The workload or application name | string | - | yes |
| environment | The environment (dev, test, prod) | string | - | yes |
| location | Azure region | string | - | yes |
| instance | Instance number | string | "001" | no |

## Outputs

All Azure resource types are available as outputs. See `outputs.tf` for the complete list.
