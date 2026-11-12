output "data_disk_ids" {
  value = azurerm_managed_disk.data[*].id
}
