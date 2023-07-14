# Dapr service-to-service with Container Apps
This sample Azure Resource Manager template deploys two Container Apps which use Dapr service-to-service invocation to communicate with each other.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fserviceinvocation%2Fnodejs%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fserviceinvocation%2Fnodejs%2Fdeploy%2Fazuredeploy.json)

### Prerequisites
Deploy a Container App Environment.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.

### Container Apps

- A frontend Container App, which uses external HTTP ingress to receive public traffic and which has Dapr enabled. This application makes an outbound request to the backend Container App via the Dapr Invoke API.

- A backend Container App, which uses internal HTTP ingress and has Dapr enabled so that the application can receive HTTP traffic from the frontend application. In order to use Dapr service-to-service invocation, HTTP ingress must be enabled on the target Container App but can be set to either external or internal. You do not need to configure the Dockerfile to expose the container's port in order for communication between the Container Apps to work.

The docker images are already built and publically accessible and configured as defaults in the template, but you can modify the source code and dockerfiles and publish to your own container registry.

To demonstrate that the frontend Container App is able to communicate with the backend Container App, make a request to the following URL on the frontend Container App (replacing *FrontEndContainerAppName*.*FQDNSuffix* with your Container App's domain):
https://*FrontEndContainerAppName*.*FQDNSuffix*/frontendpoint