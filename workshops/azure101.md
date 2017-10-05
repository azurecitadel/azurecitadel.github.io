---
layout: article
title: Azure 101
date: 2017-08-29
categories: workshops
tags: [azure, 101, index, content]
comments: true
author: Richard_Cheney
featured: true
excerpt: The Azure 101 session is intended as an introductory training for technical learners who have had little to no experience with Azure public cloud.
image:
  feature: featured/corp1.jpg
  teaser: Education.jpg
  thumb: 
---
{% include toc.html %}

## Introduction
The Azure 101 session is intended as an introductory training for technical learners who have had little to no experience with Azure public cloud.

The aim is to familiarise the student with some of the most commonly used IaaS and PaaS services in Azure, and the portal and CLI interfaces available to drive them.

In terms of orientation, the trainer may use slides to help give an overview of some of the other services available within Azure, and the training will also make the student aware of some of the documentation and training resources available to them as they continue to explore.

Allow five hours for a full session including all of the labs.  

## Labs

### Cloud Infrastructure and Apps track

Lab | Description
<a href="/labs/portal/" target="_new">Portal & vNets</a> | Learn and customise the Azure portal, and create vNets and subnets
<a href="/workshops/azure101/VMLab" target="_new">VM Quickstart</a> | Follow a Quickstart for either Linux or Windows VMs, via the portal, CLI or PowerShell
<a href="/workshops/azure101/WebAppLab" target="_new">Web App Lab</a> | Create a Web App using content pulled from a GitHub repository
<a href="/workshops/azure101/LogicAppsLab" target="_new">Logic App Lab</a> | Create a feedback mechanism, HTTP endpoint, conditional emails and logging


## Pre-requisites
The workshop requires the following:
* [Azure Subscription](/guides/prereqs/subscription)
* [Bash and CLI 2.0](/guides/prereqs/lxss) (optional, only for Windows 10)
* [Azure Modules for PowerShell](/guides/prereqs/powershell) (optional, recommended for existing PowerShell users)
* [Visual Studio Code](/guides/prereqs/vscode) (optional)
* A Twitter account (optional)
* [Postman](https://www.getpostman.com/)

## Content
The below sections are [PowerPoint](./PresenterDeck.pptx) content unless specified otherwise
1. Azure Intro
    * Cloud drivers and key Azure principles
    * Scale and compliancy
    * Rate of change, services and open source
2. Infrastructure Services
    * Compute options
    * Networking fundamentals
    * [**LAB: Portal familiarisation and customisation, resource groups, vNets and subnets, documentation resources**](./PortalLab/#introduction)
    * Storage and RBAC principles
    * [**LAB: Windows and Linux VMs, customising NSGs, defining Availability Sets**](./VMLab/#introduction)
3. Lunch
4. Application & Platform Services
    * Responsibilities: Traditional v IaaS v PaaS v SaaS
    * Web Apps, Mobile Apps, etc
    * Functions and Logic Apps
5. DevOps & Automation
    * CI/CD
    * Toolchains
    * Monitoring and Insight
6. [**LAB: Deploying to Web Apps from a GitHub repository**](./WebAppLab/#introduction)
7. Data and Analytics
    * Hadoop, HDinsight and Data Lake
    * SQL DB, Data Warehouse and Managed Instance
    * MySQL, PostgreSQL and CosmosDB
    * Cortana Intelligence Suite, Cognitive Services, Machine Learning and IoT Suite
8. [**LAB: Using Logic Apps to create a feedback API**](./LogicAppLab/#introduction)
9. Self-training and options for future enablement sessions