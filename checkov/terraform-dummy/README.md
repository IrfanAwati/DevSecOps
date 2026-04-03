# Azure Base Infrastructure Module

This Terraform module provisions a complete, secure Azure infrastructure with best practices suitable for DevSecOps scanning.

## Resources Included

- **Resource Group**: Logical container for all resources
- **Storage Account**: Secure blob storage with HTTPS enforcement and TLS 1.2
- **Key Vault**: Secure secrets and key management with RBAC
- **Virtual Network**: Custom VNet with subnets
- **Subnet**: Isolated network segment
- **Network Security Group**: Firewall rules for VM access
- **Public IP**: Static IP for VM access
- **Network Interface**: VM network connectivity
- **Linux Virtual Machine**: Managed VM with SSH key auth, premium disk encryption
- **Disk Encryption Set**: Customer-managed key encryption for disks

## How to use

### 1. Clone the repository

```bash
git clone https://github.com/<your-org>/<your-repo>.git
cd DevSecOps/terraform
```

### 2. Copy and configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your values
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Validate and plan

```bash
terraform validate
terraform plan -out=tfplan
```

### 5. Scan with Checkov before deploying

```bash
checkov -d . --framework terraform
```

Review findings and fix any security issues.

### 6. Apply if clean

```bash
terraform apply tfplan
```

## Checkov Compliance

This module is designed to pass Checkov security checks:

- ✅ Managed disks for VMs
- ✅ SSH key authentication (no password)
- ✅ HTTPS-only storage access
- ✅ TLS 1.2 minimum
- ✅ Disk encryption with customer-managed keys
- ✅ Network security groups with minimal permissions
- ✅ Key Vault with RBAC and purge protection

## Module Inputs

See `variables.tf` for all available inputs. Key variables:

- `resource_group_name`: RG name
- `location`: Azure region
- `storage_account_name`: Storage account name (must be unique)
- `key_vault_name`: Key Vault name (must be unique)
- `vm_name`: Virtual Machine name
- `ssh_public_key_path`: Path to SSH public key
- `allowed_ssh_cidr`: CIDR block for SSH access (restrict for security)

## Module Outputs

See `outputs.tf` for exported values:

- Resource IDs
- VM public/private IPs
- Key Vault URI
- Storage account name

## Security Considerations

- Update `allowed_ssh_cidr` from `0.0.0.0/0` to your specific IP
- Ensure SSH key is stored securely
- Regularly rotate Key Vault keys
- Monitor storage account access logs
- Use managed identities for Azure service authentication

## GitHub Workflow

The `.github/workflows/terraform-checkov.yml` workflow:

1. Runs on push/PR to `main` branch (only when `terraform/**` changes)
2. Executes Checkov on all Terraform files
3. Uploads SARIF report for GitHub security scanning
4. Comments PR with results summary
5. Fails if critical security issues found

## Testing locally

```bash
# Format check
terraform fmt -check -recursive

# Full Checkov scan
checkov -d . --framework terraform --output cli

# With specific skip
checkov -d . --framework terraform --skip-check CKV_AZURE_1
```

## Next Steps

1. Customize `terraform.tfvars` with your values
2. Generate or provide SSH key
3. Run Checkov locally to verify
4. Push to GitHub and let the workflow validate
5. Deploy when Checkov passes

## Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Checkov Azure Checks](https://www.checkov.io/)
- [Azure Best Practices](https://docs.microsoft.com/en-us/azure/security/)
