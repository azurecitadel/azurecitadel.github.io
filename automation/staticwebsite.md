---
title: Static websites and azcopy
date: 2019-01-07
author: Richard Cheney
tags: [ azure, azcopy, web ]
category: automation
comments: true
hidden: true
published: false
header:
  teaser: /images/teaser/code.png
  overlay_image: images/header/arm.png
excerpt: Create a static website in storage and then copy to another region using azcopy
---

## Introduction

This small and quick lab showcases some of what you can do with azcopy, as well as the simplicity of hosting static website content in an Azure storage account.

I wrote it for a partner following a query, and then promptly hid it away from the categories. (This is why it is rather no frills compared to much of the content on this site.)

If you have static website content and negligible site traffic then this is a quick and inexpensive way of hosting it on Azure.

> **NOTE THAT THIS DOES NOT WORK IN WSL - REVERT TO SAS TOKEN BASED AND TEST BEFORE PUBLISHING**

## Required

The following steps have been checked on the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about) with both [az](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) and [azcopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux) v10 or newer installed.

## Initial Steps

If you haven't already done so, login to Azure with both the az and azcopy tools.

<pre class="command-line language-bash" data-prompt="$"><code>
az login
azcopy login
az account show
</code></pre>

Authenticating with `azcopy login` uses OAuth against your AAD account and azcopy then uses the token to access the storage accounts. Note that this is not required when using SAS tokens.

Add the preview storage commands to the CLI.

<pre class="command-line language-bash" data-prompt="$"><code>
az extension add --name storage-preview
</code></pre>

Create the resource group and add the Storage Blob Data Contributor role.

<pre class="command-line language-bash" data-prompt="$"><code>
az group create --name staticwebsite --location westeurope
az role assignment create --role ba92f5b4-2d11-453d-a403-e96b0029c9fe --resource-group staticwebsite --assignee richeney@microsoft.com
</code></pre>

Specify your user login as the `--assignee` value.

## Unique names

The storage account names need to be globally unique. Set the values of the $src and $dst variables to something that should be unique.

<pre class="command-line language-bash" data-prompt="$"><code>
subId=$(az account show --output tsv --query id)
prefix=$(whoami | tr '[:upper:]' '[:lower:]')
suffix=$(/usr/bin/md5sum <<< $subId | cut -c1-10)
src=${prefix}src${suffix}
dst=${prefix}dst${suffix}
</code></pre>

## West Europe storage account

Create the v2 storage account, store the key

<pre class="command-line language-bash" data-prompt="$"><code>
az storage account create --name $src --resource-group staticwebsite --location westeurope --kind StorageV2 --sku Standard_LRS
srckey=$(az storage account keys list --account-name $src --resource-group staticwebsite --query "[1].value" --output tsv)
</code></pre>

## North Europe storage account

Repeat for North Europe.

<pre class="command-line language-bash" data-prompt="$"><code>
az storage account create --name $dst --resource-group staticwebsite --location northeurope --kind StorageV2 --sku Standard_LRS
dstkey=$(az storage account keys list --account-name $dst --resource-group staticwebsite --query "[1].value" --output tsv)
</code></pre>

## Copy a sample HTML webpage locally

<pre class="command-line language-bash" data-prompt="$"><code>
git clone https://github.com/richeney/azure101-webapp-html
rm -fR azure101-webapp-html/.git
rm azure101-webapp-html/.gitignore
cd azure101-webapp-html
</code></pre>

## Create the static website in the source storage account

<pre class="command-line language-bash" data-prompt="$"><code>
az storage container create --name \$web --account-name $src --account-key $srckey
azcopy cp ~/azure101-webapp-html/ https://$src.blob.core.windows.net/\$web/ --recursive
az storage blob service-properties update --account-name $src --static-website --404-document 404.html --index-document index.html
az storage account show --name $src --output tsv --query primaryEndpoints.web
</code></pre>

The last line shows the static web page endpoint. Copy into your browser to check that the page is working.

## Copy the files recursively from one storage account to another

<pre class="command-line language-bash" data-prompt="$"><code>
az storage container create --name \$web --account-name $dst --account-key $dstkey
azcopy cp "https://$src.blob.core.windows.net/\$web/" "https://$dst.blob.core.windows.net/\$web/"  --recursive
az storage blob service-properties update --account-name $dst --static-website --404-document 404.html --index-document index.html
az storage account show --name $dst --output tsv --query primaryEndpoints.web
</code></pre>

Check that the destination storage account's static website is up.

Done!

## References

<https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10>
<https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website>
