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

# Create the azuredeploy.json template

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

> Typing `arm!` brings in one of the JSON snippets you should have added as part of the prereqs.  You can find these in File \| Preferences \| User Snippets. 

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

Let's add a simple storage account resource into the empty list:

**<<INSERT A VIDEO HERE>>**

1. Hit enter within the resource list
2. Type `arm-stg` to add in the storage account snippet
3. Change the values for the storage account name (as it needs to be globally unique) and the display text
4. CRTL-S to save

> We will come back to managing unique names later in the labs.



