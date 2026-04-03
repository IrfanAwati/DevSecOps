terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50"
    }
  }
}

provider "azurerm" {
  features {}
}

module "azure_base" {
  source = "./modules/azure-base"

  resource_group_name = "devsecops-rg"
  location            = "East US"

  storage_account_name             = "devsecopssts${random_id.storage.hex}"
  storage_account_tier             = "Standard"
  storage_account_replication_type = "GRS"

  key_vault_name             = "devsecops-kv-${random_id.keyvault.hex}"
  key_vault_key_name         = "vm-disk-encryption-key"
  disk_encryption_set_name   = "devsecops-des"

  virtual_network_name = "devsecops-vnet"
  address_space        = ["10.0.0.0/16"]

  subnet_name                = "devsecops-subnet"
  subnet_address_prefixes    = ["10.0.1.0/24"]

  nsg_name       = "devsecops-nsg"
  nic_name       = "devsecops-nic"
  public_ip_name = "devsecops-pip"

  vm_name              = "devsecops-vm"
  vm_size              = "Standard_B2s"
  admin_username       = "azureuser"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  allowed_ssh_cidr     = "0.0.0.0/0"  # Change to your IP

  tags = {
    Environment = "dev"
    Project     = "DevSecOps"
    Managed     = "Terraform"
  }
}

# Random IDs for unique names
resource "random_id" "storage" {
  byte_length = 4
}

resource "random_id" "keyvault" {
  byte_length = 4
}

# Outputs
output "resource_group_name" {
  value = module.azure_base.resource_group_name
}

output "vm_public_ip" {
  value = module.azure_base.vm_public_ip
}

output "key_vault_uri" {
  value = module.azure_base.key_vault_uri
}
