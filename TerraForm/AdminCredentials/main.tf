terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  acr_name           = "kedsouzaacr"
  arc_resource_group = "kedsouza-acr-rg"

  container_app_environment_name                = "managedEnvironment-kedsouzaca-9088"
  container_app_environment_name_resource_group = "kedsouza-ca"
}


data "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = local.arc_resource_group
}


data "azurerm_container_app_environment" "containerapp-env" {
  name                = local.container_app_environment_name
  resource_group_name = local.container_app_environment_name_resource_group
}

resource "azurerm_container_app" "example" {
  name                         = "kedsouza-terra-admin"
  container_app_environment_id = data.azurerm_container_app_environment.containerapp-env.id

  resource_group_name = "kedsouza-ca"
  revision_mode       = "Single"

  secret {
    name  = "registry-password"
    value = data.azurerm_container_registry.acr.admin_password
  }

  registry {
    server               = data.azurerm_container_registry.acr.login_server
    username             = data.azurerm_container_registry.acr.admin_username
    password_secret_name = "registry-password"
  }

  template {
    container {
      name   = "examplecontainerapp"
      image  = "kedsouzaacr.azurecr.io/nginx-test:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}
