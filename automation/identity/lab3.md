---
title: "RBAC Models and API Permissions"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, RBAC, api, principal ]
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: The RBAC model used in Azure Active Directory and the one used in Azure, plus API permissions for Microsoft Graph etc.
---

## Introduction

In this lab we will show how to authenticate to Azure with different security principals. We are going to do some low level REST API calls using curl on linux

But before we get to that, let's understand a little about the role based access control in AAD and Azure.

## RBAC in AAD

OK, so  point number one is that the RBAC in Azure and the RBAC in Azure Active Directory are separate. You can be the Global Administrator in AAD without being a subscription owner and vice versa.

CLick on the [Roles & Administrators](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RolesAndAdministrators) in Azure Active Directory.

![Roles & Administrators](/automation/identity/images/rolesAndAdministrators.png)

Here you can see the various built in roles for AAD. The most important roles in here are:

* Global Administrator
* User Administrator
* Billing Administrator

> You can also add custom roles in AAD, but only if you have Azure AD Premium P1 or P2.

Click on the User Administrator role and then Description in the Manage section of the blade and you will see the [Role Permissions](https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/RoleMenuBlade/RoleDescription/objectId/fe930be7-5e62-47db-91af-98c3a49a38b1/roleName/User%20administrator/roleTemplateId/fe930be7-5e62-47db-91af-98c3a49a38b1/adminUnitObjectId//customRole//resourceScope/%2F).

![User Administrator](/automation/identity/images/userAdministrator.png)

Here you can see the list of actions that the role deinition permits. It interacts with a number of APIs:

* microsoft.directory
* microsoft.azure.serviceHealth
* microsoft.azure.supportTickets
* microsoft.office365.webPortal
* microsoft.office365.serviceHealth
* microsoft.office365.supportTickets

What is notably missing is the Azure Resource Manager endpoint, <https://management.azure.com>. This is handled by the ARM RBAC roles covered in the next section.

If you want to understand more about how the RBAC roles work with each other then the [Classic subscription administrator roles, Azure RBAC roles, and Azure AD administrator roles](https://docs.microsoft.com/azure/role-based-access-control/rbac-and-directory-admin-roles?context=azure/active-directory/users-groups-roles/context/ugr-context) documentation page is recommended reading.

### Elevated Access Permissions

You may see doc pages that mention the AAD Global Admin using elevated privileges. This grants you the User Access Administrator role in Azure Resource Manager at the root level (/).

An example use case is temporarily elevating a Global Admin so that they can assign an Owner to a subscription, or to provide the ability to create management groups.

This toggle is found at the bottom of the [AAD Properties](https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties):

![Elevated Access](/automation/identity/images/elevatedAccess.png)

There is more info on the [elevated access](https://docs.microsoft.com/en-gb/azure/role-based-access-control/elevate-access-global-admin) page.

## RBAC in Azure Resource Manager

Text.

## Acquiring Tokens

### User authentication via REST API

Text.

### Service Principal via CLI

Text.

### Managed Identity accessing Azure Key Vault

Text.

## Summary

We have gone through the RBAC models in both AAD and Azure, plus how API permissions can extend the abilities of an App Registration / Service Principal.

In the next section we'll start to automate.

[◄ Lab 2: Service Principals & Managed Identities](../lab2){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 4: Service Principals ►](../lab4){: .btn .btn--primary}
