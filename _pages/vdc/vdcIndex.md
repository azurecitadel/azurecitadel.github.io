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
* [Bash and CLI 2.0](../prereqs/prereqLxss.md) (optional, only for Windows 10)
* [Azure Modules for PowerShell](../prereqs/prereqPowershell.md) (optional, recommended for existing PowerShell users)
* [Visual Studio Code](../prereqs/prereqVscode.md)
* **Acceptance for the Cisco Legal Agreement**
  * This is required in advance, or the ARM templated automated lab deployment during the workshop will not succeed
  * See steps in the section below to manually Deploy the Cisco CSR1000V Virtual Appliance, accept the agreement and then clean up 

Note that the Role Based Access Control (RBAC) section of the lab requires write access to Azure AD (i.e. Microsoft.Authorization/*/Write access).  Yiou may test this by going to https://aad.portal.azure.com and confirming that you can create users and groups.

## Deploy the Cisco CSR1000V Virtual Appliance

Deploying a third party network virtual appliance (such as the Cisco CSR router used in this lab) programmatically is not possible until you have accepted the legal agreement. At the time of writing, the only way to do this is to create the virtual appliance through the Azure portal and subsequently delete it. You must do this first before attempting to deploy the lab environment through the ARM templates. To do this, follow these steps:

1) Using the Azure portal, click on the 'Add' button on the top left of the screen. Search for 'Resource Group' and then select 'Create'. Name the resource group 'NVA-Legal'.
2) Click the 'Add' button again, but this time search for 'Cisco' - select the option entitled 'Cisco CSR 1000v Deployment with 2 NICs' and then select create
3) Name the virtual machine 'NVA-Legal' and use the username and password labuser / M1crosoft123. Select the resource group you created in step 1 (NVA-Legal).
4) In the next step, select 'storage account' and create a storage account with a unique name (you will receive an error if the name is not unique)
5) Select 'Public IP' and give the IP address any name (e.g. 'test')
6) Assign a unique DNS label (you will receive an error if the name is not unique)
7) Click on 'subnets' and accept the default options
8) Select 'OK' until the virtual appliance starts to deploy. Wait for the deployment to finish.
9) When the virtual appliance deployment has completed, delete the entire 'NVA-Legal' resource group by navigating to the resource group overview and selecting 'Delete'

## Virtual Data Centre Workshop 

The main virtual data centre workshop may be found here:
**[https://github.com/Araffe/vdc-networking-lab](https://github.com/Araffe/vdc-networking-lab)**.

The workshop will follow the readme for the hands on lab element, and will also cover the fundamental concepts using the accompanying presentation materials. 


