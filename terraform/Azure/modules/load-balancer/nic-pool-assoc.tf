resource "azurerm_network_interface_backend_address_pool_association" "linux" {
  network_interface_id    = var.linux_nic_id
  ip_configuration_name   = var.linux_nic_ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
}
