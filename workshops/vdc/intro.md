---
layout: article
title: "VDC Lab Introduction"
categories: null
date: 2018-07-19
tags: [azure, virtual, data, centre, vdc, hub, spoke, nsg, udr, nva, policy, rbac]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

This lab guide allows the user to deploy and test a complete Microsoft Azure Virtual Data Centre (VDC) environment. A VDC is not a specific Azure product; instead, it is a combination of features and capabilities that are brought together to meet the requirements of a modern application environment in the cloud.

More information on VDCs can be found at the following link:

<https://docs.microsoft.com/en-us/azure/networking/networking-virtual-datacenter>

This is recommended reading as it covers the theory and recommendations from the field for enterprise deployments in Azure, and the documentation also includes a number of additional governance topics and some extended topologies.

## Pre-requisites

Before proceeding with this lab, please make sure you have fulfilled all of the following prerequisites:

* A valid subscription to Azure. If you don't currently have a subscription, consider setting up a free trial (<https://azure.microsoft.com/en-gb/free/>). Please note however that some free trial accounts have been found to have limits on the number of compute cores available - if this is the case, it may not be possible to create the virtual machines required for this lab (6 VMs).
* Access to the Azure CLI 2.0. You can achieve this in one of two ways:
    1. Installing the CLI on the Windows 10 Bash shell (<https://aka.ms/InstallTheAzureCLI>)
    1. Use Cloud Shell in the Azure portal, by either
        * clicking on the ">_" symbol in the top right corner of the portal
        * open a new tab to <https://shell.azure.com>

## Registering the Microsoft.Insights provider

**Some subscription types (e.g. Azure Passes) do not have the necessary resource provider enabled to use NSG Flow Logs. Before beginning the lab, enable the resource provider by entering the following Azure CLI command - this will save time later.**

```bash
az provider register --namespace Microsoft.Insights
```

There is no need to wait for the registration to complete before continuing with the lab set up.  

You can always check on the current status for the provider using this command

```bash
az provider show --namespace Microsoft.Insights --query registrationState --output tsv
```

In the next section we will deploy the base lab environment.

[▲ Index](../#labs){: .btn-subtle} [Lab Setup ►](../setup){: .btn-success}