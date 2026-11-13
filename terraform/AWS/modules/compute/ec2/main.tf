resource "aws_instance" "web" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name = var.key_name
  user_data = <<-USERDATA
    #!/bin/bash
    set -eux
    dnf install -y nginx || yum install -y nginx || apt-get update && apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>AWS backend - ${var.name}</h1>" > /usr/share/nginx/html/index.html
  USERDATA
  tags = { Name = "${var.name}-web" }
}
