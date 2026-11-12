resource "azurerm_lb_probe" "http" {
  name                = "http-health-probe"
  loadbalancer_id     = azurerm_lb.public.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}
