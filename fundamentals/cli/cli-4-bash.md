---
layout: article
title: CLI 2.0 and Bash Scripting
date: 2017-10-04
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
previous:
  url: ../cli-3-jmespath
  title: Using JMESPATH Queries
next:
  url: ../..
  title: Back up to Guides
---
{% include toc.html %}

## Introduction 

CLI 2.0 works really nicely when integrated with Bash scripting.  This page will work through a number of examples to show some techniques.  

Many of the commands below require the ```--resource-group``` switch.  If that is not shown then it is using my default, set using ```az configure```.  The resource group can always be made explicit using the --resource-group switch.

## Using variables in commands

This is one of the simplest things to do.

```bash
rg=myResourceGroup
az resource list --resource-group $rg --output table
```

## Setting variables using CLI 2.0 output

Bash supports variables and simple arrays.  (For multi-level and name:value based objects then Perl and Python would be more useful.)

#### Variables
  
The example below finds the public IP address for a specific VM.

```bash
pip=$(az vm list --show-details --output tsv --query "[?name == 'vmName'].publicIps")
echo $pip
```

With multi-word variables we can use these within simple loops.  The first command returns a white-space delimited list of the resource groups that are not within my default region.  It then loops over those, showing a table of the resources for each, using sed to indent it a little for readability.

```bash
rgs=$(az group list --output tsv --query "[?location != 'westeurope'].name")
for rg in $rgs
do
  echo -e "\nResource Group: $rg\n"
  az resource list --output table --resource-group $rg | sed 's/^/  /g'
done
```

Many CLI 2.0 commands accept multi-word strings as an argument.  One of those is the ```--ids``` switch for the ```az vm stop``` command. 
  
The VMs in my example resource group In the example below we are using a compound filter to select the ids of the VMs that are a) running and b) do not have an environment tag set to production.  And then we'll shut them down.

```bash
ids=$(az vm list --show-details --query "[?tags.environment != 'production' && powerState == 'VM running'].id" --output tsv)
az vm stop --ids $ids
```

#### Arrays

Again, array assignments can be completed in one command:

```bash
rgArray=($(az group list --output tsv --query "[?location != 'westeurope'].name"))
echo ${rgArray[0]}
echo ${rgArray[*]}
echo ${#rgArray[*]}
```

The first command sets an array of the resource group names.  The others print out the first array element, all of the elements, and finally the number of elements.

####  Handling command substitution in queries

As the JMESPATH queries are passed as a single string, the choice of delimiter is important.  Using double quotes at either end is usually the safest approach.  For instance:

```bash
env=preprod; key=name
az vm list --query "[?tags.environment == '$env'].$key" --output tsv
```

## Storage SAS Token example

This final section shows one example of JMESPATH queries in use.  It is a short piece of Bash code to generate a storage SAS token that permits access to a storage blob for the next 30 minutes.  Without the full URL the storage blob woiuld be inaccessible, assuming the permissions are set to deny public access by default.  

```bash
blob=azuredeploy.json
container=templates
expiry=$(date '+%Y-%m-%dT%H:%MZ' --date "+30 minutes")

export accountName=$(az storage account list --resource-group ExampleResourceGroup --query [0].name --output tsv)
storageAccountKey=$(az storage account keys list --account-name $accountName --resource-group ExampleResourceGroup --query [0].value --output tsv)
sasToken=$(az storage blob generate-sas --account-name $accountName --account-key $storageAccountKey --container-name templates --name azuredeploy.json --permissions r --expiry $expiry --output tsv)
shortURL=$(az storage blob url --container-name $container --name $blob) 
fullURL=$shortURL?$sasToken
echo $fullURL
```

The full URL could be used in this context to deploy an ARM template stored in blob storage.

Once the 30 minutes period has expired then the template would remain inaccessible, even with the full URL.  This is a common way of storing templates in a publically accessible location whilst maintaining control over when they are accessed and by whom.
