# Configure GCS backend after bucket bootstrap.
# Uncomment and replace bucket name before terraform init.
terraform {
  backend "gcs" {
    bucket = "mc-infra-gcp-tfstate-001"
    prefix = "multi-cloud-terraform-lab-gha/gcp"
  }
}
