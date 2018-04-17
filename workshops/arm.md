---
layout: article
title: Authoring ARM Templates
date: 2018-01-08
categories: workshops
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
featured: true
image:
  feature: 
  teaser: Education.jpg
  thumb: 
excerpt: Learn how to use Infrastructure as Code with Azure Resource Manager template deployments.
---

{% include toc.html %}

## Introduction

This self-paced enablement session will run through a sequence of bite-sized labs that build on each other.

Each lab will always include links to the JSON templates at the start and end so that you may compare your own files and highlight any differences.

It is up to you how far through the labs you need to go.  The labs go through to a level of detail and complexity and leverage a number of the features within the Azure Resource Manager (ARM) templates that provide the power required for more complicated enterprise Infrastructure as Code deployments.

However the advice would always be to keep it as simple as possible and maximise supportability.  Therefore the recommendation is to stop at the earliest point where you can meet the business requirements.

The comments section has been enabled and feedback is always welcome.

The short URL to get back to this page is:

[**aka.ms/citadel/arm**](https://aka.ms/citadel/arm){:target="_blank" class="btn-info"}

## Pre-requisites

You will need a working [Azure subscription](/guides/subscription). Test that the subscription is active by logging onto the [portal](http://portal.azure.com) and creating an resource group.

For the labs we will be using Visual Studio Code, configured as per the [VS Code](/guides/vscode) prereqs page.  Please follow all of those configuration steps to make sure you are ready to begin the labs.

You will need to add in the following extensions to vscode for the ARM workshop:

**Module Name** | **Author** | **Extension Identifier**
Azure Account | Microsoft | [ms-vscode.azure-account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
Azure Resource Manager Tools | Microsoft | [msazurermtools.azurerm-vscode-tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)
JSON Tools | Erik Lynd | [eriklynd.json-tools](https://marketplace.visualstudio.com/items?itemName=eriklynd.json-tools)

Use `CTRL+SHIFT+X` to open the extensions sidebar.  You can search and install the extensions from within there.

Finally, add the snippets for Azure Resource Manager.

1. Browse to the [snippets file](https://raw.githubusercontent.com/sam-cogan/azure-xplat-arm-tooling/master/VSCode/armsnippets.json) and copy the contents
2. In VS Code, go to File -> Preferences -> User Snippets -> JSON
3. Paste in the contents before the last curly brace
4. Ensure the JSON file has no syntax errors and save

**💬 Note.** Do not install the third party Azure Resource Manager Snippets extension available in the gallery.  This only has a subset of the snippets that you will find in Sam Cogan's [GitHub repository](https://github.com/sam-cogan/azure-xplat-arm-tooling/blob/master/VSCode/armsnippets.json).

## Index

Lab | Section | Description
| [Azure Resource Manager](/workshops/arm/theoryARM/) | A short theory session on Azure Resource
| [ARM Templates](/workshops/arm/theoryTemplates/) | Template structure overview, options for creating and deploying
1 | [First Template](/workshops/arm/arm-lab1-firstTemplate/) | Create a simple template, factor parameters, and deploy using the CLIs
2 | [Sources of Resources](/workshops/arm/arm-lab2-sourcesOfResources) | Overview of functions plus sources for resources
3 | [References and Secrets](/workshops/arm/arm-lab3-referencesAndSecrets) | Reference resources, and how to handle secrets
4 | [Conditional Resources](/workshops/arm/arm-lab4-conditionalResources) | Using conditions to selectively deploy resources
5 | [Using Copy](/workshops/arm/arm-lab5-usingCopy) | Use the copy property to create multiple resources
6 | [Objects and Arrays](/workshops/arm/arm-lab6-objectsAndArrays) | More complex parameters, variables and outputs
7 | [Nesting Templates](/workshops/arm/arm-lab7-nestingTemplates) | Nesting templates inline and with linked templates