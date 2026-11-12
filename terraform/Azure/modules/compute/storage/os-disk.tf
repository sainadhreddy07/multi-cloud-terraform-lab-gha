# Azure OS disk is a nested block inside azurerm_linux_virtual_machine / azurerm_windows_virtual_machine.
# This module exports its configuration as an object; it does not create a separate OS disk resource.
output "os_disk_settings" {
  value = {
    caching               = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  disk_size_gb           = null
  }
}
