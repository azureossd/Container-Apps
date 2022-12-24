param environmentName string 
param logAnalyticsWorkspaceName string
param appInsightsName string
param containerAppName string 
param azureContainerRegistry string
param azureContainerRegistryImage string 
param azureContainerRegistryImageTag string
param acrPullDefinitionId string
param userAssignedIdentityName string
param location string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: azureContainerRegistry
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: userAssignedIdentityName
  location: location 
}

// roleDefinitionId is the ID found here for AcrPull: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acr
  name: guid(resourceGroup().name, azureContainerRegistry, 'AcrPull')
  properties: {
    principalId: identity.properties.principalId  
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullDefinitionId)
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource appEnvironment 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: environmentName
  location: location
  properties: {
    // daprAIInstrumentationKey:appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties:{
    managedEnvironmentId: appEnvironment.id
    configuration: {
      ingress: {
        targetPort: 8080
        external: true
      }
      registries: [
        {
          server: '${azureContainerRegistry}.azurecr.io'
          identity: identity.id
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${azureContainerRegistry}.azurecr.io/${azureContainerRegistryImage}:${azureContainerRegistryImageTag}'
          name: 'dockercontainersshexamples-dotnet-alpine'
          resources: {
            cpu: 1
            memory: '2Gi'
          }}
      ]
    }
  }
}

output location string = location
output environmentId string = appEnvironment.id
