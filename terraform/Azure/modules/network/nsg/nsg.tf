resource "azurerm_network_security_group" "web" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-http-from-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-azure-load-balancer-probes"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "linux" {
  network_interface_id      = var.linux_nic_id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_network_interface_security_group_association" "windows" {
  network_interface_id      = var.windows_nic_id
  network_security_group_id = azurerm_network_security_group.web.id
}
