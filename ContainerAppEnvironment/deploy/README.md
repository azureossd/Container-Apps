# Container App Environment deployment
This Azure Resource Manager template automates deployment of a Container App Environment.

By default, the template deploys a [workload profile-enabled](https://learn.microsoft.com/azure/container-apps/workload-profiles-overview) internal Azure Container App Environment to an Azure Virtual Network, and deploys a Private DNS Zone for the Container App Environment.

However, you can change the options, such as deploy an external Container App Environment to VNET, not use VNET, not enable workload profiles, not use a Private DNS Zone, and deploy the VNET without deploying the Container App Environment.

This sample Azure Resource Manager template deploys an Azure Container App Environment to an Azure Virtual Network. For more information about deploying a Container App Environment to a virtual network, refer to [this documentation](https://docs.microsoft.com/azure/container-apps/vnet-custom?tabs=powershell&pivots=azure-cli#deploy-with-a-private-dns).

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FContainerAppEnvironment%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FContainerAppEnvironment%2Fdeploy%2Fazuredeploy.json)

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Container App Environment

The Container App Environment houses Container Apps. This template gives you the option to deploy the environment in one of the following ways:
- If you set the **deployToVnet** parameter to **true**, the Container App Environment will be deployed to a virtual network.
- If you set the **deployToVnet** parameter to **false**, the Container App Environment will be deployed without a virtual network.
- If you set the **deployToVnet** and **internal** parameters to **true**, the Container App Environment will only be reachable privately through the virtual network.
- If you set the **deployEnvironment** parameter to **false**, the Container App Environment will not be deployed. This setting is useful if you want to deploy and customize the VNET before deploying the Container App Environment.
- If you set the **workloadProfileEnabled** parameter to **true**, the Container App Environment will be deployed with workload profiles enabled. Only the Consumption workload profile will be included, but you can add other profiles later.
- If you set the **workloadProfileEnabled** parameter to **false**, the Container App Environment will be deployed without workload profiles enabled.

If you set the **deployToVnet** parameter to **true**, there are three properties that are available to add to the containerAppsConfiguration element of the Container App Environment resource but that are not included in this template:
- platformReservedCidr
- platformReservedDnsIP
- dockerBridgeCidr

These properties help ensure that other address ranges in your network infrastructure don't conflict with the networking of the Container App Environment infrastructure. If you do not specify these properties, the ARM provider will automatically generate values that don't conflict with the entire address range of the virtual network. If you need further control over which address ranges are or are not assigned to the Container App Environment infrastructure, you can specify these properties in the containerAppsConfiguration element of the Container App Environment resource. See [this documentation](https://docs.microsoft.com/azure/container-apps/vnet-custom?tabs=powershell&pivots=azure-cli#networking-parameters) for further information about these properties.

### Virtual Network

If you set the **deployVnet** parameter to **true** and don't set the **deployToVnet** parameter to **false**, the virtual network will be deployed. The virtual network contains the following subnets, which are necessary for the Container App Environment to function with the virtual network.
- App subnet: Subnet for user app containers. Subnet that contains IP ranges mapped to applications deployed as containers.
- Control plane subnet: Subnet for control plane infrastructure components and user app container.

If you set the **deployVnet** parameter to **false** and set the **deployToVnet** parameter to **false**, the Container App Environment will be deployed to the existing VNET, provided that the VNET already exists.

### Private DNS Zone
If you set the **deployToVnet**, **internal**, and **privateDNS** parameters to **true**, a private DNS zone will be deployed for the Container App Environment.
