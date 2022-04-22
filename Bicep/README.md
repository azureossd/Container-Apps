# Container App Environment and Container App
This sample Bicep template deploys a Container App Environment and Container App. This example can be ran with the following command:

`az deployment group create --resource-group "yourresourcegroupname" --template-file containerapps.bicep --parameters location="yourregionofchoice"`

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Application Insights
An Application Insights resource is created.

### Container App Environment

The Container App Environment houses the Container Apps.

### Container App

A Container App that uses the NGINX image is deployed, to demonstrate deployment of Container Apps in the same deployment as the Container App Environment deployment.
