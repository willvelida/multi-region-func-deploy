targetScope = 'subscription'

@allowed([
  'dev'
  'tst'
  'stg'
  'prod'
])
param environment string

@description('Azure region for the deployment of all resources')
param location string

var config = loadYamlContent('config.yaml')
var project = config.common.project
var appMaximumInstances = config.common.appMaximumInstances
var logRetentionInDays = config.common.logRetentionInDays
var suffix = substring(uniqueString(resourceGroup.id), 0, 4)

var regionShortCode = config[environment].locations[location].regionShortCode
var resourceGroupName = config[environment].locations[location].resourceGroupName

var namingConvention = toLower('${regionShortCode}-${project}-type-${suffix}')
var tags = {
  project: project
  environment: environment
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module uai 'modules/identity/uai.bicep' = {
  scope: az.resourceGroup(subscription().id, config[environment].locations[location].resourceGroupName)
  name: '${deployment().name}-uai'
  params: {
    name: replace(namingConvention, 'type', 'uai')
    location: location
    tags: tags
  }
}

module logAnalytics 'modules/monitor/logAnalytics.bicep' = {
  scope: az.resourceGroup(subscription().id, config[environment].locations[location].resourceGroupName)
  name: '${deployment().name}-law'
  params: {
    name: replace(namingConvention, 'type', 'law')
    tags: tags
    location: location
    retentionInDays: logRetentionInDays
  }
}

module appInsights 'modules/monitor/appInsights.bicep' = {
  scope: az.resourceGroup(subscription().id, config[environment].locations[location].resourceGroupName)
  name: '${deployment().name}-appins'
  params: {
    name: replace(namingConvention, 'type', 'appins')
    tags: tags
    location: location
    logAnalyticsName: logAnalytics.outputs.name
  }
}

module keyVault 'modules/security/keyVault.bicep' = {
  scope: az.resourceGroup(subscription().id, config[environment].locations[location].resourceGroupName)
  name: '${deployment().name}-kv'
  params: {
    name: replace(namingConvention, 'type', 'kv')
    tags: tags
    location: location
  }
}

module blobStorage 'modules/storage/blobAccount.bicep' = {
  scope: az.resourceGroup(subscription().id, config[environment].locations[location].resourceGroupName)
  name: '${deployment().name}-blob'
  params: {
    name: replace(namingConvention, 'type', 'blob')
    tags: tags
    location: location
  }
}

module appServicePlan 'modules/host/appServicePlan.bicep' = {
  scope: az.resourceGroup(subscription().id, config[environment].locations[location].resourceGroupName)
  name: '${deployment().name}-asp'
  params: {
    name: replace(namingConvention, 'type', 'asp')
    location: location
    tags: tags
    kind: 'windows'
    maximumElasticWorkerCount: appMaximumInstances
  }
  dependsOn: [
    blobStorage
  ]
}

module functionApp 'modules/host/functionApp.bicep' = {
  scope: az.resourceGroup(subscription().id, config[environment].locations[location].resourceGroupName)
  name: '${deployment().name}-func'
  params: {
    name: replace(namingConvention, 'type', 'func')
    tags: tags
    appServicePlanId: appServicePlan.outputs.resourceId
    applicationInsightsName: appInsights.outputs.name
    keyVaultName: keyVault.outputs.name
    managedIdentityId: uai.outputs.id
    storageAccountName: blobStorage.outputs.name
  }
}
