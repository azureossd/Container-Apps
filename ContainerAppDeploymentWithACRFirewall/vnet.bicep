@description('Location for the VNet and subnet')
param location string

@description('Name of the Virtual Network')
param vnetName string

@description('Name of the subnet for Container Apps Environment')
param subnetName string = 'cae-subnet'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/23'
          delegations: [
            {
              name: 'Microsoft.App.environments'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
