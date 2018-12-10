#!/bin/bash
# Log in to Azure as a service principal if a provider.tf exists

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

[[ ! -f ./provider.tf ]] && error "provider.tf not found"

eval $(grep -E "subscription_id|client_id|client_secret|tenant_id" provider.tf  | tr -d " ")

for var in subscription_id client_id client_secret tenant_id
do
    [[ $(eval "echo \$$var" | wc -c) -ne 37 ]] && error "$var not set correctly from provider.tf"
done

echo "Logging into Azure using populated provider.tf"
az login --service-principal --username $client_id --password $client_secret --tenant $tenant_id
az account set --subscription $subscription_id --output jsonc
