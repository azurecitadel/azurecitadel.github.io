---
layout: article
title: Securing Workloads in Azure
date: 2018-02-23
categories: workshops
#permalink: /seclab/
tags: [security, azure, infrastructure]
comments: true
featured: true
excerpt: This workshop is focused on securing IaaS and PaaS workloads in Azure.     
author: Adam_And_Tom
image:
  feature: 
  teaser: secure.png
  thumb: 
---
Overview and pre-requisites for the Azure infrastructure workshop.

{% include toc.html %}

## Introduction

This workshop walks the user through a scenario where a fictional organisation (Contoso) has migrated a number of resources to Azure. This migrated environment has not been secured correctly - the lab will walk through the application of a number of security best practices.

## Workshop Topics

* Deploy the security lab environment
* Explore Azure Security Center
* Securing Azure storage
* Securing Azure networking
* Applying "just in time" access to VMs
* Encrypting virtual machines
* Securing Azure SQL databases
* Applying Privileged Identity Management (PIM)

## Prerequisites

The workshop requires the following:

* **[Azure Subscription]({{ site.url }}/guides/subscription)**
  * If your workshop is being hosted by a Microsoft Cloud Solution Architect (CSA) then you will be provided with a code for an **Azure Pass** subscription

  * If you will be using you own subscription (e.g. Visual Studio Enterprise), you will need the ability to create users and groups in the associated Azure Active Directory tenant.

* **Office 365 / EMS License**
  * Your subscription will need to be licensed for Office 365 and Enterprise Mobility and Security; details on how to sign up for a free trial are provided in the main lab guide.

## Azure Infrastructure Security Workshop

The main Azure security workshop guide may be found here:
**[https://github.com/Araffe/azure-security-lab](https://github.com/Araffe/azure-security-lab)**.