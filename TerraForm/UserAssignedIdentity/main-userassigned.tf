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

  user_assigned_identity_name           = "kedsouza-ca-usi-5"
  user_assigned_identity_resource_group = "kedsouza-ca"
  user_assigned_identity_name_location  = "centralus"

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

# Creating the UserAssignedManagedIdentity
resource "azurerm_user_assigned_identity" "managedidentity" {
  name                = local.user_assigned_identity_name
  resource_group_name = local.user_assigned_identity_resource_group
  location            = local.user_assigned_identity_name_location
}

# Adding the role assigment for the user assiged managed identity.
resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
}

resource "azurerm_container_app" "example" {
  depends_on = [azurerm_user_assigned_identity.managedidentity, azurerm_role_assignment.example]

  name                         = "kedsouza-terra-user-5"
  container_app_environment_id = data.azurerm_container_app_environment.containerapp-env.id

  resource_group_name = "kedsouza-ca"
  revision_mode       = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managedidentity.id]
  }


  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.managedidentity.id
  }

  ingress {
    target_port      = 80
    external_enabled = true
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {

    container {
      name   = "examplecontainerapp"
      image  = "kedsouzaacr.azurecr.io/nginx:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}
