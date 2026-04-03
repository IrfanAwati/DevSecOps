output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_private_ip" {
  description = "Private IP of the virtual machine"
  value       = azurerm_network_interface.main.private_ip_address
}

output "vm_public_ip" {
  description = "Public IP of the virtual machine"
  value       = azurerm_public_ip.main.ip_address
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.main.id
}

output "disk_encryption_set_id" {
  description = "ID of the disk encryption set"
  value       = azurerm_disk_encryption_set.main.id
}
