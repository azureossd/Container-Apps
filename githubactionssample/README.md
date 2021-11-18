# Container App Github actions sample
This sample includes a GitHub actions workflow to perform continous deployment to an existing Azure Container App from an Azure Container Registry (ACR).
Instructions on how to set up this GitHub action are found [here](https://docs.microsoft.com/azure/container-apps/github-actions-cli?tabs=bash).

If you want to test this sample without running the **az containerapp github-action add** command in the above documentation, you can do so if you first create the following secrets in your GitHub repository (prior to pushing the contents of this folder to your GitHub repository):
- CONTAINERAPP_NAME : The name of your existing Container App
- RESOURCEGROUP : The resource group for your existing Container App
- ACR_NAME : The name of your ACR
- REGISTRY_USERNAME : The name of your ACR
- REGISTRY_PASSWORD : Your ACR password
- AZURE_CREDENTIALS : The Azure service principal JSON information. Eg:

```
{
  "clientId": "<Azure service principal client id>",
  "clientSecret": "<Azure service principal  client secret>",
  "subscriptionId": "<Azure subscription>",
  "tenantId": "<Azure tenant id>",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com/",
  "resourceManagerEndpointUrl": "https://eastus2euap.management.azure.com",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

This sample application listens on port 80 by default, or on whatever port is set in the APP_PORT environment variable if present. Be sure that the target port of your Container App's Ingress and the application port match. If the GitHub action successfully completes, and if yourContainer App's Ingress is set to External and the target port matches the application's port, you should see the following text when you visit the root page of your Container App revision:

```
Docker container for GitHub actions sample was successfully pulled
```