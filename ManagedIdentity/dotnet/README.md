# Dapr service-to-service with Container Apps
This sample Azure Resource Manager template deploys a Container App Environment and Container App that gets secrets from KeyVaults via System-Assigned Managed Identity and User-Assigned Managed Identity.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FManagedIdentity%2Fdotnet%2FManagedIdentity%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FManagedIdentity%2Fdotnet%2FManagedIdentity%2Fdeploy%2Fazuredeploy.json)

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### User-Assigned Managed Identity

A User-Assigned Managed Identity named containerappuseridentity-*uniquestring* will be deployed.

### Container App Environment

The Container App Environment houses the Container Apps.

### Container App
A Container App named identityca1-*uniquestring* will be deployed with the following configurations:
- Assignment of the User-Assigned Managed Identity and a System-Assigned Managed Identity.
- Environment variables that specify the KeyVault URIs and the User-Managed Identity client id.

The code in the Container App is configured to read these environment variables. The application will print the KeyVault secrets to the web page upon successful connection to the respective KeyVault.

### Key Vaults
Two Key Vaults are deployed:
- keyvault1-*uniquestring*: The Container App will connect to this Key Vault via System-Assigned Managed Identity
- keyvault2-*uniquestring*: The Container App will connect to this Key Vault via User-Assigned Managed Identity

### Instructions
After the template is deployed, do the following:
1. In the keyvault1-*uniquestring* Key Vault's access policies, [add an access policy](https://docs.microsoft.com/azure/key-vault/general/assign-access-policy?tabs=azure-portal) that grants **Secret permissions** for **Get** operations to the identityca1-*uniquestring* identity.
2. In the keyvault2-*uniquestring* Key Vault's access policies, [add an access policy](https://docs.microsoft.com/azure/key-vault/general/assign-access-policy?tabs=azure-portal) that grants **Secret permissions** for **Get** operations to the containerappuseridentity-*uniquestring* identity.
3. On the Container App, open the web url for the Container App.
4. Click UserIdentityTest to test the User-Assigned Managed Identity connection. If successful, it should display the secret on the page.
5. Click SystemIdentityTest to test the System-Assigned Managed Identity connection. If successful, it should display the secret on the page.
