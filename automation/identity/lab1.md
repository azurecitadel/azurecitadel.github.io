---
title: "Users and Groups"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, user, group, security, principal ]
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: Directory accounts, guest accounts, and security groups
---

## Introduction

Azure uses the identities in Azure Active Directory (AAD) for authentication, role based access control, and integrations with third party applications and platforms.

This page and the next will quickly run through the various types of security principals available in AAD and how they are commonly used.

* Directory Accounts
* Guest Accounts
* Service Principals
* Managed Identities

We will also mention object IDs, app IDs, app registrations, authentication and tokens as these will be covered in more depth in later labs

## Directory Accounts

![Directory Account](/automation/identity/images/directoryAccount.png)

Directory accounts are the key security principals used by people as opposed to applications or trusted compute. If someone talks about user accounts or member accounts on Azure then they will be talking about an AAD directory account. If you look in the [portal](https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/UsersManagementMenuBlade/AllUsers) then you can see the accounts with user type of Member:

![Directory Account](/automation/identity/images/directoryAccounts.png)

As you can see in the screen shot, you can have member accounts with a source of Azure Active Directory or as Microsoft Accounts. (Select _Columns_ in the ellipsis (...) menu to add the Object IDs column.)

Usually you will have a proper directory with a validated custom domain suffix, e.g. richard.cheney@_microsoft.com_. However, if you have created a directory using a Microsoft Account then you will have an auto-generated domain. For this directory I used a lighthousecustomer@outlook.com Microsoft Account and the generated tenant is _lighthousecustomer930.onmicrosoft.com_.

You can see the domain for your directory in the Azure Active Directory screen, and also in the tooltips if you hover over your identity at the top right:

![domain suffix](/automation/identity/images/directoryDomainSuffix.png)

You can also see the tenant ID here. All of the security principals have a unique objectId and exist within that tenantId.

You can list out the users using CLI commands:

```bash
az ad user list --query "[].{name:displayName, objectId:objectId}" --output table
```

Example output:

```text
Name                 ObjectId
-------------------  ------------------------------------
Joe                  d3c6ea16-62a8-41d2-88c3-a094edfcbd69
Lighthouse Customer  6d189e88-be28-49be-96bc-0dbe8728e467
User Access Admin    26f7d6a8-8792-48fd-94a6-f7806fc9a500
```

You can also see details for the current signed in user. For the example command below I have signed in as the Joe user.

```bash
az ad signed-in-user show --output jsonc
```

