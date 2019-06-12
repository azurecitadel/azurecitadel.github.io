#!/bin/bash
######################################################
# Utility script to download latest Hashicorp
# binaries and move into /usr/local/bin. Uses their
# releases APIs.
#
# Requires sudo password unless sudoers is configured.
#
# Can be renamed to installLatestTerraform.sh or
# installLatestPacker.sh.  If not then specify
# either terraform or packer as first argument.
######################################################

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

# Grab software name based on either first parameters or the script name

declare -l software

if [[ -n "$1" ]]
then
  software=$1
  [[ "$software"  =~ ^(terraform|packer)$ ]] || error "Argument must be either terraform or packer"
else
  # Derive the software from the script name if it is installLatestTerraform.sh or installLatestPacker.sh
  software=$(basename $0 .sh | sed 's/^installLatest//1')
  [[ "$software"  =~ ^(terraform|packer)$ ]] || error "Usage is \"$(basename $0) terraform|packer\""
fi

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
latest=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/$software | jq -r -M '.current_version')
dir=https://releases.hashicorp.com/$software/$latest
zip=${software}_${latest}_linux_amd64.zip

# Download the zip file
echo "Downloading $dir/$zip ..." >&2
curl --silent --output /tmp/$zip $dir/$zip

if [[ "$(cd /tmp; sha256sum $zip)" != "$(curl -s $dir/${software}_${latest}_SHA256SUMS | grep $zip)" ]]
then
  error "Downloaded zip does not match SHA256 checksum value - removing"
else
  echo "Extracting ${software} executable ..." >&2
  unzip -oq /tmp/$zip $software -d /tmp && rm /tmp/$zip
fi

echo "Moving $software executable to /usr/local/bin with elevated privileges..." >&2

sudo bash <<EOF
mv /tmp/$software /usr/local/bin/$software
chown root:root /usr/local/bin/$software
chmod 755 /usr/local/bin/$software
EOF

# Echo out the version number for confirmation
echo -n "/usr/local/bin/$software -version: "
/usr/local/bin/$software -version

# Warn if another binary is found earlier in the path
if [[ "$(which $software)" != "/usr/local/bin/$software" ]]
then
  echo "WARNING: Additional binary found earlier in your path - $(which $software)"
else
  exit 0
fi
