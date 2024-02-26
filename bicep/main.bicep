targetScope = 'subscription'

param location string = 'westeurope'
param aks_name string
param postgres_name string
param adminUserName string
param adminUserObjectId string
param myIPAddressToBeWhitelisted string


resource WorkloadIDentityResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-workload-identity'
  location: location
}

module aksCluster 'modules/aks.bicep' = {
  scope: WorkloadIDentityResourceGroup
  name: 'aks-deployment'
   params: {
    aks_name: aks_name
   }
}

module postgresQL 'modules/postgres.bicep' = {
  scope: WorkloadIDentityResourceGroup
  name: 'postgresql-deployment'
   params: {
    administratorLoginPassword: 'adminPassword:)'
    whitelistedMyIP: myIPAddressToBeWhitelisted
    postgres_name: postgres_name
    adminUserName: adminUserName
    adminUserObjectId: adminUserObjectId
    
   }
}

module identity 'modules/identities.bicep' = {
  scope: WorkloadIDentityResourceGroup
  name: 'identity-deployment'
  params: {
    aksIssuerURL: aksCluster.outputs.oidcIssuerURL
   
  }
}


