---
layout: article
title: CLI 2.0 JMESPATH
date: 2017-10-04
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
previous: ./cli-2-firststeps
next: ./cli-4-scripting
---
WORK IN PROGRESS

{% include toc.html %}

## Introduction 

The ```--query``` switch is one of the "global" switches, i.e. it is available on every az command, and it enables you to query and filter the output of the command.  

It uses the industry standard JMESPATH query format that is used not only by the Azure CLI 2.0, but also the AWS CLI and other commands  that need to manipulate JSON. 

There is some excellent documentation on JMESPATH at the official site, and it covers the full range of what can be accomplished.  This guide will give you a shortcut into the commonly used functionality when querying Azure JSON output.  

## JSON Format

Here is some example JSON output from an ```az resource list --resource-group <resourceGroup> --output json``` command.  The example resource group below(myAppRG-Staging) contains a single Web App in standard app service plan.

```
[
  {
    "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/serverFarms/MyAppServicePlan",
    "identity": null,
    "kind": "app",
    "location": "westeurope",
    "managedBy": null,
    "name": "MyAppServicePlan",
    "plan": null,
    "properties": null,
    "resourceGroup": "myAppRG-Staging",
    "sku": null,
    "tags": {
      "displayName": "myAppServicePlan"
    },
    "type": "Microsoft.Web/serverFarms"
  },
  {
    "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/sites/MyWebApp-richeney-Staging",
    "identity": null,
    "kind": "app",
    "location": "westeurope",
    "managedBy": null,
    "name": "MyWebApp-richeney-Staging",
    "plan": null,
    "properties": null,
    "resourceGroup": "myAppRG-Staging",
    "sku": null,
    "tags": {
      "displayName": "myWebApp",
      "hidden-related:/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/serverfarms/MyAppServicePlan": "Resource"
    },
    "type": "Microsoft.Web/sites"
  }
]
```

Whilst it may initially look complex, there are only keys, values, and structures.

The structures are split into two types:

1. Arrays, denoted by square brackets
   * Arrays in JSON are ordered lists of value
   * Also known as lists or vectors
   * In Azure that order depends on the context.  It may be based on order, such as with VM NICs, or alphabetically by name, i.e. when listing resource groups
2. Objects, denoted by curly brackets
   * Objects are collections of name:value pairs
   * Also known as keyed lists, dictionaries or hashes 

When arrays and objects contain multiple elements then those elements are separated by commas.

Values may be:
* string
* number
* true
* false
* null
* object
* array

JSON also supports nested objects and arrays nicely.  The elements of a list may simply be unkeyed values (e.g. ['red', 'white', 'blue']), or it may be another structure, i.e. a nested array or object.  You can see this in the example above.

Note that JSON files do not need to be indented to preserve the structure in the way that a YAML file or a Python script do.  However if it is likely to be read by humans then it is common practice to indent the output to reflect the nested levels.  This is also known as pretty printing.  

## Selecting Array Elements

Each of the commands below follow ```az resource list --resource-group myAppRG-Staging --query '<query>' --output json``` format.  Only the query switch will be shown in the table below for the sake of brevity. 

**Query** | **Output**
```--query '[*]'``` | Pass through the whole array
```--query '[]'``` | Flatten the array
```--query '[0]'``` | First entity 
```--query '[-1]'``` | Last entity
```--query '[a:b]'``` | Array slice from a to b-1

If you omit either the a or b value from a slice then the slice array goes to the start or end, e.g. ```'[:2]'``` gives the first two elements (i.e. 0 and 1), whereas ```'[2:]'``` will give all remaining elements from a list, from element 2 onwards.

Compare ```'[0]'``` and ```'[:1]'``` to see a subtle difference.  The former is the object that is the first array element, and therefore starts with curly brackets, whereas the second is an array slice, containing only that same first element, i.e. it still has square brackets surrounding it. 

You can also step through an array using the ```'[a:b:c]'``` notation, but there are few valid reasons where that makes sense in Azure.  Perhaps in slicing the odd and even NICs for a VM with multiple NICs. One additional use is to reverse an array using ```'[::-1]'```.   

You can also slice based on querying the data - see below.

You'll initially see little difference in the ```'[*]'``` and ```'[]'``` queries, but array flattening will make more sense when we shift to filtering at deeper levels.

## Selecting Object Values

Querying on the name for a name:value pair is also simple.  Simply state the name.  Use the ```az account show --query '<query>' --output json``` command to show your active Azure subscription.

**Query** | **Output**
```--query 'name'``` | Cosmetic name for the subscription
```--query 'id'``` | The ID for the subscription
```--query 'user'``` | The user **object** for the subscription
```--query 'user.name'``` | The user **object** for the subscription

The last example above shows a nested value, pulling the value of name in the user object.

When pulling out individual values, the tsv output format will braces and quotes, making it easier to read into a variable.  For example: 

```
username=$(az account show --query 'user.name' --output tsv)
echo $username 
```

## Selective filtering

This is very useful for outputting selected JSON or TSV for scripting purposes, or for being selective on which columns to show in a table.  

List the VMs in one of your resource groups, using ```az vm list --resource-group <resourceGroup> --output table```. 

The table should show all of the VMs, with the name of each server, the resource group and the location.

If you run the same command with ```--output json``` then you will see significantly more information.  If you run ```az vm list --help``` then you'll find there is a ```--show-details``` switch.  It is a little slow but has some additional information which is very useful.

Capture the detailed information into a file using ```az vm list --resource-group <resourceGroup> --show-details --output json > vms.json```.  

If you have [Visual Studio Code](/guides/prereqs/vscode) installed then you can type ```code vms.json``` to open it up in VS Code. (Example <a href="/guides/cli/vms.json" target="json">vms.json file</a>.)

Examine the JSON output to determine the desired information.  In this example we want the VM name, size, OS, private and public IP addresses, and FQDN. 

YOU ARE HERE

```az vm list --output table --query "[*].[name, hardwareProfile.vmSize, storageProfile.osDisk.osType]"```