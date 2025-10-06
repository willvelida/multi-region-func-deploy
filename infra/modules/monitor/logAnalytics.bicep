targetScope = 'resourceGroup'

@description('The name of the Log Analytics workspace')
param name string

@description('The SKU of the workspace')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param sku string = 'PerGB2018'

@description('Specifies the workspace data retention in days')
param retentionInDays int = 90

@description('Specifies the location')
param location string = resourceGroup().location

@description('Specifies the resource tags')
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

@description('The name of the deployed Log Analytics workspace')
output name string = logAnalytics.name

@description('The resource Id of the deployed Log Analytics workspace')
output id string = logAnalytics.id

@description('The customer Id of the deployed Log Analytics workspace')
output customerId string = logAnalytics.properties.customerId
