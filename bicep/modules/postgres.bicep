@description('Specifies the location for resources.')
param location string = 'westeurope'
param postgres_name string
param whitelistedMyIP string  
param adminUserName string  
param adminUserObjectId string   
@secure()
param administratorLoginPassword string  

resource postgres_name_resource 'Microsoft.DBforPostgreSQL/flexibleServers@2023-06-01-preview' = {
  name: postgres_name
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    replica: {
      role: 'Primary'
    }
    storage: {
      iops: 120
      tier: 'P4'
      storageSizeGB: 32
      autoGrow: 'Disabled'
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    dataEncryption: {
      type: 'SystemManaged'
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Enabled'
      tenantId: subscription().tenantId
    }
    version: '16'
    administratorLogin: 'pgadmin'
    administratorLoginPassword: administratorLoginPassword
    availabilityZone: '3'
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    replicationRole: 'Primary'
  }
}

resource admin 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2023-06-01-preview' = {
  parent: postgres_name_resource
  name: adminUserObjectId
  properties: {
    principalType: 'User'
    principalName: adminUserName
    tenantId: subscription().tenantId
  }
}

resource my_app_database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-06-01-preview' = {
  parent: postgres_name_resource
  name: 'my_app'
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

resource flexibleServers_wli_postgres_name_ClientIPAddress_2024_2_24_17_29_40 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-06-01-preview' = {
  parent: postgres_name_resource
  name: 'ClientIPAddress'
  properties: {
    startIpAddress: whitelistedMyIP
    endIpAddress: whitelistedMyIP
  }
}

resource AllowAllAzureServicesAndResourcesWithinAzureIps 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-06-01-preview' = {
  parent: postgres_name_resource
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}


