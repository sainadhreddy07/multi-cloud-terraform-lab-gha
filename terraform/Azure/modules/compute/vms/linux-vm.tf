resource "azurerm_linux_virtual_machine" "linux" {
  name          = var.vm_name
  computer_name = substr(var.vm_name, 0, 15)

  resource_group_name = var.resource_group_name

  location = var.location
  size     = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [var.linux_nic_id]

  custom_data = base64encode(<<-CUSTOMDATA
    #!/bin/bash
    set -eux
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    printf '%s\n' '<h1>Azure backend - ${var.vm_name}</h1>' > /var/www/html/index.html
  CUSTOMDATA
  )

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(var.admin_ssh_public_key)
  }

  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = var.os_disk_settings.caching
    storage_account_type = var.os_disk_settings.storage_account_type
    disk_size_gb         = var.os_disk_settings.disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}


# Optional data-disk attachments. The disks are created by modules/compute/storage/data-disks.tf.
resource "azurerm_virtual_machine_data_disk_attachment" "linux_data" {
  count              = length(var.data_disk_ids)
  managed_disk_id    = var.data_disk_ids[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.linux.id
  lun                = count.index
  caching            = "ReadWrite"
}
