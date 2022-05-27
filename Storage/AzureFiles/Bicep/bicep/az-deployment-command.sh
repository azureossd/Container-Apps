az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file ./azurefiles-storage-volume.bicep \
  --parameters \
    environment_name="$CONTAINERAPPS_ENVIRONMENT" \
    location="$LOCATION" \
    azureContainerRegistry="$AZURE_CONTAINER_REGISTRY" \
    azureContainerRegistryUsername="$AZURE_CONTAINER_REGISTRY_USERNAME" \
    azureContainerRegistryPassword="$AZURE_CONTAINER_REGISTRY_PASSWORD" \
    azureFileShareName="$AZURE_FILE_SHARE_NAME" \
    azureStorageAccountKey="$AZURE_STORAGE_ACCOUNT_KEY" \
    azureStorageAccountName="$AZURE_STORAGE_ACCOUNT_NAME"
