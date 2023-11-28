# Multi-container Container App
This sample Azure Resource Manager template deploys a multi-container Container App.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2Fmulticontainer%2Fnodejs%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2Fmulticontainer%2Fnodejs%2Fdeploy%2Fazuredeploy.json)

### Prerequisites
Deploy a Container App Environment.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.

### Container App

A Container App that contains two containers and an HTTP Ingress controller
- A frontend container that listens internally on port 4000, which the Ingress controller forwards HTTP traffic to.
- A backend container, which listens internally on port 5000. This port is exposed via its Docker configuration so that the frontend container can send traffic to it.

The docker images are already built and publically accessible and configured as defaults in the template, but you can modify the source code and dockerfile and publish to your own container registry.

To demonstrate that the frontend container is able to communicate with the backend container, make a request to the following URL (replacing *ContainerAppName*.*FQDNSuffix* with your Container App's domain):
https://*ContainerAppName*.*FQDNSuffix*/frontendpoint

### CLI deployment for multi-container Container Apps
To deploy multi-contain Container App, supply a yaml configuration and use the --yaml argument.

The containerapp.yaml file provided in the deploy folder can be used to deploy the above-mentioned Container App:
1. Deploy a Container App Environment if you don't already have one. Refer to [this documentation](https://docs.microsoft.com/azure/container-apps/get-started?tabs=bash) for instructions on how to deploy a Container App Environment via CLI.
2. Replace the <SubscriptionId>, <ResourceGroupName>, <ContainerAppEnvironmentName>a, and <RegionName> values with the respective values for your Container App Environment.
3. Replace the <ResourceGroupName> and <ContainerAppName> values in the following command, and then run the command from the directory that contains the deploy folder:

```
az containerapp create --resource-group <ResourceGroupName> --name <ContainerAppName> --yaml ./deploy/containerapp.yaml
```
