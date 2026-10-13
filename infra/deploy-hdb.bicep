@description('Random suffix used to keep resource names unique per deployment.')
param nameSuffix string = uniqueString(newGuid())

@description('Location for all resources.')
param location string = resourceGroup().location
// australiaeast,canadacentral,centralus,eastus,germanywestcentral,indiasouthcentral
//,indonesiacentral,japaneast,koreacentral,swedencentral,westus2,westus3,eastus2euap
//,italynorth,polandcentral,uaenorth,uksouth

@description('Unique name for the HorizonDB cluster.')
param clusterName string = 'horizondb-lab-${location}-${nameSuffix}'

@description('The version of PostgreSQL to use.')
param postgresVersion string = '17'

@description('Number of vCores per node.')
param vCores int = 2

@description('Number of replicas.')
param replicaCount int = 2

@description('Admin username for the cluster.')
var administratorLogin = 'labUser'

@secure()
@description('Auto-generated admin password.')
param administratorLoginPassword string



@description('Creates a HorizonDB Cluster.')
resource horizonDb 'Microsoft.HorizonDb/clusters@2026-05-01-preview' = {
  name: clusterName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    createMode: 'Create'
    vCores: vCores
    replicaCount: replicaCount
    version: postgresVersion
    // Enable integrated AI Model Management
    //aiModelManagement: 'Enabled'
    aiModelManagement: 0 // 0 to Enable
  }
}