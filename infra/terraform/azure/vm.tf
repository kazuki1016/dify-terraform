# パブリックIPアドレス
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  location            = data.azurerm_resource_group.app_rg.location
  resource_group_name = data.azurerm_resource_group.app_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}
# ネットワークインターフェース (NIC)
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.app_rg.location
  resource_group_name = data.azurerm_resource_group.app_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  tags = local.common_tags
}

# 仮想マシン (Linux)
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.prefix
  resource_group_name = data.azurerm_resource_group.app_rg.name
  location            = data.azurerm_resource_group.app_rg.location
  size                = "Standard_D2s_v3"
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}

# Ansibleインベントリファイルを生成
resource "null_resource" "generate_inventory" {
 triggers = {
    vm_public_ip = azurerm_public_ip.pip.ip_address
  }
  provisioner "local-exec" {
    command = <<EOF
      echo "[azure_vms]" > ../ansible/hosts.ini
      echo "${azurerm_public_ip.pip.ip_address} ansible_user=${azurerm_linux_virtual_machine.vm.admin_username} ansible_ssh_private_key_file=./vm_ssh_key.pem" >> ../ansible/hosts.ini
    EOF
  }

  depends_on = [
    azurerm_linux_virtual_machine.vm,
    local_file.private_key_pem
  ]
}
