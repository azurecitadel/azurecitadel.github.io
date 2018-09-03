#!/bin/bash

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


# Grab the Azure subscription ID
subId=$(az account show --output tsv --query id)
[[ -z "$subId" ]] && error "Not logged into Azure as expected."

# Check for existing provider.tf
if [[ -f provider.tf ]] 
then
  echo -n "The provider.tf file exists.  Do you want to overwrite? [Y/n]: "
  read ans
  [[ "${ans:-Y}" != [Yy] ]] && exit 0
fi

sname="terraform-${subId}-sp"
name="http://${sname}"

# Create the service principal
echo "az ad sp create-for-rbac --name \"$name\"" | yellow
spout=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subId" --name "$sname" --output json)

# If the service principal has been created then offer to reset credentials
if [[ "$?" -ne 0 ]]
then
  echo -n "Service Principal already exists. Do you want to reset credentials? [Y/n]: " 
  read ans
  if [[ "${ans:-Y}" = [Yy] ]]
  then spout=$(az ad sp credential reset --name "$name" --output json)
  else exit 1
  fi 
fi

[[ -z "$spout" ]] && error "Failed to create / reset the service principal $name" 

# Echo the json output 
echo "$spout" | yellow

# Derive the required variables
clientId=$(jq -r .appId <<< $spout)
clientSecret=$(jq -r .password <<< $spout)
tenantId=$(jq -r .tenant <<< $spout)

echo -e "\nWill now create a provider.tf file.  Choose output type." 
PS3='Choose provider block type: '
options=("Populated azurerm block" "Empty azurerm block with environment variables" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Populated azurerm block")
      cat > provider.tf <<-END-OF-STANZA 
	provider "azurerm" {
	  subscription_id = "$subId"
	  client_id       = "$clientId"
	  client_secret   = "$clientSecret"
	  tenant_id       = "$tenantId"
	}
	END-OF-STANZA

      echo -e "\nPopulated provider.tf:" 
      cat provider.tf | yellow
      echo 
      break
      ;;
    "Empty azurerm block with environment variables")
      echo "provider \"azurerm\" {}" > provider.tf
      echo -e "\nEmpty provider.tf:" 
      cat provider.tf | yellow
      echo >&2

      export ARM_SUBSCRIPTION_ID="$subId"
      export ARM_CLIENT_ID="$clientId"
      export ARM_CLIENT_SECRET="$clientSecret"
      export ARM_TENANT_ID="$tenantId"
     
      echo "Copy the following environment variable exports and paste into your .bashrc file:" 
      cat <<-END-OF-ENVVARS | cyan
	export ARM_SUBSCRIPTION_ID="$subId"
	export ARM_CLIENT_ID="$clientId"
	export ARM_CLIENT_SECRET="$clientSecret"
	export ARM_TENANT_ID="$tenantId"
	
	END-OF-ENVVARS
      break
      ;;
    "Quit")
      exit 0
      ;;
    *) echo "invalid option $REPLY";;
  esac
done

echo "To log in as the Service Principal then run the following command:"
echo "az login --service-principal --username \"$clientId\" --password \"$clientSecret\" --tenant \"$tenantId\"" | cyan

exit 0
