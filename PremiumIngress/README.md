Premium Ingress for Container Apps

This sample Azure Resource Manager template deploys a Container App Environment [Premium Ingress] workload profile and configuration.

**WARNING**: If you have existing workload profiles in your Container App Environment that you wish to keep, add them to the workloadProfiles section of the template. Deploying this template as-is will attempt to remove existing dedicated workload profiles from the Environment.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FPremiumIngress%2Fdeploy%2Fazuredeploy.json)
### Prerequisites
A workload profiles-enabled Container App Environment. You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.
