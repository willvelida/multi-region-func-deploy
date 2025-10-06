targetScope = 'resourceGroup'

@description('The name of the App Insights workspace')
param name string

@description('Specifies the location')
param location string = resourceGroup().location

@description('Retention Period in Days')
param retentionInDays int = 90

@description('Specifies the resource tags')
param tags object

@description('The name of the Log Analytics this App Insights component will use')
param logAnalyticsName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalyticsName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: true
    DisableLocalAuth: true
    IngestionMode: 'LogAnalytics'
    Request_Source: 'rest'
    RetentionInDays: retentionInDays
    WorkspaceResourceId: logAnalytics.id
  }
}

@description('The name of the App Insights component')
output name string = appInsights.name

@description('The resource Id of the App Insights component')
output resourceId string = appInsights.id

@description('The App Insights Connection String')
output connectionString string = appInsights.properties .ConnectionString
