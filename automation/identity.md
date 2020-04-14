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

**Lab** | **Name** | **Description**
1 | [Security Principals](lab1) | What are the different types of security principals in Azure?
2 | [RBAC and API permissions](lab2) | What are the RBAC models for AAD, Azure and the APIs used by App Registrations? What are tokens?
3 | [Creating service principals](lab3) | Create a service principal for Terraform, and another with its secret in Azure Key Vault
4 | [Custom RBAC role](lab4) | Understand management and data planes and the actions available to custom RBAC definitions
5 | [API permissions](lab5) | Enable a service principal to access the Microsoft Graph or the legacy AAD API
6 | [Managed Identities](lab6) | Create and use managed identities
