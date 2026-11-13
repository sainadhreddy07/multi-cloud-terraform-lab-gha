module "network" {
  source      = "./modules/network"
  name        = var.name
  subnet_cidr = var.subnet_cidr
  region      = var.region
}
module "firewall" {
  source            = "./modules/firewall"
  name              = var.name
  network_name      = module.network.network_name
  ssh_source_ranges = var.ssh_source_ranges
}
module "compute" {
  source           = "./modules/compute/vm"
  name             = var.name
  project_id       = var.project_id
  zone             = var.zone
  machine_type     = var.machine_type
  subnet_self_link = module.network.subnet_self_link
  network_name     = module.network.network_name
}
module "load_balancer" {
  source        = "./modules/load-balancer"
  name          = var.name
  project_id    = var.project_id
  region        = var.region
  zone          = var.zone
  network_name  = module.network.network_name
  instance_name = module.compute.instance_name
}
