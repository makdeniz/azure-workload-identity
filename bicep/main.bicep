@description('Specifies the location for resources.')
param location string = 'westeurope'

targetScope = 'subscription'


resource WorkloadIDentityResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-workload-identity'
  location: location
}

module aksCluster 'modules/aks.bicep' = {
  scope: WorkloadIDentityResourceGroup
  name: 'aks-deployment'
   params: {
    aks_name: 'wli-aks'
   }
}

module postgresQL 'modules/postgres.bicep' = {
  scope: WorkloadIDentityResourceGroup
  name: 'postgresql-deployment'
   params: {
    administratorLoginPassword: 'adminPassword:)'
    whitelistedMyIP: '91.66.107.42'
    postgres_name: 'wli-postgres'
    adminUserName: 'murat@makdenizmsn.onmicrosoft.com'
    adminUserObjectId: 'f3e57f22-4ce6-4177-8fad-9212925f7cc6'
    
   }
}

module identity 'modules/identities.bicep' = {
  scope: WorkloadIDentityResourceGroup
  name: 'identity-deployment'
  params: {
    aksIssuerURL: aksCluster.outputs.oidcIssuerURL
   
  }
}


