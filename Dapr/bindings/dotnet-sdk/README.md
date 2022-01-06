# Dapr Bindings with Container Apps
This sample Azure Resource Manager template deploys a Container App Environment and a Container App that uses Dapr bindings.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fbindings%2Fdotnet-sdk%2Fbinding-example-dotnet-sdk%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fbindings%2Fdotnet-sdk%2Fbinding-example-dotnet-sdk%2Fdeploy%2Fazuredeploy.json)

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Container App Environment

The Container App Environment houses the Container Apps.

### Azure Service Bus Queue and Azure Storage Queue

In this setup, an Azure Service Bus Queue is used as the Dapr input binding, and an Azure Storage Queue is used as the Dapr output binding. You can use [any supported bindings](https://docs.dapr.io/reference/components-reference/supported-bindings/). Keep in mind that some Binding providers might not use JSON format, in which case you would need to tailor the code to accept the data format that the provider uses.

### Container App

A Container App that uses Dapr bindings. This Container App will listen for messages via the POST route that matches the binding component nameed mybindingforinput.
This route in turn will make a request to the Dapr binding route named mybindingforoutput and write a message to the specified output binding. For simplicity, the code reads the message body of the input and writes the same message body to the output binding. This code uses the Dapr .NET SDK to invoke the output binding, but you can use any REST client.

To test the functionality of the Dapr bindings:
1. Add a JSON message to the Service Bus Queue. You can use the Azure Portal [Service Bus Explorer](https://docs.microsoft.com/azure/service-bus-messaging/explorer#using-the-service-bus-explorer) feature to send a message to the queue. Be sure to select **Application/Json as the **Content Type**. Sample json message:

```
{"hello":"world"}
```

2. [Check the Storage Queue](https://docs.microsoft.com/azure/storage/queues/storage-quickstart-queues-portal#view-message-properties) for a message that contains the same body as the message that you sent to the Service Bus Queue.

If you just want to test the Dapr output binding functionality without triggering the input binding, you can do so by making a GET request to the /myroute endpoint (which is a non-Dapr endpoint). This will write a message that contains "MyRoute method wrote to the output binding at <current date/time>" to the Storage Queue.

If the message does not show up in the queue, you can check the Log Analytics logs to see if bindings were invoked or if there were errors. Eg:

```
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(15m)
| where ContainerAppName_s == "bindingappdotnetsdk"
| project TimeGenerated, Log_s, RevisionName_s
| order by TimeGenerated desc
```


You can also use the Azure CLI to deploy the Container App. A Container App-schema components yaml file named components.yaml is located under the **deploy** folder. Please note that for Container Apps, the yaml file does not use the Dapr schema. To create the Container App via the CLI, you will need an existing Container App Environment and Azure Service Bus Queue and Storage Queue. Refer to [this documentation](https://docs.microsoft.com/azure/container-apps/get-started?tabs=bash) for instructions on how to deploy a Container App Environment via CLI. Here is a sample command that creates the Container App via the CLI, using PowerShell. Replace the bracketed values below (and remove the brackets) and then run the following command from the directory that contains the **deploy** folder:

```
$sbconn1secret = 'Endpoint=sb://<MYSERVICEBUSNAMESPACE>.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=<KEY>';
$storagename1secret='<MYSTORAGEACCOUNTNAME>';
$storageconn1secret='<MYSTORAGEACCOUNTACCESSKEY>';

az containerapp create --name <MYCONTAINERAPPNAME> --resource-group <MYRESOURCEGROUPNAME> --environment <MYCONTAINERAPPENVIRONMENTNAME> --image docker.io/gfakedocker/bindingdotnetsdk:latest --target-port 5000 --ingress external --min-replicas 1 --max-replicas 1 --secrets "sbconn1secret=$sbconn1secret,storagename1secret=$storagename1secret,storageconn1secret=$storageconn1secret" --environment-variables "APP_PORT=5000" --enable-dapr --dapr-app-port 5000 --dapr-app-id bindingappdotnetsdk --dapr-components ./deploy/components.yaml

```
