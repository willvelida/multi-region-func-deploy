targetScope = 'resourceGroup'

@description('The name of the Storage account')
param name string

@description('The SKU of the Storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param sku string = 'Standard_LRS'

@description('The name of the blob container')
param containerName string = 'data'

@description('Specifies the location')
param location string = resourceGroup().location

@description('Specifies the resource tags')
param tags object

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}

@description('The name of the deployed Storage account')
output name string = storageAccount.name

@description('The resource Id of the deployed Storage account')
output id string = storageAccount.id

@description('The name of the blob container')
output containerName string = blobContainer.name

@description('The primary endpoints of the Storage account')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
