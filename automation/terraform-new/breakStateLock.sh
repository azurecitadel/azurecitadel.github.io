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

yellow() { tput setaf 3; cat - ; tput sgr0; return; }
cyan()   { tput setaf 6; cat - ; tput sgr0; return; }

# Check the backend exists, grab the parameters and check the values are valid
[[ ! -f backend.tf ]] && error "backend.tf does not exist"
eval $(grep -E "storage_account_name|container_name|key|access_key" backend.tf  | tr -d " ")

[[ -z "$storage_account_name" ]] && error "storage_account_name not defined in backend.tf"
[[ -z "$container_name" ]]       && error "container_name not defined in backend.tf"
[[ -z "$key" ]]                  && error "key not defined in backend.tf"
[[ -z "$access_key" ]]           && error "access_key not defined in backend.tf"

# Export environment variables for storage CLI commands

export AZURE_STORAGE_ACCOUNT=$storage_account_name
export AZURE_STORAGE_KEY=$access_key

# Check the current blob lease is locked

state=$(az storage blob show --container-name $container_name --name $key --query properties.lease.status --output tsv)
[[ "$state" != "locked" ]] && error "Expected state to be locked. Current state is $state."

# Break the lease

echo "az storage blob lease break --container-name $container_name --blob-name $key" | yellow
az storage blob lease break --container-name $container_name --blob-name $key

[[ $? -ne 0 ]] && error "Failed to break lock"

## Output the current status

echo "az storage blob show --container-name $container_name --name $key --query properties.lease" | yellow
az storage blob show --container-name $container_name --name $key --query properties.lease

exit 0
