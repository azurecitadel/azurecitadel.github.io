#/bin/bash

error()
{
  if [[ -n "$@" ]] 
  then
    tput setaf 1
    echo "ERROR: $@" >&2
    tpu sgr0
  fi

  exit 1
}

yellow() { tput setaf 3; cat - ; tput sgr0; return; }
cyan()   { tput setaf 6; cat - ; tput sgr0; return; }

# Set default values
rg=tfstate
loc=westeurope

# Grab the Azure subscription ID
subId=$(az account show --output tsv --query id)
[[ -z "$subId" ]] && error "Not logged into Azure as expected."

# Check for existing provider.tf
if [[ -f backend.tf ]] 
then
  echo "The backend.tf file exists:" 
  cat backend.tf | cyan
  echo -n "Do you want to overwrite? [Y/n]: "
  read ans
  [[ "${ans:-Y}" != [Yy] ]] && exit 0
fi


# Create the resource group

echo "az group create --name $rg --location $loc" 
az group create --name $rg --location $loc --output jsonc 
[[ $? -ne 0 ]] && error "Failed to create resource group $rg"

# Create the storage account

saName=tfstate$(tr -dc "[:lower:][:digit:]" < /dev/urandom | head -c 10)
echo "az storage account create --name $saName --kind BlobStorage --access-tier hot --sku Standard_LRS --resource-group $rg --location $loc" 
az storage account create --name $saName --kind BlobStorage --access-tier hot --sku Standard_LRS --resource-group $rg --location $loc --output jsonc
[[ $? -ne 0 ]] && error "Failed to create storage account $saName"

# Grab the storage account key

saKey=$(az storage account keys list --account-name $saName --resource-group $rg --query "[1].value" --output tsv)
[[ $? -ne 0 ]] && error "Do not have sufficient privileges to read the storage account access key"

# Create the container
containerName="tfstate-$subId-$(basename $(pwd))"
echo "az storage container create --name $containerName --account-name $saName --account-key $saKey" 
az storage container create --name $containerName --account-name $saName --account-key $saKey --output jsonc
[[ $? -ne 0 ]] && error "Failed to create the container $containerName"

# Creating the backend.tf


read -r -d'\0' backend <<-EOV
	backend "azurerm" {
	  storage_account_name = "$saName"
	  container_name       = "$containerName"
	  key                  = "terraform.tfstate"
	  access_key           = "$saKey"
	  }
	}
EOV

umask 027
echo "Creating backend.tf:" 
echo "$backend" > backend.tf || error "Failed to create backend.tf"
cat backend.tf | cyan

exit 0
