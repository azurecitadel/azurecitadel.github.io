---
layout: article
title: Azure 101
date: 2017-08-29
categories: null
permalink: /azure101/
tags: [azure, 101, index, content]
comments: true
author: Richard_Cheney`
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
Introduction to the Authoring ARM Templates workshop.

{% include toc.html %}

## Introduction
The Azure 101 session is intended as an introductory training for technical learners who have had little to no experience with Azure public cloud.

The aim is to familiarise the student with some of the most commonly used IaaS and PaaS services in Azure, and the portal and CLI interfaces available to drive them.

In terms of orientation, the trainer may use slides to help give an overview of some of the other services available within Azure, and the training will also make the student aware of some of the documentation and training resources available to them as they continue to explore.

Allow five hours for a full session including all of the labs.  

## Quick navigate for labs:
* [**LAB: Portal customisation, resource groups, vNets and subnets, documentation resources**](./azure101PortalLab.md/#introduction)
* [**LAB: Windows and Linux VMs, customising NSGs, defining Availability Sets**](./azure101VMLab.md/#introduction)
* [**LAB: Deploying to Web Apps from a local Docker repository**](./azure101WebAppLab.md/#introduction)
* [**LAB: Using Logic Apps with the Twitter API**](./azure101LogicAppLab.md/#introduction)

## Pre-requisites
The workshop requires the following:
* [Azure Subscription](../prereqs/prereqSubscription.md)
* [Bash and CLI 2.0](../prereqs/prereqLxss.md) (optional, only for Windows 10)
* [Azure Modules for PowerShell](../prereqs/prereqPowershell.md) (optional, recommended for existing PowerShell users)
* [Visual Studio Code](../prereqs/prereqVscode.md) (optional)
* A Twitter account (optional, recommended)

## Content
The below sections are PowerPoint content unless specified otherwise
1. Azure Intro
    * Cloud drivers and key Azure principles
    * Scale and compliancy
    * Rate of change, services and open source
2. Infrastructure Services
    * Compute options
    * Networking fundamentals
    * [**LAB: Portal familiarisation and customisation, resource groups, vNets and subnets, documentation resources**](./azure101PortalLab.md/#introduction)
    * Storage and RBAC principles
    * [**LAB: Windows and Linux VMs, customising NSGs, defining Availability Sets**](./azure101VMLab.md/#introduction)
3. Lunch
4. Application & Platform Services
    * Responsibilities: Traditional v IaaS v PaaS v SaaS
    * Web Apps, Mobile Apps, etc
    * Functions and Logic Apps
5. DevOps & Automation
    * CI/CD
    * Toolchains
    * Monitoring and Insight
6. [**LAB: Deploying to Web Apps from a local Docker repository**](./azure101WebAppLab.md/#introduction)
7. Data and Analytics
    * Hadoop, HDinsight and Data Lake
    * SQL DB, Data Warehouse and Managed Instance
    * MySQL, PostgreSQL and CosmosDB
    * Cortana Intelligence Suite, Cognitive Services, Machine Learning and IoT Suite
8. [**LAB: Using Logic Apps with the Twitter API**](./azure101LogicAppLab.md/#introduction)
9. Self-training and options for future enablement sessions