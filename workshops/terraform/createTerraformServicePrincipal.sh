#!/bin/bash

error()
{
  [[ -n "$@" ]] && echo "ERROR: $@" >&2
  exit 1
}

# Grab the Azure subscription ID
subId=$(az account show --output tsv --query id)
[[ -z "$subId" ]] && error "Not logged into Azure as expected."

# Check for existing provider.tf
if [[ -f provider.tf ]] 
then
  echo -n "The provider.tf file exists.  Do you want to overwrite? [Y/n]: " >&2
  read ans
  [[ "${ans:-Y}" != [Yy] ]] && exit 0
fi


# Create the service principal
echo "az ad sp create-for-rbac --role=\"Contributor\" --scopes=\"/subscriptions/$subId\" --name \"terraform-$subId\"" >&2
spout=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subId" --name "terraform-$subId" --output json)

# If the service principal has been created then offer to reset credentials
if [[ "$?" -ne 0 ]]
then
  echo -n "Service Principal already exists. Do you want to reset credentials? [Y/n]: " >&2
  read ans
  if [[ "${ans:-Y}" = [Yy] ]]
  then spout=$(az ad sp credential reset --name "http://terraform-$subId" --output json)
  else exit 1
  fi 
fi

[[ -z "$spout" ]] && error "Failed to create / reset the service principal" || echo >&2

# Echo the json output to stderr
jq . <<< $spout >&2 && echo >&2

# Derive the required variables
clientId=$(jq -r .appId <<< $spout)
clientSecret=$(jq -r .password <<< $spout)
tenantId=$(jq -r .tenant <<< $spout)

# Create the provider.tf file
umask 027
echo "provider \"azurerm\" {
  subscription_id = \"$subId\"
  client_id       = \"$clientId\"
  client_secret   = \"$clientSecret\"
  tenant_id       = \"$tenantId\"
}
" > provider.tf

if [[ "$?" -eq 0 ]]
then
  echo "Created provider.tf:"
  sed "s/^/  /g" provider.tf 
  echo
fi >&2

echo -n "Log in as the Service Principal? [Y/n]: " >&2
read ans
if [[ "${ans:-Y}" == [Yy] ]]
then az login --service-principal --username $clientId --password $clientSecret --tenant $tenantId
fi 

exit 0
