resource "azurerm_managed_disk" "data" {
  count                = var.create_data_disks ? var.data_disk_count : 0
  name                 = "${var.vm_name}-data-${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
}
