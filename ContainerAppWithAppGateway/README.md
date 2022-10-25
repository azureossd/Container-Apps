# Container App with Application Gateway
This sample Azure Resource Manager template deploys an Azure Container App behind an Azure Application Gateway. 

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FContainerAppWithAppGateway%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FContainerAppWithAppGateway%2Fdeploy%2Fazuredeploy.json)

## Prerequisites
Deploy a Container App Environment and Virtual Network.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppInVNET/deploy) to deploy a Virtual Network and [Internal Container App Environment](https://learn.microsoft.com/azure/container-apps/networking) that uses private DNS.

## Resources deployed in this template
### Container App
The Container App will server as the backend for the Application Gateway. If you deploy the Container App to an internal Environment, the Container App will not be accessible via the Internet, but the Application Gateway will be Internet-facing and will be able to forward traffic to the Container App via VNET. 

### Public IP Address
The Public IP address that will be used by the Application Gateway

### Subnet
The subnet that will be used by the Application Gateway.

### Network Security Group
The NSG that will be used by the Application Gateway subnet. By default, inbound HTTP/S traffic is not allowed from the Internet. For any Internet addresses that you want to allow to access the Application Gateway, you will need to allow these addresses.

### Application Gateway

The Application Gateway uses the Container App as the backend. The Application Gateway will be able to receive HTTP requests via the Public IP and forward them to the Container App.