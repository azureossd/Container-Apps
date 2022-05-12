# System-Assigned Managed Identity with Container Apps
This sample Azure Resource Manager template deploys a Container App Environment and Container App that gets secrets from KeyVaults via System-Assigned Managed Identity and User-Assigned Managed Identity.

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### System-Assigned Managed Identity

A System-Assigned Managed Identity that is configured to be enabled in the Bicep template.

### Key Vault
A Key Vault will be referenced. This implies there is an existing Key Vault. See [here](https://docs.microsoft.com/en-us/azure/key-vault/general/quick-create-portal) on how to create one.
- A policy that grants Container App's System-Assigned Managed Identity permission to get secrets - this grants 'Get' access.
- The environment variable `KEY_VAULT_NAME` should contain the name of your Key Vault - ex. mykeyvault
- The environment variable `SECRET` should contain the secret name in your Key Vault you want to retrieve 

### Container App Environment

The Container App Environment houses the Container Apps.

### Container App
A Container App named `pythonmanagedidentitykv` will be deployed with the following configurations:
- A System-Assigned Managed Identity
- Environment variables that specify the KeyVault name and the KeyVault secret to retrieve.

The code in the Container App is configured to read these environment variables. In `app.py` and specifically the `get_keyvault_secret()` function which maps to the root path of the application (ex. '/'):
- The System method will get the secret of choice via the System-Assigned Managed Identity and print the value of the secret in the response.

### Instructions
The Bicep template can be deployed with the following command:

```bash
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
```

> **NOTE**: Make sure to set the above environment variables or hardcode if desired

The Docker Image should be built locally and then pushed to your Azure Container Registry.

After the template is deployed, do the following:
1. On the Container App, open the web url for the Container App.
2. If successful, this should print the secret name in a JSON response.