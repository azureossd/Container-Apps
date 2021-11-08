# Dapr Actors with Container Apps
This sample Azure Resource Manager template deploys a Container App Environment and two Container Apps which use Dapr Actors.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Factors%2Fdotnet-sdk%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Factors%2Fdotnet-sdk%2Fdeploy%2Fazuredeploy.json)

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Container App Environment

The Container App Environment houses the Container Apps.

### Azure Redis Cache

An Azure Redis Cache is used as the Dapr state store for the Actor. You can use [any supported state store](https://docs.dapr.io/reference/components-reference/supported-state-stores/). 

### Container Apps

- A Container App that hosts a Dapr Actor service. This Container App uses an internal Ingress controller so that the client Container App can use the Actor proxy to communicate with the Actor service. The minReplicas is set to 1 because there must be at least 1 replica in order for Actors to function.

- A Container App that acts as a Dapr client. This Container App uses an external Ingress controller so that you can view the results of the test via a web page.

The code is based on the [Dapr .NET SDK example](https://docs.dapr.io/developing-applications/sdks/dotnet/dotnet-actors/dotnet-actors-howto/).
There are two Docker files:
- MyActorServiceDockerfile: builds the MyActorService and MyActor.Interfaces projects.
- MyActorClientDockerfile: builds the MyActorClient and MyActor.Interfaces projects.

MyActor.sln contains all three projects: MyActorService, MyActor.Interfaces, and MyActorClient.

To demonstrate that the Dapr client Container App is able to perform operations on the Actor in the Actor service Container App, make a request to the following URL on the client Container App (replacing *DaprClientContainerAppName*.*FQDNSuffix* with your Container App's domain):
https://*DaprClientContainerAppName*.*FQDNSuffix*

If the communication with the Actor is successful, the client site page will render the following text:

PropertyA: **ValueA**
PropertyB: **ValueB**

If the communication with the Actor is not successful, the client site page will render the following text:
"unable to contact MyActorService :("
