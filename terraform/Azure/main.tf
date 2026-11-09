resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "lab" {
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "web" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_network_security_group" "web" {
  name                = var.nsg_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

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

resource "azurerm_network_interface" "web" {
  name                = var.nic_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "web" {
  network_interface_id      = azurerm_network_interface.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_public_ip" "lb" {
  name                = var.load_balancer_public_ip_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "public" {
  name                = var.load_balancer_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  name            = "web-backend-pool"
  loadbalancer_id = azurerm_lb.public.id
}

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  network_interface_id    = azurerm_network_interface.web.id
  ip_configuration_name   = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
}

resource "azurerm_lb_probe" "http" {
  name                = "http-health-probe"
  loadbalancer_id     = azurerm_lb.public.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

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

# The explicit outbound rule gives the private VM outbound internet access
# for package installation without assigning the VM its own public IP.
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

resource "azurerm_linux_virtual_machine" "web" {
  name                            = var.vm_name
  computer_name                   = substr(var.vm_name, 0, 15)
  resource_group_name             = azurerm_resource_group.lab.name
  location                        = azurerm_resource_group.lab.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.web.id]
  custom_data = base64encode(<<-CUSTOMDATA
    #!/bin/bash
    set -eux
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    printf '%s\n' '<h1>Azure backend - ${var.vm_name}</h1>' > /var/www/html/index.html
  CUSTOMDATA
  )

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(var.admin_ssh_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface_security_group_association.web,
    azurerm_network_interface_backend_address_pool_association.web,
    azurerm_lb_outbound_rule.web_egress
  ]
}
