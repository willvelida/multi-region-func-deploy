targetScope = 'resourceGroup'

@description('The name of the user-assigned managed identity')
param name string

@description('The GitHub organization or user name')
param githubOrganization string

@description('The GitHub repository name')
param githubRepository string

@description('Specifies the location')
param location string

@description('Specifies the resource tags')
param tags object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

// Federated credential for Pull Requests
resource federatedCredentialPR 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: managedIdentity
  name: 'github-pr'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubOrganization}/${githubRepository}:pull_request'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

// Federated credential for Dev environment
resource federatedCredentialDev 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: managedIdentity
  name: 'github-dev'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubOrganization}/${githubRepository}:environment:dev'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
  dependsOn: [
    federatedCredentialPR
  ]
}

// Federated credential for Prod environment
resource federatedCredentialProd 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: managedIdentity
  name: 'github-prod'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubOrganization}/${githubRepository}:environment:prod'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
  dependsOn: [
    federatedCredentialDev
  ]
}

@description('The name of the deployed managed identity')
output name string = managedIdentity.name

@description('The resource Id of the deployed managed identity')
output id string = managedIdentity.id

@description('The principal Id of the deployed managed identity')
output principalId string = managedIdentity.properties.principalId

@description('The client Id of the deployed managed identity')
output clientId string = managedIdentity.properties.clientId
