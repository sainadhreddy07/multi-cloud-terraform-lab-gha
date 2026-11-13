# Configure S3 backend only after bootstrap bucket exists.
# Uncomment and fill values before terraform init.
terraform {
  backend "s3" {
    bucket = "multicloudbucket001"
    key    = "multi-cloud-terraform-lab-gha/aws/terraform.tfstate"
    region = "ap-south-1"

    encrypt      = true
    use_lockfile = true
  }
}
