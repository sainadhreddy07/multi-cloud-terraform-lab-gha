terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 8.9.0"
    }
  }

  backend "gcs" {
    bucket = "mc-infra-gcp-tfstate-001"
    prefix = "multi-cloud-terraform-lab-gha/gcp"
  }
}