Here is the output, filtered using the [JMESPATH](https://azurecitadel.com/prereqs/cli/cli-3-jmespath/) query, `--query "{name:displayName, objectId:objectId, userPrincipalName:userPrincipalName}"`.

```json
{
  "name": "Joe",
  "objectId": "d3c6ea16-62a8-41d2-88c3-a094edfcbd69",
  "userPrincipalName": "joe@lighthousecustomeroutloo930.onmicrosoft.com"
}
```

So this is Joe's UPN and objectId within the tenantId.

You can pull the tenantId from the `az account show` output:

```azurecli
az account show --output tsv --query tenantId
```

Example output:

```text
ce508eb3-7354-4fb6-9101-03b4b81f8c54
```

> Strictly speaking the tenantId here relates to the subscriptionId rather than the user, but it is _usually_ the same...

You will all be familiar with the process to log on to Azure and authenticate via [aka.ms/devicelogin](https://aka.ms/devicelogin). This is how you gain the token.

OK, that will do for the basics on directory accounts. We'l
l return to them briefly in the next lab when we look in more detail at the authentication process and tokens.

## Guest Accounts

![Guest Account](/automation/identity/images/guestAccount.png)

Guest users are directory accounts in one tenancy that have been invited into another tenant. In the Users screen you add on `+ New Guest User` and then invite them via the magic of AAD B2B (business to business). This is a far better way to add access to your resources for a person who works in another organisation as they will authenticate using their normal ID and authentication factors and leverage SSO, password rotation, B2B etc. effectively.

> It is not good practice to create directory accounts in your tenant for people who work for other organisations as then there are then multiple identities, passwords etc. It introduces risk, e.g. if simple non-rotated passwords are used or if access is not cleaned up once it is no longer needed.

<img src="/automation/identity/images/inviteGuestUser.png" alt="Invite GuestUser" width="700"/>

The invited user will then have an email sent to their UPN.  That will take them through to the portal using the directory explicit format <https://portal.azure.com/#@lighthousecustomeroutloo930.onmicrosoft.com> (note the domain suffix) where they authenticate using their normal ID and authentication factors and then provide consent.

<img src="/automation/identity/images/guestAccountConsent.png" alt="Guest Account Consent" width="300"/>

You can then see the invited user show up as a Guest user type linked to an External Azure Active Directory.

![Guest User](/automation/identity/images/guestUserInAllUsers.png)

So this approach is ideal for proper business to business interactions, for instance a service integrator requiring access for the duration of a project. (You can also explore [Azure Lighthouse](/automation/lighthouse) to provide access in this scenario, as well as for managed services.)

Here I have logged in as that invited user, and switched to the right subscription.

```bash
az account set --subscription 9a52c25a-b883-437e-80a6-ff4c2bccd44e
az account show --output jsonc
```

Example output:

```json
{
  "environmentName": "AzureCloud",
  "homeTenantId": "ce508eb3-7354-4fb6-9101-03b4b81f8c54",
  "id": "9a52c25a-b883-437e-80a6-ff4c2bccd44e",
  "isDefault": true,
  "managedByTenants": [],
  "name": "Lighthouse Customer Subscription",
  "state": "Enabled",
  "tenantId": "ce508eb3-7354-4fb6-9101-03b4b81f8c54",
  "user": {
    "name": "richeney@azurecitadel.com",
    "type": "user"
  }
}
```

So the tenantId is correct, and the user.name is richeney@azurecitadel.com. Everything looks as you would expect. But let's check the signed in user output:

```text
az ad signed-in-user show --query "{name:displayName, objectId:objectId, userPrincipalName:userPrincipalName}" --output jsonc
```

Example output:

```json
{
  "name": "Richard Cheney (Citadel)",
  "objectId": "db45c0b1-5b75-4743-93b3-bf46b5cb64cf",
  "userPrincipalName": "richeney_azurecitadel.com#EXT#@lighthousecustomeroutloo930.onmicrosoft.com"
}
```

There are a couple of points to make here:

1. The B2B process has created a completely new objectId under the inviter's tenantId
1. The UPN above is not richeney@azurecitadel.com; it is an auto-generated UPN that reflects both the invitee's UPN and the inviter's domain suffix

Most of the time that level of detail is irrelevant, but in certain scenarios (e.g. [Partner Admin Link](https://aka.ms/partneradminlink)) then that is a really important distinction.

## Security Groups

OK, so they are the key security principals for users. Before moving on to the security principals we use for applications and compute, let's briefly mention security groups as they are another security objectId that we can use in role assignments.

![Security Group](/automation/identity/images/securityGroup.png)

When you create a new group in AAD then you have the choice of Security or Office 365. Select security as the type, and then add owners and members. We can see the resulting objectId for that entity.

<img src="/automation/identity/images/vmadminsObjectId.png" alt="Virtual Machine Admins" width="700"/>

You can also pull the objectId using the CLI:

```bash
az ad group show --group "Virtual Machine Admins" --query objectId --output tsv
```

Example output:

```text
54a6edbb-5c88-421c-8e26-4721dbf4f686
```

OK, let's go past users and groups to service principals and managed identities.

## Summary

OK, so now you should have a better understanding of the security principals used for users and groups in Azure.

In the next section we'll look at the security principals used for applications and trusted compute.

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: Service Principals & Managed Identities ►](../lab2){: .btn .btn--primary}
