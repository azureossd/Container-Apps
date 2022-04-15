# Dapr pub/sub with Container Apps
THE FOLLOWING IS DEPRECATED AND WILL BE UPDATED SOON.

This sample Azure Resource Manager template deploys a Container App Environment and three Container Apps which interact with a pub/sub component.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fpubsub-programmatic%2Fnodejs%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fpubsub-programmatic%2Fnodejs%2Fdeploy%2Fazuredeploy.json)

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Container App Environment

The Container App Environment houses the Container Apps.

### Azure Service Bus Topic

An Azure Service Bus Topic is used as the Dapr pub-sub component to broker messages. You can use [any supported pub/sub](https://docs.dapr.io/reference/components-reference/supported-pubsub//). 

### Container Apps

- A Container App that publishes messages. This Container App uses an external Ingress controller so that you can publish a message via HTTP request.

- Two Container Apps that listen for and consume messages.


To demonstrate that the Publisher is able to send messages to the pub/sub broker and the Consumers are able to receive messages from the pub/sub broker, do the following:
1. Use a REST client to make the following request to the Publisher Container App (replacing *PublisherContainerAppName*.*FQDNSuffix* with your Container App's domain):

POST https://*PublisherContainerAppName*.*FQDNSuffix*/publish

Headers:
Content-Type: application/json

Body: {"mymessage1": "hello data"}

For example:

```
curl -H "Content-Type: application/json" -X POST https://publisher.agreeablemeadow-3efe39b9.canadacentral.azurecontainerapps.io/publish -d "{\"mymessage1\": \"hello data\"}"
```

2. Check the Log Analytics workspace to verify that the Consumer Container Apps received the message. For example:

```
let mymessage = "hello data";
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "consumer1" or ContainerAppName_s == "consumer2"
| where Log_s contains mymessage
| project TimeGenerated, RevisionName_s, ContainerAppName_s, Log_s
```