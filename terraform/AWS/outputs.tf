output "alb_dns_name" { value = module.load_balancer.dns_name }
output "http_url" { value = "http://${module.load_balancer.dns_name}" }
output "ec2_instance_id" { value = module.compute.instance_id }
