# System- and User-Assigned Managed Identity with Container Apps
This sample Azure Resource Manager template deploys a Container App that gets secrets from KeyVaults via System-Assigned Managed Identity and User-Assigned Managed Identity.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FManagedIdentity%2Fdotnet%2FManagedIdentity%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FManagedIdentity%2Fdotnet%2FManagedIdentity%2Fdeploy%2Fazuredeploy.json)

### Prerequisites
Deploy a Container App Environment.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.

### User-Assigned Managed Identity

A User-Assigned Managed Identity named containerappuseridentity-*uniquestring* will be deployed.

### Key Vault
A Key Vault with two secrets will be deployed. This Key Vault will have two access policies:
- A policy that grants Container App's System-Assigned Managed Identity permission to get secrets.
- A policy that grants the User-Assigned Managed Identity permission to get secrets.

### Container App
A Container App named identityca1-*uniquestring* will be deployed with the following configurations:
- A System-Assigned Managed Identity
- Assignment of the User-Assigned Managed Identity.
- Environment variables that specify the KeyVault URI and the User-Managed Identity client id.

The code in the Container App is configured to read these environment variables. In the ManagedIdentityController:
- The System method will get secret1 via the System-Assigned Managed Identity and print the value of the secret in the Web page view.
- The User method will get secret2 via the User-Assigned Managed Identity and print the value of the secret in the Web page view.

### Instructions
After the template is deployed, do the following:
1. On the Container App, open the web url for the Container App.
2. Click SystemIdentityTest to test the System-Assigned Managed Identity connection. If successful, it should display the secret on the page. If not successful, a generic error should be displayed and the exception should be logged to the Log Analytics workspace.
3. Click UserIdentityTest to test the User-Assigned Managed Identity connection. If successful, it should display the secret on the page. If not successful, a generic error should be displayed and the exception should be logged to the Log Analytics workspace.
