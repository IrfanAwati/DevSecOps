# Checkov Rules & Remediation Guide

This file documents common Checkov findings and how to fix them—perfect for beginners learning to resolve IaC issues.

## Terraform Examples (Azure)

### CKV_AZURE_1: Ensure that Virtual Machines use managed disks

**Problem:** VM uses unmanaged disks, increasing security and management overhead.

**❌ Bad:**
```hcl
resource "azurerm_instance" "example" {
  name                  = "example-vm"
  location              = "East US"
  resource_group_name   = azurerm_resource_group.example.name
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name          = "osdisk"
    vhd_uri       = "https://mystorageacct.blob.core.windows.net/vhds/osdisk.vhd"  # ❌ Unmanaged
    create_option = "FromImage"
  }
  # ❌ No managed disk
}
```

**✅ Good:**
```hcl
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  location            = "East US"
  resource_group_name = azurerm_resource_group.example.name
  vm_size             = "Standard_B2s"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"  # ✅ Managed disk with encryption
  }

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
```

### CKV_AZURE_2: Ensure that Virtual Machines use SSH keys for authentication

**Problem:** VM uses password authentication (weaker than SSH keys).

**❌ Bad:**
```hcl
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  location            = "East US"
  resource_group_name = azurerm_resource_group.example.name
  vm_size             = "Standard_B2s"

  admin_username = "azureuser"
  admin_password = "P@ssw0rd1234!"  # ❌ Password authentication
  disable_password_authentication = false
}
```

**✅ Good:**
```hcl
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  location            = "East US"
  resource_group_name = azurerm_resource_group.example.name
  vm_size             = "Standard_B2s"

  admin_username = "azureuser"
  disable_password_authentication = true  # ✅ SSH keys only

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")  # ✅ SSH key-based auth
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
```

### CKV_AZURE_3: Ensure that Storage Accounts use HTTPS

**Problem:** Storage Account allows unencrypted HTTP access.

**❌ Bad:**
```hcl
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  # ❌ No https_traffic_only setting, defaults to allow HTTP
}
```

**✅ Good:**
```hcl
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  https_traffic_only_enabled = true  # ✅ Enforce HTTPS

  identity {
    type = "SystemAssigned"
  }
}
```

### CKV_AZURE_36: Ensure that Storage Account uses a minimum TLS version

**Problem:** Storage Account allows old TLS versions (vulnerable).

**❌ Bad:**
```hcl
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  https_traffic_only_enabled = true
  # ❌ No min_tls_version, defaults to TLS 1.0
}
```

**✅ Good:**
```hcl
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  https_traffic_only_enabled = true
  min_tls_version          = "TLS1_2"  # ✅ TLS 1.2 minimum
}
```

### CKV_AZURE_33: Ensure Storage Account Encryption Key Version is Rotated

**Problem:** Storage Account uses outdated encryption keys.

**❌ Bad:**
```hcl
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  # ❌ No customer-managed key rotation policy
}
```

**✅ Good:**
```hcl
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  https_traffic_only_enabled = true
  min_tls_version          = "TLS1_2"

  customer_managed_key {
    key_vault_key_id = azurerm_key_vault_key.example.id
  }
}

resource "azurerm_key_vault_key" "example" {
  name            = "storagekey"
  key_vault_id    = azurerm_key_vault.example.id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["sign", "verify", "wrapKey", "unwrapKey"]  # ✅ Rotation enabled
}
```

---

## Kubernetes Examples

### CKV_K8S_8: Liveness probe not set

**Problem:** Pod has no liveness probe, so failed containers are not restarted.

**❌ Bad:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    # ❌ No liveness probe
```

**✅ Good:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
```

### CKV_K8S_9: Readiness probe not set

**Problem:** Pod has no readiness probe; traffic may route to unhealthy instances.

**❌ Bad:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    # ❌ No readiness probe
```

**✅ Good:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
```

### CKV_K8S_20: Containers should run as non-root user

