module "network" {
  source = "./modules/network"
  name   = var.name
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "security" {
  source = "./modules/security"
  name   = var.name
  vpc_id = module.network.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "compute" {
  source = "./modules/compute/ec2"
  name = var.name
  ami_id = var.ami_id
  instance_type = var.instance_type
  subnet_id = module.network.public_subnet_ids[0]
  security_group_id = module.security.instance_sg_id
  key_name = var.key_name
}

module "load_balancer" {
  source = "./modules/load-balancer"
  name = var.name
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_sg_id
  instance_id = module.compute.instance_id
}
