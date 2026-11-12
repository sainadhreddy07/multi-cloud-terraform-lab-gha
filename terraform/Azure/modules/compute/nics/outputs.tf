output "linux_nic_id" { value = azurerm_network_interface.linux.id }
output "linux_private_ip" { value = azurerm_network_interface.linux.private_ip_address }
output "linux_ip_configuration_name" { value = "primary" }
output "windows_nic_id" {
  value = var.create_windows_vm ? azurerm_network_interface.windows[0].id : null
}
