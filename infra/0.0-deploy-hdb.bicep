@description('Location for all resources.')
param location string = resourceGroup().location
// australiaeast,canadacentral,centralus,eastus,germanywestcentral,indiasouthcentral
//,indonesiacentral,japaneast,koreacentral,swedencentral,westus2,westus3,eastus2euap
//,italynorth,polandcentral,uaenorth,uksouth

@description('Unique name for the HorizonDB cluster.')
param clusterName string = 'horizondb-@lab.LabInstance.GlobalId'

@description('Unique name for the Foundry service.')
param foundryName string = 'foundry-@lab.LabInstance.GlobalId'

@description('Unique name for the Foundry Project ervice.')
param foundryProjectName string = '${foundryName}-project'

@description('The version of PostgreSQL to use.')
param postgresVersion string = '17'

@description('Number of vCores per node.')
param vCores int = 2

@description('Number of replicas.')
param replicaCount int = 2

@description('Admin username for the cluster.')
var administratorLogin = '@lab.VirtualMachine(Win11-Pro-Base).Username' //LabUser

@secure()
@description('Admin password for the cluster.')
param administratorLoginPassword string = '@lab.VirtualMachine(Win11-Pro-Base).Password'

@description('PostgreSQL extensions to allow on the HorizonDB cluster.')
param allowedExtensions array = [
  'azure_ai'
  'vector'
  'age'
  'pg_diskann'
  'pg_textsearch'
]

@description('PostgreSQL shared_preload_libraries to allow on the HorizonDB cluster.')
param sharedPreloadLibraries array = [
  'age'
  'pg_textsearch'
]

resource horizonDbParameterGroup 'Microsoft.HorizonDb/parameterGroups@2026-05-01-preview' = {
  name: '${clusterName}-parameters'
  location: location

  properties: {
    description: 'Parameter group for ${clusterName}'
    pgVersion: int(postgresVersion)
    applyImmediately: true

    parameters: [
      {
        name: 'azure.extensions'
        value: join(allowedExtensions, ',')
      }
      {
        name: 'shared_preload_libraries'
        value: join(sharedPreloadLibraries, ',')
      }
    ]
  }
}

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
    //aiModelManagement: 0 // 0 to Enable
    parameterGroup: {
      //applyImmediately: true
      id: horizonDbParameterGroup.id
    }

  }

}

// Reference the default HorizonDB pool
resource horizonDbPool 'Microsoft.HorizonDb/clusters/pools@2026-05-01-preview' existing = {
  parent: horizonDb
  name: 'DefaultPool'
}

// Allow connections from all IPv4 addresses
resource horizonDbFirewallRule 'Microsoft.HorizonDb/clusters/pools/firewallRules@2026-05-01-preview' = {
  parent: horizonDbPool
  name: 'AllowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
    description: 'Allow all IPv4 addresses'
  }
}

@description('Creates a Microsoft Foundry resource.')
resource foundry 'Microsoft.CognitiveServices/accounts@2026-07-01' = {
  name: foundryName
  location: location
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }

  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: foundryName
    publicNetworkAccess: 'Enabled'
    // Allow Foundry projects underneath this resource
    allowProjectManagement: true
  }
}

resource foundryProject 'Microsoft.CognitiveServices/accounts/projects@2026-07-01' = {
  name: foundryProjectName
  parent: foundry
  location: location

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    displayName: foundryProjectName
    description: 'Foundry AI project for HorizonDB'
  }
}

@description('Creates an embedding deployment for the Foundry service.')
resource foundryEmbeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2026-07-01' = {
  name: 'text-embedding-3-small'
  parent: foundry

  dependsOn: [
    foundryProject
  ]

  sku: {
    name: 'GlobalStandard'
    capacity: 3000
  }
  properties: {
    model: {
      // Make the quota higher for the deployment
      name: 'text-embedding-3-small'
      version: '1'
      format: 'OpenAI'
    }
  }
}

@description('Creates a GPT-5.4 chat deployment for the Foundry service.')
resource foundryChatDeployment 'Microsoft.CognitiveServices/accounts/deployments@2026-07-01' = {
  name: 'gpt-5.4'
  parent: foundry

  dependsOn: [
    foundryEmbeddingDeployment
  ]

  sku: {
    name: 'GlobalStandard'
    capacity: 1000
  }
  properties: {
    model: {
      name: 'gpt-5.4'
      version: '2026-03-05'
      format: 'OpenAI'
    }
  }
}

@description('Creates a Cohere reranker deployment.')
resource foundryRerankerDeployment 'Microsoft.CognitiveServices/accounts/deployments@2026-07-01' = {
  name: 'Cohere-rerank-v4.0-fast'
  parent: foundry

  dependsOn: [
    foundryChatDeployment
  ]

  sku: {
    name: 'GlobalStandard'
    capacity: 1500
  }

  properties: {
    model: {
      name: 'Cohere-rerank-v4.0-fast'
      version: '1'
      format: 'Cohere'
    }
  }
}
