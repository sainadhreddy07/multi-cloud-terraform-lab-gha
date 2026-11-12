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

# Optional Windows expansion; defaults keep the current Linux-only lab unchanged.
variable "create_windows_vm" {
  description = "Enable the optional Windows VM/NIC example."
  type        = bool
  default     = false
}
variable "windows_vm_name" {
  description = "Name of optional Windows VM."
  type        = string
  default     = "vm-windows-lab"
}
variable "windows_vm_size" {
  description = "SKU for optional Windows VM."
  type        = string
  default     = "Standard_B2s"
}
variable "windows_admin_username" {
  description = "Administrator username for optional Windows VM."
  type        = string
  default     = "azureadmin"
}
variable "windows_admin_password" {
  description = "Administrator password for optional Windows VM (supply via secret TF_VAR)."
  type        = string
  sensitive   = true
  default     = null
}
variable "windows_nic_name" {
  description = "NIC name for optional Windows VM."
  type        = string
  default     = "nic-windows-lab"
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
