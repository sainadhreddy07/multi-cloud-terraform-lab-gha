output "vm_name" { value = module.compute.instance_name }
output "vm_internal_ip" { value = module.compute.internal_ip }
output "http_url" { value = module.load_balancer.http_url }
