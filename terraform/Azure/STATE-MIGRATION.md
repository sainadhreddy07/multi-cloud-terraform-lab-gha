# Terraform state migration — important

Moving root resources into child modules changes Terraform addresses. For example:

`azurerm_resource_group.lab` → `module.resource_group.azurerm_resource_group.lab`

If the current deployment already exists, **do not apply a plan that proposes deleting and recreating resources**. First back up state:

```bash
terraform state pull > azure-state-before-module-migration.json
```

Then move existing addresses to their module addresses (run only for resources that already exist in state):

```bash
terraform state mv azurerm_resource_group.lab module.resource_group.azurerm_resource_group.lab
terraform state mv azurerm_virtual_network.lab module.vnet.azurerm_virtual_network.lab
terraform state mv azurerm_subnet.web module.subnet.azurerm_subnet.web
terraform state mv azurerm_network_security_group.web module.nsg.azurerm_network_security_group.web
terraform state mv azurerm_network_interface.web module.nics.azurerm_network_interface.linux
terraform state mv azurerm_network_interface_security_group_association.web module.nsg.azurerm_network_interface_security_group_association.linux
terraform state mv azurerm_public_ip.lb module.load_balancer.azurerm_public_ip.lb
terraform state mv azurerm_lb.public module.load_balancer.azurerm_lb.public
terraform state mv azurerm_lb_backend_address_pool.web module.load_balancer.azurerm_lb_backend_address_pool.web
terraform state mv azurerm_network_interface_backend_address_pool_association.web module.load_balancer.azurerm_network_interface_backend_address_pool_association.linux
terraform state mv azurerm_lb_probe.http module.load_balancer.azurerm_lb_probe.http
terraform state mv azurerm_lb_rule.http module.load_balancer.azurerm_lb_rule.http
terraform state mv azurerm_lb_outbound_rule.web_egress module.load_balancer.azurerm_lb_outbound_rule.web_egress
terraform state mv azurerm_linux_virtual_machine.web module.vms.azurerm_linux_virtual_machine.linux
```

Then:

```bash
terraform plan
```

Review carefully. The commands assume resource names in this package and the original root resources exist in state. If the old state differs, adapt the source addresses. Never run `state mv` blindly against a different workspace/state.
