 
az login 
export subscriptionId="YOUR SUBSCRIPTION ID"
az account set --subscription $subscriptionId

az deployment sub create -l westeurope -f ./bicep/main.bicep

if [ $? -ne 0 ]; then
  echo "Deployment failed" 
  exit 1
fi


# Get client ID 
export identityName="uaid-myapp"
clientId=$(az identity show -g "rg-workload-identity" --name $identityName --query clientId -o tsv)
principalId=$(az identity show -g "rg-workload-identity" --name $identityName --query principalId -o tsv)

az aks get-credentials --resource-group rg-workload-identity --name wli-aks --overwrite-existing

echo "Client ID: $clientId"
helm upgrade wli-myapp ./Helm_Charts/wli-myapp/ -f ./Helm_Charts/wli-myapp/values.nodejs.yaml --set serviceAccount.clientId=$clientId --install

# Set Postgres connection info
export PGHOST=wli-posgres.postgres.database.azure.com
export PGUSER="YOUR ENTRA ADMIN USERNAME"
export PGDATABASE=postgres 

# Get access token for Postgres
access_token=$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken)

# Set password to access token 
export PGPASSWORD=$access_token

echo "Access token was required. Trying to connect with user $PGUSER"

# Connect to Postgres to create user for the identity with its principal ID
psql "host=$PGHOST dbname=$PGDATABASE user=$PGUSER password=$PGPASSWORD" -c "select * from pgaadauth_create_principal_with_oid('$identityName', '$principalId', 'service', false, false);"
