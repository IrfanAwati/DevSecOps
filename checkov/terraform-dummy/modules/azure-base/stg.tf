resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}