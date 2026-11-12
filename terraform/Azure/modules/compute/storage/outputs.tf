output "os_disk_settings" {
  value = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = null
  }
}
output "data_disk_ids" {
  value = azurerm_managed_disk.data[*].id
}
