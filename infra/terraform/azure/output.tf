output "vm_public_ip" {
  value       = azurerm_public_ip.pip.ip_address
  description = "仮想マシンのパブリックIPアドレス"
}

output "key_vault_name" {
  value       = azurerm_key_vault.kv.name
  description = "作成されたKey Vaultの名前"
}


output "nsg_name" {
  value       = azurerm_network_security_group.nsg.name
  description = "作成されたNSGの名前"
}


output "ssh_command" {
  value       = "ssh -i ../ansible/vm_ssh_key.pem azureuser@${azurerm_public_ip.pip.ip_address}"
  description = "VMにSSH接続するためのコマンド"
  sensitive   = true
}
