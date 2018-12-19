---
title: Azure 101
date: 2017-08-29
author: Richard Cheney
category: fundamentals
tags: [azure, 101]
comments: true
featured: true
excerpt: The Azure 101 session is an instructor led session for technical learners who have had little to no experience with Azure public cloud
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/education.png
excerpt: Learn how to use Infrastructure as Code with Azure Resource Manager template deployments.
sidebar:
  nav: "azure101"
featured: true
---
{% include toc.html %}

## Introduction

The Azure 101 session is intended as an introductory training for technical learners who have had little to no experience with Azure public cloud.

The aim is to familiarise the student with some of the most commonly used IaaS and PaaS services in Azure, and the portal and CLI interfaces available to drive them.

In terms of orientation, the trainer may use slides to help give an overview of some of the other services available within Azure, and the training will also make the student aware of some of the documentation and training resources available to them as they continue to explore.

Allow five hours for a full session including all of the labs.

## Pre-requisites

The workshop requires the following

Pre-req | Required | Comment
<a href="/prereqs/subscription" target="_blank">Azure Subscription</a> | Required |
<a href="/prereqs/wsl" target="_blank">Bash & CLI 2.0</a> | Optional | Windows 10 only, recommended for power users
<a href="/prereqs/powershell" target="_blank">Azure Powershell Modules</a> | Optional | Recommended for existing PowerShell users
<a href="/prereqs/vscode" target="_blank">Visual Studio Code</a> | Optional |

Please confirm that your Azure subscription is working correctly _before_ the session:

* Browse to [Azure Portal](http://portal.azure.com)
* Authenticate to confirm your credentials are working correctly
* Click on the '**+ New**' in the left hand pane
* Search for 'Resource Group' and select it
* Click Create and use the following parameters
    * Resource Group Name: **Azure101IaaS**
        * The name should show a green tick once you move way from the text box
    * Subscription: \<your subscription name>
    * Resource Group Location: **West Europe**
* Click on Create

If the resource group is successfuly deployed then your subscription has sufficient permissions for the Azure 101 workshop.

## Labs

Lab | Description
<a href="/fundamentals/azure101/portal/" target="_blank">Portal & vNets</a> | Learn and customise the Azure portal, and create vNets and subnets
<a href="/fundamentals/azure101/vmquickstart" target="_blank">VM Quickstart</a> | Follow a Quickstart for either Linux or Windows VMs, via the portal, CLI or PowerShell
<a href="/fundamentals/azure101/webapps" target="_blank">Web App Lab</a> | Create a Web App using content pulled from a GitHub repository
<a href="/fundamentals/azure101/logicapps" target="_blank">Logic App Lab</a> | Create a feedback mechanism, HTTP endpoint, conditional emails and logging

## Content

The below sections are [PowerPoint](/fundamentals/azure101/azure101InfraAndAppsPresenterDeck.pptx) content unless specified otherwise

1. Azure Intro
    * Cloud drivers and key Azure principles
    * Scale and compliancy
    * Rate of change, services and open source
2. Infrastructure Services
    * Compute options
    * Networking fundamentals
    * **LAB: Portal familiarisation and customisation, resource groups, vNets and subnets, documentation resources**
    * Storage and RBAC principles
    * **LAB: Windows and Linux VMs, customising NSGs, defining Availability Sets**
3. Lunch
4. Application & Platform Services
    * Responsibilities: Traditional v IaaS v PaaS v SaaS
    * Web Apps, Mobile Apps, etc
    * Functions and Logic Apps
5. DevOps & Automation
    * CI/CD
    * Toolchains
    * Monitoring and Insight
6. **LAB: Deploying to Web Apps from a GitHub repository**
7. Data and Analytics
    * Hadoop, HDinsight and Data Lake
    * SQL DB, Data Warehouse and Managed Instance
    * MySQL, PostgreSQL and CosmosDB
    * Cortana Intelligence Suite, Cognitive Services, Machine Learning and IoT Suite
8. **LAB: Using Logic Apps to create a feedback API**
9. Self-training and options for future enablement sessions