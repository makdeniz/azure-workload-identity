@description('Specifies the location for resources.')
param location string = resourceGroup().location
param userAssignedIdentiyName string = 'uaid-myapp'
param aksIssuerURL string

resource userAssignedIdentities 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: userAssignedIdentiyName
  location: location
}

resource userAssignedIdentities_uaid_myapp_name_FederatedCredentialForMyApp 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-07-31-preview' = {
  parent: userAssignedIdentities
  name: 'FederatedCredentialFor${userAssignedIdentiyName}'
  properties: {
    issuer: aksIssuerURL
    subject: 'system:serviceaccount:default:sa-${userAssignedIdentiyName}'
    audiences: [ 'api://AzureADTokenExchange' ]
  }
}
