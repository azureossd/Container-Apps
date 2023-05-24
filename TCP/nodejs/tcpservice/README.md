# Container App as TCP service
This sample Azure Resource Manager template deploys an Azure Container App that acts as a TCP service.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FTCP%2Fnodejs%2Ftcpservice%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FTCP%2Fnodejs%2Ftcpservice%2Fdeploy%2Fazuredeploy.json)

## Prerequisites
Deploy a Container App Environment and Virtual Network.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppInVNET/deploy) to deploy a Virtual Network and Container App Environment.

## Resources deployed in this template
### Container App
The Container App contains a TCP service, which listens on port 5000 by default, or the port specified in the APP_PORT environment variables (if present).
If the TCP request is successfully processed, the application prints the TCP data that was sent by the client.

The default exposed port used in this template is 6000. The exposed port is what you send your TCP request to.

You can use a TCP client to test the tcp service. For example, you can use the [NMAP](https://nmap.org/dist/) NCAT utility.

To test the service via NCAT:
1. Ensure that your IP address is allowed in the inbound rules of the subnet NSG.
2. Create a text file with some text that you want to send to the TCP service.
3. Do one of the following:
- If using an external Container App Environment, or an internal Container App Environment with DNS configured, you can use the DNS name of the Container App in the tcp request. In the following command, replace the capitalized values, and adjust the values further if you customized the container app name or custom domain, DNS suffix, and/or exposed port. Then run the command.

```
ncat tcpservicenodejs.ENVIRONMENT_PREFIX.ENVIRONMENT_REGION.azurecontainerapps.io 6000 < PATH_TO_TEXT_FILE -v
```

- If using an internal Container App Environment with no DNS configured, you must use the private inbound IP address of the Container App Environment in the tcp request. In the following command, replace the capitalized values, and replace the exposed port if you chose port other than 6000. Then run the command.

```
ncat ENVIRONMENT_INBOUND_IP_ADDRESS 6000 < PATH_TO_TEXT_FILE -v
```
