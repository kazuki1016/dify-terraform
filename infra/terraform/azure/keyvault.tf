# SSHキーとKey Vault
# Key Vault名の一意性を確保するためのランダムIDresource "random_id" "kv_suffix" {  byte_length = 4}# Key Vaultリソース作成 (管理用RG内)
resource "azurerm_key_vault" "kv" {
  name                       = "kv-${var.prefix}-${random_id.kv_suffix.hex}"
  location                   = data.azurerm_resource_group.manage_rg.location
  resource_group_name        = data.azurerm_resource_group.manage_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Terraformを実行するサービスプリンシパル/ユーザーにアクセス権を付与
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }
  tags = local.common_tags
}

# SSHキーペアの生成 (ED25519)
resource "tls_private_key" "ssh" {
algorithm = "ED25519"
}

# SSH公開鍵をKey Vaultにシークレットとして格納
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "vm-ssh-public-key"
  value        = tls_private_key.ssh.public_key_openssh
  key_vault_id = azurerm_key_vault.kv.id
}

# SSH秘密鍵をKey Vaultにシークレットとして格納
resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "vm-ssh-private-key"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id
}

# 生成した秘密鍵をAnsible用にローカルファイルとして保存
resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = "../ansible/vm_ssh_key.pem"
  file_permission = "0600"
}
