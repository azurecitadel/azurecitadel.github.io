---
layout: article
title: 'ARM Lab 1: First Template and Deployment'
date: 2017-11-17
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
previous:
  url: ../theoryTemplates
  title: Azure Resource Manager Templates
next:
  url: ../arm-lab2-functions
  title: Utilising more complex functions 
---

{% include toc.html %}

## Overview

In this lab we will be creating a simple template using Visual Studio Code.  We will then be deploying it into a resource group using Azure CLI 2.0.  We will then factor some of the resource's values up into the parameters section.

## Pre-reqs

Before we start, let's check your configuration.

First of all you will need a working [Azure subscription](/guides/prereqs/subscription).

For this lab we will be using Visual Studio Code, and it is assumed that you have configured it as per the [VS Code prereqs](/guides/prereqs/vscode) page:
* Visual Studio Code
* Git working in Command Prompt
* Either CLI 2.0 (az) installed in Windows, or Azure PowerShell Modules (or both) 
* Bash on Ubuntu (Windows Subsystem for Linux) installed for Windows 10 users, with git and az (optional, recommended)
* VS Code extensions installed (ARM and CLI)
* ARM snippets
* Integrated Console chosen 

## Create the azuredeploy.json template

Let's create an empty ARM JSON file in Visual Studio Code using the snippets.  
<video video width="800" height="600" autoplay loop>
  <source type="video/mp4" src="/workshops/arm/images/lab1-1-createTemplate.mp4"></source>
  <p>Your browser does not support the video element.</p>
</video>
1. Open your working folder, e.g. C:\myTemplates (CTRL-K, CTRL-O)
2. Create a folder called _lab1_
3. Create a file called _azuredeploy.json_
4. In the body of the file, type `arm!` and hit enter
5. CTRL-S to save

Note that if you have any syntax errors then you will see some red highlighting in the scrollbar area.  

Visual Studio Code denotes unsaved files with a dot in the tab at the top. Once you have saved the file then this will disappear.  Individual file windows can be closed with CRTL-W. 

> Typing `arm!` brings in one of the JSON snippets you should have installed as part of the prereqs.  You can find the JSON snippets used in ARM templates in File \| Preferences \| User Snippets. 

You should now have the empty JSON file:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [],
    "outputs": {}
}
```

The theory section on [ARM templates](../theoryTemplates) explains the various sections. Remember that in JSON the curly brackets (`{}`) are objects, containing name:value pairs, whilst the square brackets (`[]`) are unkeyed lists.

## Add a storage account resource

Let's add a simple storage account resource into the empty list:
<video video width="800" height="600" autoplay loop>
  <source type="video/mp4" src="/workshops/arm/images/lab1-2-addStorageAccount.mp4"></source>
  <p>Your browser does not support the video element.</p>
</video>
1. Hit enter within the resource list
2. Type `arm-stg` to add in the storage account snippet
3. Change the value used for the storage account name (as it needs to be globally unique) and the display text
4. CRTL-S to save

> The snippet is setup to automatically select both instances of StorageAccount1 using the Select All Occurrences mode (CTRL-F2) is automatically switchd on.  This accelrates the refactoring.  Pressing ESC untoggles the Select All Occurrences mode. Feel free to search the json.json user snippet file and find the ${StorageAccount1} strings.

Your ARM template should now look something like this, but with a different (and hopefully unique) storage account name.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts",
            "name": "richeneysa",
            "apiVersion": "2015-06-15",
            "location": "[resourceGroup().location]",
            "tags": {
                "displayName": "richeneysa"
            },
            "properties": {
                "accountType": "Standard_LRS"
            }
        }
    ],
    "outputs": {}
}
```

Note that we will come back to ensuring the uniqueness of certain values.

## Deploy the template with PowerShell

### Open up the Integrated Console and login to Azure

* Open up the Integrated Console using CRTL-' (or View \| Integrated Console)
* Type `Login-AzureRmAccount` to launch the dialog window
* Switch to it using ALT-TAB and authenticate

Once authenticated then you will not need to reauthenticate for a period of time.  

> It has been assumed that you have only one subscription.  If not then use `Select-AzureRmSubscription -SubscriptionName <yourSubscriptionName>`.

### Deploy the template

In the Integrate Console, create a new resource group called 'lab1' and then deploy the azuredeploy.json template into it.

```powershell
New-AzureRmResourceGroup -Name lab1 -Location "West Europe"
New-AzureRmResourceGroupDeployment -Name job1 -ResourceGroupName lab1 -TemplateFile c:\\MyTemplates\\lab1\\azuredeploy.json
```
## Deploy the template with CLI

### Open up the Integrated Console and login to Azure

* Open up the Integrated Console using CRTL-' (or View \| Integrated Console)
* Type `az login` and follow the instructions

> Note that you can double click on a word to select, and right click to copy the selected text

Once authenticated then you will not need to reauthenticate for a period of time.  

> It has been assumed that you have only one subscription.  If not then use `az account set --subscription <yourSubscriptionName>`.

### Deploy the template

In the Integrate Console, create a new resource group called 'lab1' and then deploy the azuredeploy.json template into it.

```bash
az group create --name lab1 --location "West Europe"
az group deployment create --name job1 --resource-group lab1 --template-file /mnt/c/MyTemplates/lab1/azuredeploy.json 
```

> Note that the filename pathing assumes Linux.  If you are using the CLI within PowerShell then use the native Windows pathing, e.g. c:\\MyTemplates\\lab1\\azuredeploy.json.  Please convert any filenames in subsequent CLI examples.

## Validation

Check the  



