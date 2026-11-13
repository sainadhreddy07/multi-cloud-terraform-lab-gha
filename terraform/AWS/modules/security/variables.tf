variable "name" { type = string }
variable "vpc_id" { type = string }

variable "allowed_ssh_cidr" {
  type    = string
  default = null
}
