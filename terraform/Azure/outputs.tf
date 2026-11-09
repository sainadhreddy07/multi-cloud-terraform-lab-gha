output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.web.name
}

output "vm_private_ip" {
  value = azurerm_network_interface.web.private_ip_address
}

output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "load_balancer_url" {
  value = "http://${azurerm_public_ip.lb.ip_address}"
}
