targetScope = 'resourceGroup'

@description('Required. Name of the user assigned managed identity.')
@minLength(3)
@maxLength(128)
param name string

@description('Location for all resources')
param location string

@description('Tags applied to the managed identity')
param tags object

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: name
  location: location
  tags: tags
}

@description('The name of the managed identity')
output name string = uai.name

@description('The resource Id of the managed identity')
output id string = uai.id
