# service_principal.tf

data "azurerm_subscription" "current" {}

# Azure AD Application
resource "azuread_application" "github_actions" {
  display_name = "github-actions-${local.workload}-${local.environment}"
}

# Service Principal
resource "azuread_service_principal" "github_actions" {
  client_id = azuread_application.github_actions.client_id
}

# Service Principal Password
resource "azuread_service_principal_password" "github_actions" {
  service_principal_id = azuread_service_principal.github_actions.id
  end_date_relative    = "8760h" # 1 year
}

# Grant permissions to Resource Group
resource "azurerm_role_assignment" "github_rg" {
  scope                = module.resource_group.rg_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Grant permissions to ACR
resource "azurerm_role_assignment" "github_acr" {
  scope                = module.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Grant read access to Key Vault secrets
resource "azurerm_role_assignment" "github_kv" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Store GitHub Actions credentials in Key Vault
resource "azurerm_key_vault_secret" "github_credentials" {
  name         = "github-actions-credentials"
  key_vault_id = azurerm_key_vault.main.id

  value = jsonencode({
    clientId       = azuread_application.github_actions.client_id
    clientSecret   = azuread_service_principal_password.github_actions.value
    subscriptionId = data.azurerm_subscription.current.subscription_id
    tenantId       = data.azurerm_subscription.current.tenant_id
  })

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

# Store ACR name
resource "azurerm_key_vault_secret" "acr_name" {
  name         = "acr-name"
  key_vault_id = azurerm_key_vault.main.id
  value        = module.acr.name

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

# Store AKS cluster name
resource "azurerm_key_vault_secret" "aks_cluster_name" {
  name         = "aks-cluster-name"
  key_vault_id = azurerm_key_vault.main.id
  value        = module.aks.name

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}
