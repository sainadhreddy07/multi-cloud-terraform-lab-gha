
module "resource_group" {
  source              = "./modules/resources"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "vnet" {
  source              = "./modules/network/vnet"
  vnet_name           = var.vnet_name
  vnet_cidr           = var.vnet_cidr
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

module "subnet" {
  source              = "./modules/network/subnet"
  subnet_name         = var.subnet_name
  subnet_cidr         = var.subnet_cidr
  resource_group_name = module.resource_group.name
  vnet_name           = module.vnet.name
}

module "nics" {
  source              = "./modules/compute/nics"
  nic_name            = var.nic_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.subnet.id
}

module "nsg" {
  source              = "./modules/network/nsg"
  nsg_name            = var.nsg_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  linux_nic_id        = module.nics.linux_nic_id
}

module "os_disk" {
  source = "./modules/compute/storage"
}

module "data_disks" {
  source              = "./modules/compute/storage"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vm_name             = var.vm_name
  data_disk_count     = var.data_disk_count
  data_disk_size_gb   = var.data_disk_size_gb
  create_data_disks   = true
}

module "load_balancer" {
  source                          = "./modules/load-balancer"
  resource_group_name             = module.resource_group.name
  location                        = module.resource_group.location
  load_balancer_name              = var.load_balancer_name
  load_balancer_public_ip_name    = var.load_balancer_public_ip_name
  linux_nic_id                    = module.nics.linux_nic_id
  linux_nic_ip_configuration_name = module.nics.linux_ip_configuration_name
}


module "vms" {
  source = "./modules/compute/vms"

  vm_name              = var.vm_name
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  linux_nic_id     = module.nics.linux_nic_id
  os_disk_settings = module.os_disk.os_disk_settings
  data_disk_ids    = module.data_disks.data_disk_ids

  depends_on = [
    module.nsg,
    module.load_balancer
  ]
}

