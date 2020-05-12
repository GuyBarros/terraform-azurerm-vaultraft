# terraform-azurerm-vaultraft
a really simple Terraform module to create a Vault cluster in Azure which uses the Integrated storage backend and Azure KeyVault for auto unseal.

this should be used for demo purposes only, it is nowhere near production ready.

### Architecture Overview
ToDo

### Terraform Variables

```bash
subscription_id = "AZURE_SUBSCRIPTION_ID"
tenant_id = "AZURE_TENANT_ID"
client_id = "AZURE_CLIENT_ID"
client_secret = "AZURE_CLIENT_PASSWORD"
admin_username = "guyser"
admin_password = "Sup3rS3cureP4ssw0rd"
hostname = "vaultraft"
location = "ukwest"
owner = "guybarros"
resource_group = "vaultraft"
servers = "3"
enterprise      = true
vaultlicense    = ""
vault_ent_url   = "https://releases.hashicorp.com/vault/1.4.0+ent/vault_1.4.0+ent_linux_amd64.zip"
vault_url       = "https://releases.hashicorp.com/vault/1.4.0/vault_1.4.0_linux_amd64.zip"

```
### Terraform Outputs

the Terraform code outputs the SSH command to the different nodes and the the AWG link to access Vault.

```bash

Outputs:

leader = ssh guyser@vaultraft-leader.ukwest.cloudapp.azure.com
servers = [
  "ssh guyser@vaultraft-servers-0.ukwest.cloudapp.azure.com",
  "ssh guyser@vaultraft-servers-1.ukwest.cloudapp.azure.com",
  "ssh guyser@vaultraft-servers-2.ukwest.cloudapp.azure.com",
]
```

---