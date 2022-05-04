#!/bin/bash

az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file ./managed-identity.bicep \
  --parameters \
    environment_name="$CONTAINERAPPS_ENVIRONMENT" \
    location="$LOCATION" \
    azureContainerRegistry="$AZURE_CONTAINER_REGISTRY" \
    azureContainerRegistryUsername="$AZURE_CONTAINER_REGISTRY_USERNAME" \
    azureContainerRegistryPassword="$AZURE_CONTAINER_REGISTRY_PASSWORD" \
    keyVaultName="$KEY_VAULT_NAME" \
    secretName="$SECRET_NAME"