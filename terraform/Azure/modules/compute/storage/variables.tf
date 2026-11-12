variable "resource_group_name" {
  type    = string
  default = null
}
variable "location" {
  type    = string
  default = null
}
variable "vm_name" {
  type    = string
  default = "vm-lab"
}
variable "data_disk_count" {
  type    = number
  default = 0
}
variable "data_disk_size_gb" {
  type    = number
  default = 10
}
variable "create_data_disks" {
  type    = bool
  default = false
}
variable "linux_vm_id" {
  type    = string
  default = null
}
