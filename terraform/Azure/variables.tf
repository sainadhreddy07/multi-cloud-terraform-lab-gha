variable "location" {
  description = "Azure region for the lab resources."
  type        = string
}
variable "resource_group_name" {
  description = "Resource group for this Terraform stack."
  type        = string
}
variable "vm_name" {
  description = "Linux VM name."
  type        = string
}
variable "vm_size" {
  description = "Azure VM SKU available in the selected region and subscription."
  type        = string
}
variable "admin_username" {
  description = "Linux VM administrator username."
  type        = string
}
variable "admin_ssh_public_key" {
  description = "OpenSSH public key corresponding to the administrator's private key."
  type        = string
  sensitive   = true
}
variable "vnet_name" {
  description = "Virtual network name."
  type        = string
}
variable "vnet_cidr" {
  description = "Virtual network address space in CIDR notation."
  type        = string
}
variable "subnet_name" {
  description = "Subnet name."
  type        = string
}
variable "subnet_cidr" {
  description = "Subnet address prefix in CIDR notation."
  type        = string
}
variable "nsg_name" {
  description = "Network security group name."
  type        = string
}
variable "nic_name" {
  description = "Network interface name."
  type        = string
}
variable "load_balancer_name" {
  description = "Standard Load Balancer name."
  type        = string
}
variable "load_balancer_public_ip_name" {
  description = "Public IP resource name attached to the Load Balancer frontend."
  type        = string
}

variable "data_disk_count" {
  description = "Number of optional managed data disks to create and attach to Linux VM."
  type        = number
  default     = 0
}
variable "data_disk_size_gb" {
  description = "Size of each optional data disk in GB."
  type        = number
  default     = 10
}
