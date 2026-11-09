output "vpc_id" {
  value = aws_vpc.lab.id
}

output "ec2_instance_id" {
  value = aws_instance.web.id
}

output "ec2_private_ip" {
  value = aws_network_interface.web.private_ip
}

output "ec2_public_ip" {
  value = aws_eip.web.public_ip
}

output "alb_dns_name" {
  value = aws_lb.application.dns_name
}

output "alb_url" {
  value = "http://${aws_lb.application.dns_name}"
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}
