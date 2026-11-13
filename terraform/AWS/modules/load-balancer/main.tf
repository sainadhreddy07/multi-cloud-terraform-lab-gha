resource "aws_lb" "this" {
  name = substr("${var.name}-alb", 0, 32)
  load_balancer_type = "application"
  internal = false
  subnets = var.public_subnet_ids
  security_groups = [var.alb_security_group_id]
}
resource "aws_lb_target_group" "web" {
  name = substr("${var.name}-web-tg", 0, 32)
  port = 80; protocol = "HTTP"; vpc_id = var.vpc_id
  health_check { path = "/"; matcher = "200-399" }
}
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id = var.instance_id
  port = 80
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port = 80; protocol = "HTTP"
  default_action { type = "forward"; target_group_arn = aws_lb_target_group.web.arn }
}
