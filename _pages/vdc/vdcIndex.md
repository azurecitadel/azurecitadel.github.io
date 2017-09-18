---
layout: article
title: Virtual Data Centre Workshop
date: 2017-09-12
categories: workshops
permalink: /vdc/
tags: [vdc, virtual, data, centre, pre-reqs]
comments: true
author: Adam_Raffe
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
Ovewview and pre-requisites for the Virtual Data Centre (VDC) workshop.

{% include toc.html %}

## Introduction
The Virtual Data Centre (VDC) lab provides a theoretical overview and hands on lab to take the learner through the key constructs that are recommended for larger enterprise customers deploying to Azure.     

## VDC Workshop Topics
* Deploy up the VDC lab 
* Explore the VDC environment
* Configure VDC routing with NVAs and UDRs
* Secure VDC with NSGs and Policies
* Monitor VDC with Network Watcher and Azure Monitor
* Role Based Access Control in a hub and spoke topology

## Pre-requisites
The workshop requires the following:
* **[Azure Subscription](../prereqs/prereqSubscription.md)**
  * Confirm that the subscription is valid: 
    * create a resource group (to prove resource creation)
    * go to https://aad.portal.azure.com and create a test user and group
  * If you cannot create resources, ids and groups then request a temporary Azure Pass subscription
    * Note that if you have used a Microsoft account (e.g. first.last@outlook.com) for a free Azure trial before then you will be able to redeem an Azure Pass code, but will not be able to activate it and you will not be able to redeem that same code again
    * Therefore it is recommended to create a vdc.first.last@outlook.com Microsoft account, and use that in a private browser session
    * Go to https://www.microsoftazurepass.com and follow the instructions to redeem and activate your Azure Pass
* **Cloud Shell**
  * In the Azure [portal](https://portal.azure.com), click on the Cloud Shell icon at the top of the screen (**>_**), create the storage account for clouddrive and confirm it is working by typing ```az account show```
* [Bash and CLI 2.0](../prereqs/prereqLxss.md) (optional, recommended, only for Windows 10)
* [Azure Modules for PowerShell](../prereqs/prereqPowershell.md) (optional, recommended for existing PowerShell users)
* [Visual Studio Code](../prereqs/prereqVscode.md) (optional)
* **Acceptance for the Cisco Legal Agreement**
  * This is required in advance, or the ARM templated automated lab deployment during the workshop will not succeed
  * See steps in the [Deploy the Cisco CSR1000V Virtual Appliance](#deploy-the-cisco-csr1000v-virtual-appliance) section below to accept the agreement and then clean up 

## Deploy the Cisco CSR1000V Virtual Appliance

Deploying a third party network virtual appliance (such as the Cisco CSR router used in this lab) programmatically is not possible until you have accepted the legal agreement. At the time of writing, the only way to do this is to create the virtual appliance through the Azure portal and subsequently delete it. You must do this first before attempting to deploy the lab environment through the ARM templates. To do this, follow these steps:

1. Using the Azure portal, click on the 'Add' button on the top left of the screen. Search for 'Resource Group' and then select 'Create'. Name the resource group 'NVA-Legal'.
2. Click the 'Add' button again, but this time search for 'Cisco' - select the option entitled 'Cisco CSR 1000v Deployment with 2 NICs' and then select create
3. Name the virtual machine 'NVA-Legal' and use the username and password labuser / M1crosoft123. Select the resource group you created in step 1 (NVA-Legal).
4. In the next step, select 'storage account' and create a storage account with a unique name (you will receive an error if the name is not unique)
5. Select 'Public IP' and give the IP address any name (e.g. 'test')
6. Assign a unique DNS label (you will receive an error if the name is not unique)
7. Click on 'subnets' and accept the default options
8. Select 'OK' until the virtual appliance starts to deploy. Wait for the deployment to finish.
9. When the virtual appliance deployment has completed, delete the entire 'NVA-Legal' resource group by navigating to the resource group overview and selecting 'Delete'

## Virtual Data Centre Workshop 

The main virtual data centre workshop guide may be found here:
**[https://github.com/Araffe/vdc-networking-lab](https://github.com/Araffe/vdc-networking-lab)**.

The workshop will follow the readme for the hands on lab element, and will also cover the fundamental concepts using the accompanying presentation materials. 