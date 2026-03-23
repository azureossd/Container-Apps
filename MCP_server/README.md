# Minimal POC MCP server on Container App

These MCP tools perform health checks against specified service(s). This example is just for demonstration purposes and is not intended as an actual production tool, nor as a recommendation about security best-practices. Use at your own discretion. 

## Step 1 — Deploy the MCP Server

a. Deploy a Container Apps Environment or use an existing Container Apps Environment. You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.

b. Deploy the Container App using the [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FMCP_server%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FMCP_server%2Fdeploy%2Fazuredeploy.json). Provide an arbitrary value for the mcp-api-key. This will be stored as a secret in the Container App, and later used to authenticate from clients to the MCP server on the Container App.

  > Note: The code is already containerized and published to Docker Hub and referenced in the Container App, so you don't need to deploy the code or container separately.


Note the FQDN from the output — you'll use it as the MCP endpoint URL when you configure a connection from your client.

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

