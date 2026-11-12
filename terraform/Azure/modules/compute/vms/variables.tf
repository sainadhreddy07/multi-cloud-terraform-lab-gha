variable "vm_name" { type = string }
variable "vm_size" { type = string }
variable "admin_username" { type = string }

variable "admin_ssh_public_key" {
  type      = string
  sensitive = true
}

variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "linux_nic_id" { type = string }

variable "os_disk_settings" {
  type = object({
    caching              = string
    storage_account_type = string
    disk_size_gb         = number
  })
}

variable "windows_nic_id" { type = string }
variable "create_windows_vm" { type = bool }
variable "windows_vm_name" { type = string }
variable "windows_vm_size" { type = string }

variable "windows_admin_username" {
  description = "Temporary Windows VM administrator username"
  type        = string
  sensitive   = true
  default     = "azdmoduser"
}

variable "windows_admin_password" {
  description = "Temporary Windows VM administrator password"
  type        = string
  sensitive   = true
  default     = "LabWin@2026Test"
}

variable "data_disk_ids" {
  type    = list(string)
  default = []
}
