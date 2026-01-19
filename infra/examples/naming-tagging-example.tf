# Example usage of naming and tagging modules

module "naming" {
  source = "../modules/naming"

  workload    = "myapp"
  environment = "prod"
  location    = "westeurope"
  instance    = "001"
}

module "tagging" {
  source = "../modules/tagging"

  workload            = "myapp"
  environment         = "prod"
  owner               = "platform-team@company.com"
  cost_center         = "IT-12345"
  criticality         = "High"
  data_classification = "Confidential"

  additional_tags = {
    Project = "AKS Migration"
    Version = "1.0"
  }
}

# Example outputs
output "example_resource_group_name" {
  value = module.naming.resource_group
}

output "example_aks_name" {
  value = module.naming.kubernetes_cluster
}

output "example_tags" {
  value = module.tagging.tags
}

# Example resource using both modules
# resource "azurerm_resource_group" "example" {
#   name     = module.naming.resource_group
#   location = "westeurope"
#   tags     = module.tagging.tags
# }
