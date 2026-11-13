variable "project_id" { type = string }

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "name" {
  type    = string
  default = "nested-lab"
}

variable "network_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.30.1.0/24"
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "ssh_source_ranges" {
  type    = list(string)
  default = []
}
