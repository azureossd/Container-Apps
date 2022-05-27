param environment_name string
param location string 
param azureStorageAccountName string
param azureFileShareName string
param azureStorageAccountKey string
param azureContainerRegistry string
param azureContainerRegistryUsername string
@secure()
param azureContainerRegistryPassword string

var logAnalyticsWorkspaceName = 'logs-${environment_name}'
var appInsightsName = 'appins-${environment_name}'

resource logAnalyticsWorkspace'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
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

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environment_name
  location: location
  properties: {
    daprAIInstrumentationKey: reference(appInsights.id, '2020-02-02').InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspace.id, '2020-03-01-preview').customerId
        sharedKey: listKeys(logAnalyticsWorkspace.id, '2020-03-01-preview').primarySharedKey
      }
    }
  }

  resource azurefilestorage 'storages@2022-03-01' = {
    name: 'azurefilestorage'
    properties: {
      azureFile: {
        accountKey: azureStorageAccountKey
        accountName: azureStorageAccountName
        shareName: azureFileShareName
        accessMode: 'ReadWrite'
      }
    }
  }
}

resource nodeazurefilescontainerapps 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'nodeazurefilescontainerapps'
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      secrets: [
        {
          name: 'containerregistrypasswordref'
          value: azureContainerRegistryPassword
        }
      ]
      ingress: {
        external: true
        targetPort: 3000
      }

      registries: [
        {
          // server is in the format of myregistry.azurecr.io
          server: azureContainerRegistry
          username: azureContainerRegistryUsername
          passwordSecretRef: 'containerregistrypasswordref'
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${azureContainerRegistry}/nodeazurefilescontainerapps:latest'
          name: 'nodeazurefilescontainerapps'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          volumeMounts: [
            {
              mountPath: '/azurefiles'
              volumeName: 'azurefilemount'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      volumes: [
        {
          name: 'azurefilemount'
          // https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type#within-parent-resource
          storageName: environment::azurefilestorage.name
          storageType: 'AzureFile'
        }
      ]
    }
  }
}