**Problem:** Container runs as root, allowing privilege escalation.

**❌ Bad:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    # ❌ No securityContext, runs as root
```

**✅ Good:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      allowPrivilegeEscalation: false
```

### CKV_K8S_21: CPU limits should be set

**Problem:** No CPU limits; pod can starve other pods.

**❌ Bad:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    # ❌ No resources limits
```

**✅ Good:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

---

## Azure Resource Manager (ARM) Template Examples

### Ensure that SQL Server has Transparent Data Encryption (TDE) enabled

**Problem:** SQL Server database is unencrypted.

**❌ Bad:**
```json
{
  "type": "Microsoft.Sql/servers/databases",
  "apiVersion": "2019-06-01-preview",
  "name": "[concat(parameters('serverName'), '/myDatabase')]",
  "location": "[parameters('location')]",
  "properties": {
    "collation": "SQL_Latin1_General_CP1_CI_AS",
    "edition": "Standard"
  }
}
```

**✅ Good:**
```json
{
  "type": "Microsoft.Sql/servers/databases",
  "apiVersion": "2019-06-01-preview",
  "name": "[concat(parameters('serverName'), '/myDatabase')]",
  "location": "[parameters('location')]",
  "properties": {
    "collation": "SQL_Latin1_General_CP1_CI_AS",
    "edition": "Standard"
  }
},
{
  "type": "Microsoft.Sql/servers/databases/transparentDataEncryption",
  "apiVersion": "2017-03-01-preview",
  "name": "[concat(parameters('serverName'), '/myDatabase/current')]",
  "properties": {
    "status": "Enabled"
  },
  "dependsOn": [
    "[resourceId('Microsoft.Sql/servers/databases', parameters('serverName'), 'myDatabase')]"
  ]
}
```

### Ensure Application Gateway has HTTP listener redirected to HTTPS

**Problem:** App Gateway allows unencrypted HTTP traffic.

**❌ Bad:**
```json
{
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2020-05-01",
  "name": "myAppGateway",
  "properties": {
    "httpListeners": [
      {
        "name": "http-listener",
        "properties": {
          "frontendIPConfiguration": { "id": "[variables('frontendIPid')]" },
          "frontendPort": { "id": "[variables('httpPortId')]" },
          "protocol": "Http"
        }
      }
    ]
  }
}
```

**✅ Good:**
```json
{
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2020-05-01",
  "name": "myAppGateway",
  "properties": {
    "httpListeners": [
      {
        "name": "http-listener",
        "properties": {
          "frontendIPConfiguration": { "id": "[variables('frontendIPid')]" },
          "frontendPort": { "id": "[variables('httpPortId')]" },
          "protocol": "Http"
        }
      }
    ],
    "redirectConfigurations": [
      {
        "name": "http-to-https-redirect",
        "properties": {
          "redirectType": "Permanent",
          "targetListener": {
            "id": "[variables('httpsListenerId')]"
          },
          "pathIncludeQueryString": true
        }
      }
    ]
  }
}
```

---

## Quick Fix Strategy

1. Run Checkov and capture failing checks:
   ```bash
   checkov -d . --framework terraform,kubernetes
   ```

2. Note the rule ID (e.g., `CKV_AZURE_1`), file, and line number.

3. Search in this doc or [Checkov docs](https://www.checkov.io/) for the rule.

4. Apply the recommended fix pattern shown above.

5. Re-run Checkov to verify fix:
   ```bash
   checkov -d . --framework terraform,kubernetes
   ```

6. Commit and push.

---

## Suppressing false positives

If a check is a valid false positive for your context, suppress it:

**Terraform:**
```hcl
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "East US"

  # checkov:skip=CKV_AZURE_3:Storage account intentionally allows HTTP for internal traffic
}
```

**Kubernetes:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  annotations:
    checkov.io/skip1: "CKV_K8S_20=Pod runs in private network with network policies"
spec:
  # ...
```

---

## Resources

- [Checkov Rules](https://www.checkov.io/)
- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
