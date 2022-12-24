# The below command can be ran to deploy this example

az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file ./pull-image-with-user-assigned-mi.bicep \
  --parameters \
    environmentName="$CONTAINERAPPS_ENVIRONMENT" \
    containerAppName="$CONTAINERAPPS_NAME" \
    acrPullDefinitionId="$ACR_PULL_DEFINITION_ID" \
    azureContainerRegistry="$AZURE_CONTAINER_REGISTRY" \
    azureContainerRegistryImage="$AZURE_CONTAINER_REGISTRY_IMAGE" \
    azureContainerRegistryImageTag="$AZURE_CONTAINER_REGISTRY_IMAGE_TAG" \
    appInsightsName="$AZURE_APP_INSIGHTS_NAME" \
    logAnalyticsWorkspaceName="$AZURE_LAW_NAME" \
    acrPullDefinitionId="$ACR_PULL_DEFINITION_ID" \
    userAssignedIdentityName="$USER_ASSIGNED_IDENTITY_NAME"
