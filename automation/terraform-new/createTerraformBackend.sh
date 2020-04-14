#/bin/bash

error()
{
  if [[ -n "$@" ]]
  then
    tput setaf 1
    echo "ERROR: $@" >&2
    tput sgr0
  fi

  exit 1
}

# Set default values

export AZURE_STORAGE_AUTH_MODE=login

rg=tfstate
loc=westeurope
prefix=$(echo ${1:-tfstate} | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')

# Grab the Azure subscription ID
# Doesn't have to be the same as the one accessed by a service principal
subId=$(az account show --output tsv --query id)
[[ -z "$subId" ]] && error "Not logged into Azure as expected."

# Check we're logged in as a user principal
upn=$(az ad signed-in-user show --query userPrincipalName --output tsv)
[[ -z "$upn" ]] && error "Must be logged in as a user principal."

# Create the resource group

echo "az group create --name $rg --location $loc" >&2
az group create --name $rg --location $loc --output jsonc >&2
[[ $? -ne 0 ]] && error "Failed to create resource group $rg"

# If the resource group already contains a storage account name starting with that prefix then use it, else create

saName=$(az storage account list --resource-group $rg --query "[?starts_with(name, '"${prefix}"')]|[0].name" --output tsv)
if [[ -z "$saName" ]]
then
  saName=$(echo "${prefix}$(tr -dc "[:lower:][:digit:]" < /dev/urandom | head -c 10)" | cut -c 1-24)
  echo "az storage account create --name $saName --kind StorageV2 --access-tier hot --sku Standard_LRS --resource-group $rg --location $loc" >&2
  az storage account create --name $saName --kind StorageV2 --access-tier hot --sku Standard_LRS --resource-group $rg --location $loc --output jsonc >&2
  [[ $? -ne 0 ]] && error "Failed to create storage account $saName"
fi
saId=$(az storage account show --name $saName --query id --output tsv)

# Become Storage Blob Data Owner on the storage account

echo "az role assignment create --role \"Storage Blob Data Owner\" --assignee $upn --scope $saId" >&2
az role assignment create --role "Storage Blob Data Owner" --assignee $upn --scope $saId >&2
[[ $? -ne 0 ]] && error "Could not add Storage Blob Data Owner role"

## # Grab the storage account key
## 
## saKey=$(az storage account keys list --account-name $saName --resource-group $rg --query "[1].value" --output tsv)
## [[ $? -ne 0 ]] && error "Do not have sufficient privileges to read the storage account access key"

# Create the container 

containerName="tfstate-$subId-$(basename $(pwd))"
## echo "az storage container create --name $containerName --account-name $saName --account-key $saKey" >&2
## az storage container create --name $containerName --account-name $saName --account-key $saKey --output jsonc >&2
echo "az storage container create --name $containerName --account-name $saName" >&2
az storage container create --name $containerName --account-name $saName --output jsonc >&2
[[ $? -ne 0 ]] && error "Failed to create the container $containerName"
containerId="$saId/blobServices/default/containers/$containerName"

# If there is an obvious service principal in the current directory, add Storage Blob Contributor role
# Note that if you are setting up a data backend_remote_state then you'll need to assign Storage Blob Reader to the storage account or container
appId=$(grep --no-messages --no-filename --max-count=1 --extended-regexp "^\s+client_id\s*=" *.tf | awk '{print $NF}' | cut -c2-37)
appId=${appId:-ARM_CLIENT_ID}
if [[ -n "$appId" ]]
then
  objectId=$(az ad sp show --id $appId --query objectId --output tsv)
  echo "az role assignment create --role \"Storage Blob Data Contributor\" --assignee-object-id $objectId --scope $containerId" >&2
  az role assignment create --role "Storage Blob Data Contributor" --assignee-object-id $objectId --scope $containerId >&2
fi

# Creating the backend.tf, using OAuth access version rather than exposing the key

read -r -d'\0' backend <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$rg"  
    storage_account_name = "$saName"
    container_name       = "$containerName"
    key                  = "terraform.tfstate"
  }
}
EOF

echo "$backend"

exit 0
