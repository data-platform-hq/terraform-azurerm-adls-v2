terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.1.1"
    }
  }
}
