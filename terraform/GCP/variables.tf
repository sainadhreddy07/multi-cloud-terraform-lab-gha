variable "project_id" {
  description = "Existing Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "GCP region for regional network resources."
  type        = string
}

variable "zone" {
  description = "GCP zone for the VM and unmanaged instance group."
  type        = string
}

variable "vm_name" {
  description = "Compute Engine VM name."
  type        = string
}

variable "machine_type" {
  description = "Compute Engine machine type available in the selected zone."
  type        = string
}

variable "vpc_name" {
  description = "VPC network name."
  type        = string
}

variable "subnet_name" {
  description = "Subnet name."
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR range."
  type        = string
}

variable "firewall_name" {
  description = "Firewall rule name used for backend HTTP and health-check traffic."
  type        = string
}

variable "load_balancer_name" {
  description = "Prefix for the global external Application Load Balancer resources."
  type        = string
}
