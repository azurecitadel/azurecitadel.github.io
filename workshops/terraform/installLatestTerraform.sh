#!/bin/bash

error()
{
  if [[ -n "$@" ]]
  then
    tput setaf 1
    echo "ERROR: $@" >&2
    tput sgr0
  fi

  [[ -n "$zip" ]] && [[ -f /tmp/$zip ]] && rm /tmp/$zip

  exit 1
}

# Check for zip and jq
_pkgs=""
[[ ! -x /usr/bin/zip ]] && _pkgs="$_pkgs zip"
[[ ! -x /usr/bin/jq ]]  && _pkgs="$_pkgs jq"

if [[ -n "$_pkgs"  ]]
then sudo apt-get update && sudo apt-get install --assume-yes -qq $_pkgs
fi

[[ ! -x /usr/bin/zip ]] && error "Install package \"zip\" and rerun"
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