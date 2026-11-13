variable "name" { type = string }
variable "network_name" { type = string }
variable "ssh_source_ranges" { type = list(string); default = [] }
