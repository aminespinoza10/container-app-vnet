terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.10"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}