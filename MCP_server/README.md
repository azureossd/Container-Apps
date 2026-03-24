# Minimal POC MCP server on Container App

These MCP tools perform health checks against specified service(s). This example is just for demonstration purposes and is not intended as an actual production tool, nor as a recommendation about security best-practices. Use at your own discretion. 

## Deploy the MCP Server

1. Deploy a Container Apps Environment or use an existing Container Apps Environment. You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment, using the default values provided in the template.

2. Deploy the Container App:
   - Open the [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FMCP_server%2Fdeploy%2Fazuredeploy.json) link in a separate browser tab, but review the following before you submit the deployment:
     - For the mcp-api-key, provide an arbitrary value. This will be stored as a secret in the Container App, and later used to authenticate from clients to the MCP server on the Container App. This implementation is specific to the container that is provided in this example.
     - If you created the Environment via the above template, deploy the Container App to the same resource group and use the default values that are provided for Region, Location, Environment Name, and Workload Profile Name.
     - For Containerimage, use the default value if you wish to use the container in this example.


After you deploy the container app, note its application URL on the Overview page, which resembles https://*ContainerAppName*.*EnvironmentDomainPrefix*.canadacentral.azurecontainerapps.io . The MCP endpoint for this sample application resembles https://*ContainerAppName*.*EnvironmentDomainPrefix*.canadacentral.azurecontainerapps.io/mcp . You will use this MCP endpoint plus the mcp-api-key when you configure a connection from your client.

## MCP Tool Reference

### `http\_health\_check`

Probes a single HTTP endpoint.

|Parameter|Type|Default|Description|
|-|-|-|-|
|`url`|string|required|Full URL to check|
|`method`|string|`GET`|HTTP method|
|`timeout\_seconds`|int|`10`|Timeout per request|
|`expected\_status`|int|`200`|Status code = healthy|

### `batch\_health\_check`

Checks multiple endpoints concurrently.

|Parameter|Type|Default|Description|
|-|-|-|-|
|`urls`|list\[string]|required|URLs to check|
|`timeout\_seconds`|int|`10`|Timeout per request|
|`expected\_status`|int|`200`|Status code = healthy|

