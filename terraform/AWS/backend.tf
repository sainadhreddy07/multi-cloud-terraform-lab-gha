terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.72.0"
    }
  }

  backend "s3" {
    bucket = "multicloudbucket001"
    key    = "multi-cloud-terraform-lab-gha/aws/terraform.tfstate"
    region = "ap-south-1"

    encrypt      = true
    use_lockfile = true
  }
}