# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }

  }

  required_version = ">= 1.1.0"
  # backend "azurerm" {
  #   resource_group_name  = var.resource_group_name
  #   storage_account_name = "backendstorage2022"
  #   container_name       = "state"
  #   key                  = "prod.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name_stage
  location = var.location
}
