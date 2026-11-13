resource "azurerm_windows_virtual_machine" "windows" {
  count = var.create_windows_vm ? 1 : 0

  name          = var.windows_vm_name
  computer_name = substr(var.windows_vm_name, 0, 15)

  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.windows_vm_size

  admin_username = var.windows_admin_username
  admin_password = var.windows_admin_password

  network_interface_ids = [var.windows_nic_id]

  os_disk {
    name                 = "${var.windows_vm_name}-osdisk"
    caching              = var.os_disk_settings.caching
    storage_account_type = var.os_disk_settings.storage_account_type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "win_data" {
  count = var.create_windows_vm ? length(var.data_disk_ids) : 0

  managed_disk_id    = var.data_disk_ids[count.index]
  virtual_machine_id = azurerm_windows_virtual_machine.windows[0].id
  lun                = count.index
  caching            = "ReadWrite"
}
