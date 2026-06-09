@description('Location for all resources')
param location string

@description('Name of the Container App')
param containerAppName string

@description('Name of the Container Apps Environment')
param caeName string

@description('Name of the user-assigned managed identity')
param identityName string

@description('Container image to deploy')
param containerImage string

@description('ACR login server')
param acrLoginServer string

@description('ACR resource name')
param acrName string

@description('Resource group of the ACR')
param acrResourceGroup string = resourceGroup().name

@description('Existing subnet resource ID for the CAE. Leave empty to create a new VNet/subnet.')
param subnetId string = ''

@description('Outbound IP addresses from Container App to allow through ACR firewall')
param containerAppOutboundIps array = []

@description('Name of the VNet to create (used only when subnetId is empty)')
param vnetName string = '${containerAppName}-vnet'

// AcrPull role definition ID
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// User-Assigned Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

// Assign AcrPull role to the managed identity on the ACR
module acrRoleAssignment 'acr-role-assignment.bicep' = {
  name: 'acr-role-assignment'
  scope: resourceGroup(acrResourceGroup)
  params: {
    acrName: acrName
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: acrPullRoleDefinitionId
    acrLocation: location
    outboundIps: containerAppOutboundIps
  }
}

// Optional VNet/Subnet creation when no existing subnet is provided
module vnetModule 'vnet.bicep' = if (subnetId == '') {
  name: 'vnet-deployment'
  params: {
    location: location
    vnetName: vnetName
  }
}

var effectiveSubnetId = subnetId != '' ? subnetId : vnetModule!.outputs.subnetId

// Container Apps Environment with VNet integration
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2026-01-01' = {
  name: caeName
  location: location
  properties: {
    vnetConfiguration: {
      infrastructureSubnetId: effectiveSubnetId
    }
  }
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2026-01-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
      registries: [
        {
          server: acrLoginServer
          identity: managedIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          name: '${containerAppName}-container'
          image: containerImage
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
  dependsOn: [
    acrRoleAssignment
  ]
}

output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
output managedIdentityId string = managedIdentity.id
output managedIdentityClientId string = managedIdentity.properties.clientId
output containerAppOutboundIps array = containerApp.properties.outboundIpAddresses
