# acr.tf

module "acr" {
  source = "./modules/acr"

  workload            = local.workload
  environment         = local.environment
  location            = local.location
  instance            = local.instance
  resource_group_name = local.rg_name
  common_tags         = local.common_tags

  sku           = "Basic"
  admin_enabled = false
}

# Allow AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = module.aks.kubelet_identity.object_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.id
  skip_service_principal_aad_check = true
}

# Outputs
output "acr_name" {
  description = "ACR name"
  value       = module.acr.name
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = module.acr.login_server
}
