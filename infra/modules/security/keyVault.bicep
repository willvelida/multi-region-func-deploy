targetScope = 'resourceGroup'

@description('The name of the Key Vault')
param name string

@description('The SKU of the Key Vault')
@allowed([
  'standard'
  'premium'
])
param sku string = 'standard'

@description('Specifies the location')
param location string = resourceGroup().location

@description('Specifies the resource tags')
param tags object

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: true
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enablePurgeProtection: null
  }
}

@description('The name of the deployed Key Vault')
output name string = keyVault.name

@description('The resource Id of the deployed Key Vault')
output id string = keyVault.id

@description('The URI of the deployed Key Vault')
output vaultUri string = keyVault.properties.vaultUri
