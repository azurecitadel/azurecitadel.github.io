---
layout: article
title: Azure Arm and DSC Lab Guide
date: 2017-08-14
categories: workshops
author: Adam_Bohle
image:
  feature: Azure101.jpg
  teaser: Education.jpg
  thumb: 
comments: true
---


{% include toc.html %}

## Overviewtest

In this workshop session we are going to construct an ARM template using Visual Studio, this ARM template will build out a simple network topology consisting of a single VNET with two subnets "FrontEndNet" and "DataBaseNet", we will add two Virtual Machines to this configuration to represent the front end Web Server and the backend Database VM. Building on from that we will make use of PowerShell Desired State Configuration (DSC) to set the Windows Guest OS and Application components up to handle the application which we want to run. This will be a simple web store applicaton for demonstraton purposes

Our Goal with this lab exercise is to show you how you can make use of ARM templates to automate the provisioning of your infrastructure and applications. With this knowledge you should feel more empowered to start using tools such as ARM Templates and DSC to enable Infrastructure as Code (IaC) in your projects. Lets get started.

## Pre-Requirements

We are going to need a few things up and running on our workstation in order to complete this lab

* An Azure Subscription
* A laptop or development workstation with the following software installed
    * Visual Studio 2017 Community or Enterprise Edition [Visual Studio Downloads](https://www.visualstudio.com/downloads/)
    * The latest Azure PowerShell cmdlets [Instructions regarding installing Azure PowerShell cmdlets](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0)

**Please Ensure that you reboot your qorkstation after installing the SDK and the PowerShell cmdlets**

### Exercise 1

#### Configure the Automation Account

In order to allow Azure to apply our DSC settings to our Virtual Machines we are going to need to use an Automation Account, the Automation account acts as a repository for our Automation needs in Azure

##### Task 1: Create the Automation Account

1. Browse to the Azure Portal and authenticate at https://portal.azure.com/
2. Click **New** and type **Automation** in the search box. Choose **Automation** from the results