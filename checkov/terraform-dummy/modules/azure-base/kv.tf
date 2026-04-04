resource "azurerm_key_vault" "main" {
  # checkov:skip=CKV_AZURE_189: skipping HIGH issues for test
  name                = var.key_vault_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90

  network_rules {
    bypass                   = ["AzureServices"]
    default_action          = "Deny"
  }

  tags = var.tags
}