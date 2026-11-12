output "public_ip" { value = azurerm_public_ip.lb.ip_address }
output "public_ip_id" { value = azurerm_public_ip.lb.id }
output "load_balancer_id" { value = azurerm_lb.public.id }
output "backend_pool_id" { value = azurerm_lb_backend_address_pool.web.id }
