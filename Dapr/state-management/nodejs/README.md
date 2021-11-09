# Dapr State Management with Container Apps
This sample Azure Resource Manager template deploys a Container App Environment and a Container Apps that uses which use Dapr state management.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fstate-management%2Fnodejs%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fstate-management%2Fnodejs%2Fdeploy%2Fazuredeploy.json)

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Container App Environment

The Container App Environment houses the Container Apps.

### Azure Redis Cache

An Azure Redis Cache is used as the Dapr state store. You can use [any supported state store](https://docs.dapr.io/reference/components-reference/supported-state-stores/). 

### Container Apps

A Container App that uses Dapr state management. This Container App uses an external Ingress controller so that you can test the state store functionality via direct web requests.
- Making a GET request to the /writestatestore controller invokes an outbound POST request to the Dapr state API to write to the state store. It writes the current date/time to a key named "fakekey1".
- Making a GET request to the /readstatestore controller gets the value of the "fakekey1" key.

To demonstrate that the Container App is able to interact with the state store, do the following:
1. Make a GET request to the following URL (replacing *ContainerAppName*.*FQDNSuffix* with your Container App's domain):
https://*ContainerAppName*.*FQDNSuffix*/writestatestore
2. Note the value that is rendered.
3. Make a GET request to the following URL (replacing *ContainerAppName*.*FQDNSuffix* with your Container App's domain):
https://*ContainerAppName*.*FQDNSuffix*/readstatestore
4. Verify that this is the same value that was rendered in step 2.
