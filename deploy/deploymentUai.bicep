targetScope = 'subscription'

@description('The name of the user-assigned managed identity')
param name string

@description('The GitHub organization or user name')
param githubOrganization string

@description('The GitHub repository name')
param githubRepository string

@description('The name of the resource group where the managed identity will be deployed')
param resourceGroupName string

@description('Specifies the location')
param location string

@description('Specifies the resource tags')
param tags object

module managedIdentityResources 'managedIdentityResources.bicep' = {
  name: 'managedIdentityResources'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: name
    githubOrganization: githubOrganization
    githubRepository: githubRepository
    location: location
    tags: tags
  }
}

// Contributor role assignment at subscription level
resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, managedIdentityResources.name, 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: managedIdentityResources.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

// User Access Administrator role assignment at subscription level
resource userAccessAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, managedIdentityResources.name, '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
    principalId: managedIdentityResources.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

@description('The name of the deployed managed identity')
output name string = managedIdentityResources.outputs.name

@description('The resource Id of the deployed managed identity')
output id string = managedIdentityResources.outputs.id

@description('The principal Id of the deployed managed identity')
output principalId string = managedIdentityResources.outputs.principalId

@description('The client Id of the deployed managed identity')
output clientId string = managedIdentityResources.outputs.clientId
