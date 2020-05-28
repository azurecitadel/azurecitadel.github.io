---
title: "Automation with Azure Identities "
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, user, service, security, principal ]
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: Short series of labs for automating the creation of Azure service principals and managed identities, and then common use cases for those security principals
---

## Introduction

The Azure Active Directory (AAD) service is the key source of identity for Azure and the applications running on the cloud platform. This set of labs is not intended to cover the full range of functionality and integrations that are available with AAD. There are lengthier training sessions available that can cover that.

Instead we will focus on identities and how you can automate their creation and how you can then use those security identities in your automated processes.

We will cover:

* Types of security principals
    * Directory Accounts
    * Guest Accounts
    * Service Principals
    * Managed Identities
* RBAC roles in AAD, RBAC roles in Azure, API permssions for App Registrations
* Creating service principals and storing client secrets
* Creating custom RBAC roles
* Adding API permissions to App Registrations
* Creating user and system Managed Identities
* Getting tokens for REST API calls

----------

## Pre-requisites

You will need to be the Global Administrator for your AAD tenant to fully complete these labs. The recommendation is to get a Visual Studio subscription and ensure that you create a new tenant by using a Microsoft Live ID, e.g. richard.cheney@outlook.com.

As with all of the labs in the automation category, we recommend setting up your machine as per the [automation prereqs](../prereqs) page.

For these labs I have assumed you have a linux terminal (e.g. WSL2) with a Bash shell and core binaries such as az, jq and curl.

A good working knowledge of the Azure services and ecosystem has been assumed.

----------

## Labs

### Core Labs

**Lab** | **Name** | **Description**
1 | [Users & Groups](users) | The Azure security principals for users
2 | [Service Principals & Managed Identities](sp&mi) | Security principals for applications and trusted compute
3 | [RBAC](rbac) | RBAC models for AAD & Azure
4 | [Creating service principals](lab4) | Create a service principal for Terraform, and another using a Azure Key Vault secret
5 | [Custom RBAC role](lab5) | Management and data plane actions in custom RBAC definitions
6 | [API permissions](lab6) | Enable a service principal to access the Microsoft Graph or the legacy AAD API
7 | [Managed Identities](lab7) | Create and use managed identities
