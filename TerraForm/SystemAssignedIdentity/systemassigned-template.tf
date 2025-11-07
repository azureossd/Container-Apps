terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

// Example: Container App with SystemAssigned identity that pulls from an existing ACR
// Adjust the locals below to match your subscription/resource names
locals {
  resource_group = "resource-group-name"
  location       = "location/region"

  container_app_name       = "container-app-name"
  container_app_env_name   = "container-app-env-name"
  container_app_env_rg     = local.resource_group

  acr_name                 = "acrname"
  acr_resource_group       = "acr-resource-group-name"

  image                    = "acrname.azurecr.io/image:tag"
}

data "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = local.acr_resource_group
}

resource "azurerm_container_app_environment" "env" {
  name                = local.container_app_env_name
  location            = local.location
  resource_group_name = local.container_app_env_rg
}

resource "azurerm_container_app" "app" {
  name                         = local.container_app_name
  resource_group_name          = local.resource_group
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    // for SystemAssigned, container apps will use ACR access via role assignment
    identity = "system"
  }

  template {
    container {
      name   = "main"
      image  = local.image
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    target_port      = 80
    external_enabled = true
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

// Grant AcrPull role to the container app's system-assigned principal
resource "azurerm_role_assignment" "acr_pull" {
  #depends_on = [azurerm_container_app.app]
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.app.identity[0].principal_id
}

output "container_app_principal_id" {
  value = azurerm_container_app.app.identity[0].principal_id
}