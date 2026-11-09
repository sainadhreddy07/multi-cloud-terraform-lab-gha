variable "region" {
  description = "AWS region for the lab."
  type        = string
}

variable "project_name" {
  description = "Short project prefix used in AWS resource names and tags."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet."
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type available in the selected region and account."
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name tag."
  type        = string
}

variable "alb_name" {
  description = "Application Load Balancer name (AWS naming length/character limits apply)."
  type        = string
}

variable "target_group_name" {
  description = "ALB target group name (AWS naming length/character limits apply)."
  type        = string
}

variable "allowed_http_cidr" {
  description = "IPv4 CIDR allowed to reach the public ALB listener, normally 0.0.0.0/0 for this HTTP lab."
  type        = string
}
