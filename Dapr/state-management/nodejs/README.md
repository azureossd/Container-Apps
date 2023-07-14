# Dapr State Management with Container Apps
This sample Azure Resource Manager template deploys a Container App that uses Dapr state management.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fstate-management%2Fnodejs%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fstate-management%2Fnodejs%2Fdeploy%2Fazuredeploy.json)

### Prerequisites
Deploy a Container App Environment.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.

### Azure Storage Account Blob Container

An Azure Storage Account Blob Container is used as the Dapr state store. You can use [any supported state store](https://docs.dapr.io/reference/components-reference/supported-state-stores/). 

### Container App

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


THE FOLLOWING IS DEPRECATED AND WILL BE UPDATED IN THE NEAR FUTURE.

You can also use the Azure CLI to deploy the Container App. A Container App-schema components yaml file named components.yaml is located under the **deploy** folder. Please note that for Container Apps, the yaml file does not use the Dapr schema. To create the Container App via the CLI, you will need an existing Container App Environment and Azure Storage account. Refer to [this documentation](https://docs.microsoft.com/azure/container-apps/get-started?tabs=bash) for instructions on how to deploy a Container App Environment via CLI. Refer to the [Azure Storage Account CLI documentation](https://docs.microsoft.com/cli/azure/storage/account?view=azure-cli-latest) for information about how to create the Storage account via CLI.  Here is a sample PowerShell comamnd to create the Container App via the CLI. Run the command from the directory that contains the **deploy** folder:

```
az containerapp create --name $MYCONTAINERAPPNAME --resource-group $MYRESOURCEGROUPNAME --environment $MYCONTAINERAPPENVIRONMENTNAME --image docker.io/gfakedocker/statefulappnodejs:latest --target-port 5000 --ingress external --min-replicas 1 --max-replicas 1 --secrets "storageaccountnamesecret=${STORAGE_ACCOUNT},storageaccountkeysecret=${STORAGE_ACCOUNT_KEY}" --environment-variables 'APP_PORT=5000' --enable-dapr --dapr-app-port 5000 --dapr-app-id statefulapp --dapr-components ./deploy/components.yaml

```

A Dapr-schema components yaml file named redisStateStore.yaml is located under the **components** folder, if you want to run the application locally. This component file uses the local Redis instance that is part of the Dapr self-hosted installation. Refer to the [Dapr documentation](https://docs.dapr.io/getting-started/) on how to run an application in Dapr self-hosted mode.

Here is a sample command that runs an application locally in Dapr self-hosted mode:

```
dapr run --app-id app1 --app-port 5000 --dapr-http-port 3500 node app.js --components-path ./components
```