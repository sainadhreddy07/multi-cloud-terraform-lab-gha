output "linux_vm_name" { value = azurerm_linux_virtual_machine.linux.name }
output "linux_vm_id" { value = azurerm_linux_virtual_machine.linux.id }
output "windows_vm_name" {
  value = azurerm_windows_virtual_machine.windows.name
}
