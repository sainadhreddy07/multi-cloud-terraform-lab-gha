data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.common_tags, { Name = "${var.project_name}-vpc" })
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, { Name = "${var.project_name}-public-a" })
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, { Name = "${var.project_name}-public-b" })
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id
  tags   = merge(local.common_tags, { Name = "${var.project_name}-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-public-rt" })
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP from configured client CIDRs to the Application Load Balancer."
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "HTTP listener"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_http_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-alb-sg" })
}

resource "aws_security_group" "vm" {
  name        = "${var.project_name}-vm-sg"
  description = "Allow HTTP to the EC2 target only from the ALB security group."
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-vm-sg" })
}

resource "aws_network_interface" "web" {
  subnet_id       = aws_subnet.public_1.id
  security_groups = [aws_security_group.vm.id]
  description     = "Primary ENI for the lab EC2 instance."
  tags            = merge(local.common_tags, { Name = "${var.project_name}-eni" })
}

resource "aws_instance" "web" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.web.id
    device_index         = 0
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = <<-USERDATA
    #!/bin/bash
    set -eux
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
    printf '%s\n' '<h1>AWS backend - ${var.instance_name}</h1>' > /usr/share/nginx/html/index.html
  USERDATA

  tags = merge(local.common_tags, { Name = var.instance_name })
}

# A dedicated IPv4 address is included for the requested VM public-IP resource.
# The EC2 security group still accepts HTTP only from the ALB security group.
resource "aws_eip" "web" {
  domain     = "vpc"
  tags       = merge(local.common_tags, { Name = "${var.project_name}-vm-eip" })
  depends_on = [aws_internet_gateway.lab]
}

resource "aws_eip_association" "web" {
  allocation_id        = aws_eip.web.id
  network_interface_id = aws_network_interface.web.id
}

resource "aws_lb" "application" {
  name                       = var.alb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  drop_invalid_header_fields = true
  tags                       = merge(local.common_tags, { Name = var.alb_name })

  depends_on = [
    aws_route_table_association.public_1,
    aws_route_table_association.public_2
  ]
}

resource "aws_lb_target_group" "web" {
  name        = var.target_group_name
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.lab.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(local.common_tags, { Name = var.target_group_name })
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
