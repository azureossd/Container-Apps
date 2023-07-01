# Container App that returns the request headers
This sample Azure Resource Manager template deploys a Container App Environment and an Ingress-enabled Container App that returns the list of request headers in the response.

Note: This application is only intended for testing purposes and not for real-world scenarios. Proceed with caution before sending sensitive request headers to this Container App, because the application will return the request headers in the response.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FShowRequestHeaders%2Fdeploy%2Fazuredeploy.json)

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Container App Environment

The Container App Environment houses the Container Apps.

### Container App

A Container App that hosts an application that returns the request headers in the response, when you visit the root of the site.
