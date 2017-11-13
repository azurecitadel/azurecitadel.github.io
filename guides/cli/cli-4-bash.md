---
layout: article
title: CLI 2.0 and Bash Scripting
date: 2017-10-04
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
previous.url: ./cli-3-jmespath
previous.title: Using JMESPATH Queries
---
{% include toc.html %}

## Introduction 

CLI 2.0 works really nicely when integrated with Bash scripting.  This page will work through a number of examples to show some techniques.  

Many of the commands below require the ```--resource-group``` switch.  If that is not shown then it is using my default, set using ```az configure```.  The resource group can always be made explicit using the --resource-group switch.

## Using variables in commands

This is one of the simplest things to do.

```
rg=myResourceGroup
az resource list --resource-group $rg --output table
```

## Setting variables using CLI 2.0 output

Bash supports variables and simple arrays.  (For multi-level and name:value based objects then Perl and Python would be more useful.)

* Variables
  
  The example below finds the public IP address for a specific VM.

```
pip=$(az vm list --show-details --output tsv --query "[?name == 'vmName'].publicIps")
echo $pip
```

  With multi-word variables we can use these within simple loops.  The first command returns a white-space delimited list of the resource groups that are not within my default region.  It then loops over those, showing a table of the resources for each, using sed to indent it a little for readability.

```
rgs=$(az group list --output tsv --query "[?location != 'westeurope'].name")
for rg in $rgs
do
  echo -e "\nResource Group: $rg\n"
  az resource list --output table --resource-group $rg | sed 's/^/  /g'
done
```

  Many CLI 2.0 commands accept multi-word strings as an argument.  One of those is the ```--ids``` switch for the ```az vm stop``` command. 
  
  The VMs in my example resource group In the example below we are using a compound filter to select the ids of the VMs that are a) running and b) do not have an environment tag set to production.  And then we'll shut them down.

```
ids=$(az vm list --show-details --query "[?tags.environment != 'production' && powerState == 'VM running'].id" --output tsv)
az vm stop --ids $ids
```

* Arrays

  Again, array assignments can be completed in one command:

```
rgArray=($(az group list --output tsv --query "[?location != 'westeurope'].name"))
echo ${rgArray[0]}
echo ${rgArray[*]}
echo ${#rgArray[*]}
```

The first command sets an array of the resource group names.  The others print out the first array element, all of the elements, and finally the number of elements.

*  Handling command substituion in queries

As the JMESPATH queries are passed as a single string, the choice of delimiter is important.  Using double quotes at either end is usually the safest approach.  For instance:

```
env=test; key=name
az vm list --query "[?tags.environment == '$env'].$key" --output tsv
```

## Storage SAS Token example

The following is an example of generating a storage SAS token and then creating a full URL for the protected blob storage:

```
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




