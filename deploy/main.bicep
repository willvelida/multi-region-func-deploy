targetScope = 'subscription'

@description('The name of the resource group')
param resourceGroupName string

@description('The name of the user-assigned managed identity')
param managedIdentityName string

@description('The GitHub organization or user name')
param githubOrganization string

@description('The GitHub repository name')
param githubRepository string

@description('Specifies the location')
param location string = deployment().location

@description('Specifies the resource tags')
param tags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module deploymentIdentity 'deploymentUai.bicep' = {
  name: 'deploymentUai'
  scope: resourceGroup
  params: {
    name: managedIdentityName
    githubOrganization: githubOrganization
    githubRepository: githubRepository
    location: location
    tags: tags
  }
}

@description('The name of the deployed resource group')
output resourceGroupName string = resourceGroup.name

@description('The principal Id of the deployment managed identity')
output deploymentPrincipalId string = deploymentIdentity.outputs.principalId

@description('The client Id of the deployment managed identity')
output deploymentClientId string = deploymentIdentity.outputs.clientId
