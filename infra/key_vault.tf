# key_vault.tf

data "azurerm_client_config" "current" {}

# Key Vault with RBAC
resource "azurerm_key_vault" "main" {
  name                      = "kv-${local.workload}-${local.environment}-${local.instance}"
  location                  = local.location
  resource_group_name       = module.resource_group.rg_name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
  purge_protection_enabled  = true

  tags = local.common_tags
}

# Grant yourself permission to manage secrets
resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Store ACR name in Key Vault
resource "azurerm_key_vault_secret" "acr_name" {
  name         = "acr-name"
  value        = module.acr.name
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

# Output
output "key_vault_name" {
  value = azurerm_key_vault.main.name
}
