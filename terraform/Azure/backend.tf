terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 5.13.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-shared"
    storage_account_name = "multicloudstorage001"
    container_name       = "tfstate"
    key                  = "multi-cloud-terraform-lab-gha/azure.tfstate"
    use_oidc             = false # Backend uses ARM_SAS_TOKEN; AzureRM provider uses OIDC separately.
  }
}
