# Container App Environment and Container App
This sample Azure Resource Manager template deploys a Container App Environment and multi-container Container App.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2Fmulticontainer%2Fnodejs%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2Fmulticontainer%2Fnodejs%2Fdeploy%2Fazuredeploy.json)

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Container App Environment

The Container App Environment houses the Container Apps.

### Container App

A Container App that contains two containers and an HTTP Ingress controller
- A frontend container that listens internally on port 4000, which the Ingress controller forwards HTTP traffic to.
- A backend container, which listens internally on port 5000. This port is exposed so that the frontend container can send traffic to it.

The docker images are already built and publically accessible and configured as defaults in the template, but you can modify the source code and dockerfile and publish to your own container registry.

To demonstrate that the frontend container is able to communicate with the backend container, make a request to the following URL (replacing <ContainerAppName>.<FQDNSuffix> with your Container App's domain):
https://<ContainerAppName>.<FQDNSuffix>/frontendpoint