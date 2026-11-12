resource "azurerm_lb_rule" "http" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.public.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
}

# Explicit outbound rule lets the private Linux VM reach the Internet for apt/Nginx setup.
resource "azurerm_lb_outbound_rule" "web_egress" {
  name                     = "web-egress"
  loadbalancer_id          = azurerm_lb.public.id
  protocol                 = "All"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.web.id
  allocated_outbound_ports = 1024

  frontend_ip_configuration {
    name = "public-frontend"
  }
}
