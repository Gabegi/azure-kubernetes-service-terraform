# Tagging Module

This module generates a standard set of tags based on Microsoft Azure tagging best practices.

## Tag Strategy

Following Microsoft's recommended tags:
- **Environment**: Deployment environment (dev, test, prod)
- **Workload**: Application or workload name
- **Owner**: Owner or contact information
- **ManagedBy**: Always set to "Terraform"
- **Criticality**: Business criticality level
- **DataClassification**: Data sensitivity level
- **CostCenter**: Cost allocation (optional)

## Usage

```hcl
module "tagging" {
  source = "./modules/tagging"

  workload            = "myapp"
  environment         = "prod"
  owner               = "platform-team@company.com"
  cost_center         = "IT-12345"
  criticality         = "High"
  data_classification = "Confidential"

  additional_tags = {
    Project = "AKS Migration"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-prod-weu-001"
  location = "westeurope"
  tags     = module.tagging.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| workload | Workload or application name | string | - | yes |
| environment | Environment name | string | - | yes |
| owner | Owner or contact email | string | - | yes |
| cost_center | Cost center or department | string | "" | no |
| criticality | Business criticality | string | "Medium" | no |
| data_classification | Data classification level | string | "Internal" | no |
| additional_tags | Additional custom tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| tags | Map of all tags to apply to resources |
