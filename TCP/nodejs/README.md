# Container App as TCP service
This sample Azure Resource Manager template deploys an Azure Container App that acts as a TCP service. Refer to the [Configure Ingress](https://learn.microsoft.com/azure/container-apps/ingress-how-to) documentation for further information about Ingress settings. For further information about TCP ingress requirements and behaviors, refer to the [Ingress Overview](https://learn.microsoft.com/azure/container-apps/ingress-overview#tcp) documentation.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FTCP%2Fnodejs%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FTCP%2Fnodejs%2Fdeploy%2Fazuredeploy.json)

## Prerequisites
Deploy a Container App Environment and Virtual Network.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Virtual Network and Container App Environment.

## Resources deployed in this template
### Container Apps
You can optionally deploy either or both of the following Container Apps:
- **TCP service**: by default, this app listens on port 5000. If the TCP request is successfully processed, the application prints the TCP data that was sent by the client. The default exposed port used in this template is 6000. The exposed port is what you send your TCP request to.
- **TCP client**: for convenience, a Container App that has netcat installed is deployed, so that you can test the TCP service.

## Testing the TCP service

### From the TCP client ACA
For the sake of this test, we will test connectivity to the TCP service via its external ingress FQDN.

1. Make note of the ingress FQDN of the TCP service ACA. The FQDN will resemble tcpservicenodejs.ENVIRONMENT_PREFIX.ENVIRONMENT_REGION.azurecontainerapps.io
2. [Connect to the Console](https://learn.microsoft.com/azure/container-apps/container-console?tabs=bash#azure-portal) on the TCP client.
3. In the following command, replace the capitalized values and underscores. Then run the command from the console on the TCP client:
```
nc -w 5 tcpservicenodejs.ENVIRONMENT_PREFIX.ENVIRONMENT_REGION.azurecontainerapps.io 6000 < test.txt
```

If the connection to the TCP service is successful and the TCP service returns the expected response, the following text will be returned:
```
Hello world!
```

If no response is returned, then there was an issue with getting a response from the TCP service.


### From a local machine
You can use a TCP client such as the [NMAP](https://nmap.org/dist/) NCAT utility to test the TCP service from your machine.

To test the TCP service via NCAT:
1. Ensure that your IP address is allowed in the inbound rules of the subnet NSG.
2. Create a text file with some text that you want to send to the TCP service. 
Note: The application is provided as-is and has not been tested for special characters or complex text. I recommend using simple text such as a hello message for the purpose of testing basic functionality with the tcp service.
3. Do one of the following:
- If using an external Container App Environment, or an internal Container App Environment with DNS configured, you can use the DNS name of the Container App in the tcp request. In the following command, replace the capitalized values and underscores, and adjust the values further if you customized the container app name or custom domain, DNS suffix, and/or exposed port. Then run the command.

```
ncat tcpservicenodejs.ENVIRONMENT_PREFIX.ENVIRONMENT_REGION.azurecontainerapps.io 6000 < PATH_TO_TEXT_FILE
```

- If using an internal Container App Environment with no DNS configured, you must use the private inbound IP address of the Container App Environment in the tcp request. In the following command, replace the capitalized values, and replace the exposed port if you chose port other than 6000. Then run the command.

```
ncat ENVIRONMENT_INBOUND_IP_ADDRESS 6000 < PATH_TO_TEXT_FILE
```

If the message is successfully processed, you should receive a response that contains the text you sent. You can use the -v switch with NCAT to see further details about the request.

You can also check the Container App logs to verify that the message was received, or whether there were related errors. Refer to the [documentation](https://learn.microsoft.com/en-us/azure/container-apps/log-options) for logging options and how to use logging with Container Apps. If using the default Log Analytics option for Container Apps, you can use a query such as the following to check the application logs.

```
let containerApp = "tcpservicenodejs";
ContainerAppConsoleLogs_CL
| where ContainerAppName_s =~ containerApp
| where Log_s != "Client connected" and Log_s != "Client disconnected"
| order by TimeGenerated desc
```