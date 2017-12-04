---
layout: article
title: 'ARM Lab 2: Parameter files, resources'
date: 2017-11-17
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab1-firstTemplate
  title: Creating your first template
next:
  url: ../arm-lab3-moreComplex
  title: Utilising more complex functions 
---

{% include toc.html %}

## Overview

In this lab we will create a template from some of the major sources of resource type information to speed up the templating process and enable infrastructure as code deployments for some of the newer or more exotic services available on the Azure platform.

We'll take a manual deployment of Cosmos DB into a new resource group, and export the template and parameter file just prior to submission. We can determine which parameters we want to be user defined (with defaults and permitted values).  

We will then create collections etc. within the Cosmos DB blade in the portal.  Once that is done we will export the resouce group definition as a JSON template, and use that in combination with the ARM reference documentation to create our final template and parameter file pair.

## Manual Cosmos DB portal steps

**Follow the steps below, but make sure you stop just prior to submission via the final 'Create' button.**

* Open the Azure [portal(https://portal.azure.com)]
* Click **+ Add** on the left
* Search for "Azure Cosmos DB"
* Select and click on Create
  * ID: **\<yourname>cosmosdb**
  * API: **SQL**
  * Resource Group: Create New, called **lab2**
  * Location: **West Europe**

**_DO NOT CLICK ON THE CREATE BUTTON!_** Click on the _Automation Options_ link instead.

This will open up the template that the portal has created on the fly.  If you tab through the Template, Parameters, CLI, PowerShell, .NET and Ruby tabs then you will see the two JSON templates, plus deployment code for the various CLIs and key SDKs.

Let's copy out the template and parameter file into our project.

## Factoring the initial Cosmos DB template


