resource "azurerm_public_ip" "lb" {
  name                = var.load_balancer_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
