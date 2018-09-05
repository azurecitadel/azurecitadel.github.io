#!/bin/bash

error()
{
  if [[ -n "$@" ]]
  then
    tput setaf 1
    echo "ERROR: $@" >&2
    tpu sgr0
  fi

  [[ -n "$zip" ]] && [[ -f /tmp/$zip ]] && rm /tmp/$zip

  exit 1
}

# Install zip if not there
[[ ! -x /usr/bin/zip ]] && sudo apt-get --assume-yes -qq install zip
[[ ! -x /usr/bin/zip ]] && error "Install package \"zip\" and rerun"

# Install jq if not there
[[ ! -x /usr/bin/jq ]] && sudo apt-get --assume-yes -qq install jq
[[ ! -x /usr/bin/jq ]] && error "Install package \"jq\" and rerun"

# Determine latest file using the API
latest=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
dir=https://releases.hashicorp.com/terraform/$latest
zip=terraform_${latest}_linux_amd64.zip

# Download the zip file
echo "Downloading $dir/$zip ..." >&2
curl --silent --output /tmp/$zip $dir/$zip

if [[ "$(cd /tmp; sha256sum $zip)" != "$(curl -s $dir/terraform_${latest}_SHA256SUMS | grep $zip)" ]]
then
  error "Downloaded zip does not match SHA256 checksum value - removing"
else
  echo "Extracting terraform executable ..." >&2
  unzip -oq /tmp/$zip terraform -d /tmp && rm /tmp/$zip
fi

echo "Moving terraform executable to /usr/local/bin with elevated privileges..." >&2

sudo bash <<"EOF"
mv /tmp/terraform /usr/local/bin/terraform
chown root:root /usr/local/bin/terraform
chmod 755 /usr/local/bin/terraform
EOF

/usr/local/bin/terraform -version