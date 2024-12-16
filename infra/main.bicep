targetScope = 'resourceGroup'

@description('The location where resources will be deployed.')
param location string = 'westeurope'

@description('The name of the storage account.')
param storageAccountName string = 'hvalfangststorageaccount'

@description('The name of the storage container.')
param storageContainerName string = 'hvalfangstcontainer'

@description('The name of the App Service Plan.')
param servicePlanName string = 'hvalfangstserviceplan'

@description('The name of the Application Insights instance.')
param appInsightsName string = 'hvalfangstapplicationinsights'

@description('The name of the Linux Function App.')
param functionAppName string = 'hvalfangstlinuxfunctionapp'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: storageContainerName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: servicePlanName
  location: location
  sku: {
    name: 'Y1'
  }
  kind: 'Linux'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'other'
  properties: {
    Application_Type: 'other'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsFeatureFlags'
          value: 'EnableWorkerIndexing'
        }
      ]
      linux_fx_version: 'Python|3.10'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
