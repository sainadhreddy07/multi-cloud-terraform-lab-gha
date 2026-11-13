variable "aws_region" { 
    type = string
    default = "us-east-1" 
}

variable "name" { 
    type = string
    default = "nested-lab" 
}

variable "vpc_cidr" { 
    type = string
    default = "10.20.0.0/16" 
}

variable "public_subnet_cidrs" { 
    type = list(string)
    default = ["10.20.1.0/24", "10.20.2.0/24"] 
}

variable "instance_type" { 
    type = string
    default = "t3.micro" 
}

variable "ami_id" { 
    description = "Valid Linux AMI ID in aws_region" 
    type = string 
}

variable "key_name" { 
    description = "Existing EC2 key pair name optional if SSH is disabled" 
    type = string 
    default = null 
}

variable "allowed_ssh_cidr" { 
    description = "Your public IP /32 set null to disable SSH" 
    type = string 
    default = null 
}
