targetScope = 'resourceGroup'

param name string

param location string

param tags object

@allowed([
  'linux'
  'windows'
])
param kind string = 'linux'

param skuTier string = 'ElasticPremium'

param skuName string = 'EP1'

param maximumElasticWorkerCount int = 10

param isZoneRedundant bool = false

resource appServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: kind == 'linux' ? true : false
    zoneRedundant: location == 'australiaeast' ? isZoneRedundant : false
    elasticScaleEnabled: true
    maximumElasticWorkerCount: maximumElasticWorkerCount
  } 
  kind: kind
}

output name string = appServicePlan.name
output resourceId string = appServicePlan.id
