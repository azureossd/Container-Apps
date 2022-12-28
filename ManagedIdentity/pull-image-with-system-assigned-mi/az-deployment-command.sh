# The below command can be ran to deploy this example

# This first commands sets up our structure and the role assignment for System Assigned Managed Identity
# This also sets it to a public image
# The next command changes the public image to point to our ACR and pull with System Assigned Managed Identity
# Per documentation, this is the current practice: https://learn.microsoft.com/en-us/azure/container-apps/managed-identity-image-pull?tabs=azure-cli&pivots=command-line#system-assigned-managed-identity-1
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file ./set-image-with-system-assigned-mi.bicep \
  --parameters \
  environmentName="$CONTAINERAPPS_ENVIRONMENT" \
  containerAppName="$CONTAINERAPPS_NAME" \
  azureContainerRegistry="$AZURE_CONTAINER_REGISTRY" \
  acrPullDefinitionId="$ACR_PULL_DEFINITION_ID" \
  appInsightsName="$AZURE_APP_INSIGHTS_NAME" \
  logAnalyticsWorkspaceName="$AZURE_LAW_NAME" &&
  az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file ./pull-image-with-system-assigned-mi.bicep \
    --parameters \
    environmentName="$CONTAINERAPPS_ENVIRONMENT" \
    containerAppName="$CONTAINERAPPS_NAME" \
    azureContainerRegistry="$AZURE_CONTAINER_REGISTRY" \
    azureContainerRegistryImage="$AZURE_CONTAINER_REGISTRY_IMAGE" \
    azureContainerRegistryImageTag="$AZURE_CONTAINER_REGISTRY_IMAGE_TAG" \
    appInsightsName="$AZURE_APP_INSIGHTS_NAME" \
    logAnalyticsWorkspaceName="$AZURE_LAW_NAME" 

