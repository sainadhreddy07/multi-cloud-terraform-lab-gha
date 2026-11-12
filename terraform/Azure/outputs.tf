output "resource_group_name" {
  value = module.resource_group.name
}
output "vm_name" {
  value = module.vms.linux_vm_name
}
output "vm_private_ip" {
  value = module.nics.linux_private_ip
}
output "load_balancer_public_ip" {
  value = module.load_balancer.public_ip
}
output "load_balancer_url" {
  value = "http://${module.load_balancer.public_ip}"
}
output "windows_vm_name" {
  value       = module.vms.windows_vm_name
  description = "Null unless create_windows_vm is enabled."
}
