@description('Name of the ACR')
param acrName string

@description('Principal ID to assign the role to')
param principalId string

@description('Role definition ID to assign')
param roleDefinitionId string

@description('Location of the ACR')
param acrLocation string

@description('SKU of the ACR')
param acrSku string = 'Premium'

@description('Outbound IP addresses from Container App to allow through ACR firewall')
param outboundIps array = []

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

var outboundIpRules = [for ip in outboundIps: {
  action: 'Allow'
  value: ip
}]

resource acrNetworkConfig 'Microsoft.ContainerRegistry/registries@2023-07-01' = if (length(outboundIps) > 0) {
  name: acrName
  location: acrLocation
  sku: {
    name: acrSku
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: outboundIpRules
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, principalId, roleDefinitionId)
  scope: acr
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: 'ServicePrincipal'
  }
}
