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
@allowed([
  '17'
  '18'
])
param postgresVersion string = '17'

@description('Number of vCores per node.')
@minValue(2)
@maxValue(192)
param vCores int = 2

@description('Total number of nodes in the pool, including the primary.')
@minValue(1)
@maxValue(16)
param nodeCount int = 2

@description('Admin username for the cluster.')
param administratorLogin string = '@lab.VirtualMachine(Win11-Pro-Base).Username' //LabUser

@secure()
@description('Admin password for the cluster.')
param administratorLoginPassword string = '@lab.VirtualMachine(Win11-Pro-Base).Password'

@description('PostgreSQL extensions to allow on the HorizonDB cluster.')
param allowedExtensions array = [
  'azure_ai'
  'vector'
  'age'
  'pg_diskann'
  'pg_durable'
  'pg_textsearch'
]

@description('PostgreSQL shared_preload_libraries to allow on the HorizonDB cluster.')
param sharedPreloadLibraries array = [
  'age'
  'pg_durable'
  'pg_textsearch'
]

resource horizonDbParameterGroup 'Microsoft.HorizonDb/parameterGroups@2026-10-01-preview' = {
  name: '${clusterName}-parameters'
  location: location

  properties: {
    description: 'Parameter group for ${clusterName}'

    // Enable integrated AI Model Management
    //aiModelManagement: 'Enabled'
    //aiModelManagement: 0 // 0 to Enable

    postgreSqlVersion: postgresVersion

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
resource horizonDb 'Microsoft.HorizonDb/clusters@2026-10-01-preview' = {
  name: clusterName
  location: location

  properties: {
    creationMode: 'Create'
    postgreSqlVersion: postgresVersion
    network: {
      publicAccess: 'Enabled'
    }
  }
}

resource horizonDbPasswordAuthentication 'Microsoft.HorizonDb/clusters/authentications@2026-10-01-preview' = {
  parent: horizonDb
  dependsOn: [
    horizonDbPool
  ]
  name: 'passwordMethod'
  properties: {
    state: 'Enabled'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource horizonDbPool 'Microsoft.HorizonDb/clusters/pools@2026-10-01-preview' = {
  parent: horizonDb
  name: 'defaultpool'
  properties: {
    computeModel: {
      type: 'Provisioned'
      computeProcessor: 'AMD'
      computeGeneration: 6
      vCores: vCores
    }

    nodeCount: nodeCount
    highAvailability: {
      mode: 'AnyZone' // 'AnyZone' | 'Disabled' | 'ZoneRedundant'
    }
/*
    ParameterGroupAssignmentOnCreateNotSupported,
    Pool creation accepts only the location-scoped default parameter group for the 
    parent cluster's subscription, location, and PostgreSQL version, with an applyMethod of Immediate or PendingReboot. 
    Assign custom parameter groups after creation.

    parameterGroup: {
      parameterGroupResourceId: horizonDbParameterGroup.id
      applyMethod: 'Immediate'
    }
*/
    scheduledMaintenance: {
      maintenanceManagementType: 'System'
    }
  }
}

resource horizonDbFirewallRule 'Microsoft.HorizonDb/clusters/pools/firewallRules@2026-10-01-preview' = {
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
