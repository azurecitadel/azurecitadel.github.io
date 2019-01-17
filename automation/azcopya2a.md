---
title: Static websites and azcopy
date: 2019-01-07
author: Richard Cheney
tags: []
category: automation
comments: true
hidden: true
published: true
header:
  teaser: /images/teaser/code.png
  overlay_image: images/header/arm.png
excerpt: Create a static website in storage and then copy to another region using azcopy
---

## Required

The following steps have been checked using the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about) with both [az](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) and [azcopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux) installed.

## Initial Steps

Login to Azure, create the resource group and add the preview storage commands to the CLI.

<pre class="command-line language-bash" data-prompt="$"><code>
az login
az account show
az group create --name azcopya2a --location westeurope
az extension add --name storage-preview
</code></pre>

## West Europe storage account

Create the v2 storage account, store the key

<pre class="command-line language-bash" data-prompt="$"><code>
az storage account create --name azcopya2asrc --resource-group azcopya2a --location westeurope --kind StorageV2 --sku Standard_LRS
srckey=$(az storage account keys list --account-name azcopya2asrc --resource-group azcopya2a --query "[1].value" --output tsv)
</code></pre>

## North Europe storage account

Repeat for North Europe.

<pre class="command-line language-bash" data-prompt="$"><code>
az storage account create --name azcopya2adst --resource-group azcopya2a --location northeurope --kind StorageV2 --sku Standard_LRS
dstkey=$(az storage account keys list --account-name azcopya2adst --resource-group azcopya2a --query "[1].value" --output tsv)
</code></pre>

## Copy a sample HTML webpage locally

<pre class="command-line language-bash" data-prompt="$"><code>
git clone https://github.com/richeney/azure101-webapp-html
rm -fR azure101-webapp-html/.git
cd azure101-webapp-html
</code></pre>

## Create the static website in the source storage account

<pre class="command-line language-bash" data-prompt="$"><code>
az storage container create --name \$web --account-name azcopya2asrc --account-key $srckey
azcopy --source ~/azure101-webapp-html/ --destination https://azcopya2asrc.blob.core.windows.net/\$web/ --dest-key $srckey --recursive
az storage blob service-properties update --account-name azcopya2asrc --static-website --404-document 404.html --index-document index.html
az storage account show --name azcopya2asrc --output tsv --query primaryEndpoints.web
</code></pre>

The last line shows the static web page endpoint. Copy into your browser to check that the page is working.

## Copy the files recursively from one storage account to another

<pre class="command-line language-bash" data-prompt="$"><code>
az storage container create --name \$web --account-name azcopya2adst --account-key $dstkey
azcopy --source https://azcopya2asrc.blob.core.windows.net/\$web/ --destination https://azcopya2adst.blob.core.windows.net/\$web/ --source-key $srckey --dest-key $dstkey --recursive
az storage blob service-properties update --account-name azcopya2adst --static-website --404-document 404.html --index-document index.html
az storage account show --name azcopya2adst --output tsv --query primaryEndpoints.web
</code></pre>

Check that the destination storage account's static website is up.  Done.