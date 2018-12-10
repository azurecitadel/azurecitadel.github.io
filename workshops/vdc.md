---
layout: article
title: Virtual Data Centre Workshop
date: 2017-09-12
categories: workshops
#permalink: /vdc/
tags: [vdc, virtual, data, centre, pre-reqs]
comments: true
featured: true
excerpt: The Virtual Data Centre (VDC) lab provides a theoretical overview and hands on lab to take the learner through the key constructs that are recommended for larger enterprise customers deploying to Azure.
author: Richard_Cheney
image:
  feature: featured/corp2.jpg
  teaser: Education.jpg
  thumb:
---
Ovewview and pre-requisites for the Virtual Data Centre (VDC) workshop.

{% include toc.html %}

## Introduction

The Virtual Data Centre (VDC) lab provides a theoretical overview and hands on lab to take the learner through the key constructs that are recommended for larger enterprise customers deploying to Azure.

## VDC Workshop Topics

* Deploy the VDC lab
* Explore the VDC environment
* Configure VDC routing with NVAs and UDRs
* Secure VDC with NSGs and Policies
* Monitor VDC with Network Watcher and Azure Monitor
* Role Based Access Control in a hub and spoke topology

## Pre-requisites

The workshop requires the following:

* **[Azure Subscription]({{ site.url }}/guides/subscription)**
    * If your workshop is being hosted by a Microsoft Cloud Solution Architect (CSA) then you will be provided with a code for an **Azure Pass** subscription
    * Open a **private** (in-private / incognito) browser session
    * Go to <http://signup.live.com> and create a new  Microsoft account in  **vdc._firstname.lastname_@outlook.com** format
    * Go to <https://www.microsoftazurepass.com> (still within a private session)
    * Ensure that you log in using your new email (*Sign In* is top right)
    * Follow the instructions to redeem the code and activate your Azure Pass
* If you will be using you own subscription (e.g. Visual Studio Enterprise) then you can confirm that the subscription is valid for the workshop by checking the following in the portal:
    * prove the ability to create resources by creating a new resource group
    * check there are no stringent Virtual Machine or CPU quotas in Subscriptions -> Usage + Quotas
    * within Azure Active Directory, create a test user and group
* Common pitfalls to avoid:
    * Free Trial accounts may have a CPU quota that is insufficient for the lab environment deployment to successfully complete
    * Redeeming an Azure Pass code against an email address previously used for a trial will succeed, but the activation will fail
    * Using a work email may mean that you do not have write access to the company's directory and therefore you cannot create users and groups
* **Cloud Shell**
    * In the Azure [portal](https://portal.azure.com), click on the Cloud Shell icon at the top of the screen (**>_**), create the storage account for clouddrive and confirm it is working by typing ```az account show```
    * [Bash and CLI 2.0]({{ site.url }}/guides/wsl) (optional, recommended, only applicable for Windows 10)

## Labs

The setup for the lab has been updated, and the labs have been fully migrated into the Azure Citadel organisation.  Here are the individual lab sections:

Lab | Section | Description
 | [Setup](/workshops/vdc/setup/) | Deploy the base lab environment using a few Azure CLI commands
1 | [Explore](/workshops/vdc/lab1/) | Explore and understand the starting point for the lab environment
2 | [Configure](/workshops/vdc/lab2) | Configure a S2S VPN, base Cisco CSR config, UDRs and vNet peering settings
3 | [Secure](/workshops/vdc/lab3) | Secure the environment using NSGs, Azure Security Center and Azure Policies
4 | [Monitor](/workshops/vdc/lab4) | Use Network Watcher and analyse NSG Flow Logs
5 | [RBAC](/workshops/vdc/lab5) | Create users and groups, allocate roles to scopes.  And clean up the lab!
