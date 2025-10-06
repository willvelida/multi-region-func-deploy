using './main.bicep'

param resourceGroupName = 'rg-multi-region-func-deploy'
param managedIdentityName = 'id-github-deployment'
param githubOrganization = 'willvelida'
param githubRepository = 'multi-region-func-deploy'
param location = 'australiaeast'
param tags = {
  environment: 'deployment'
  project: 'multi-region-func-deploy'
  managedBy: 'bicep'
}
