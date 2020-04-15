---
title: "Security Principals"
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
excerpt: Directory accounts, guest accounts, service principals, app registrations and managed identities.
---

## Introduction

Azure uses the identities in Azure Active Directory (AAD) for authentication, role based access control, and integrations with third party applications and platforms.

This page will quickly run through the various types of security principals available in AAD and how they are commonly used.

* Directory Accounts
* Guest Accounts
* Service Principals
* Managed Identities

We will also cover object IDs, app IDs, app registrations, authentication and tokens.

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

## Service Principals

![Service Principals](/automation/identity/images/servicePrincipal.png)

Service Principals are the security identities that we use within services or applications when you want to have specific access rather than authenticate the user and make use of their access levels.

Here are a few common use cases:

* CI/CD pipelines within DevOps
* configuration management software such as Terraform, Packer, Ansible, etc.
* bespoke applications

When you create a service principal you create both an app registration and the service principal belonging to it:

![App Registrations and Service Principals](/automation/identity/images/appRegistrationAndServicePrincipal.png)

Let's quickly create a service principal on the CLI using the defaults:

```bash
az ad sp create-for-rbac --output json
```

Take a copy of the resulting JSON output. Here is an example:

```json
{
  "appId": "1ad9914d-4ff6-425b-adb9-400ff4f95cd9",
  "displayName": "azure-cli-2020-04-15-09-02-09",
  "name": "http://azure-cli-2020-04-15-09-02-09",
  "password": "0692e349-c682-465f-b0f6-9f5d653a4916",
  "tenant": "ce508eb3-7354-4fb6-9101-03b4b81f8c54"
}
```

The command has generated a name for the service principal based on the UTC timestamp. If documentation mentions the "client ID" then that is synonymous with the appId. Likewise, the password is also known as the "client secret".

> It is important to protect these credentials to prevent unauthorised access.
>
> (This service principal has already been deleted, otherwise this would be a serious security faux pas.)

Open the [portal](https://portal.azure.com), search on App Registrations and then find the app you just created:

![App Registration](/automation/identity/images/appRegistration.png)

Everything at this level is application developer related, from authentication, secrets and tokens through to using and exposing APIs and specifying the redirect URL.

Click on the _Managed application in local directory_ link, shown in the red box:

<img src="/automation/identity/images/enterpriseApplication.png" alt="Enterprise Application" width="700"/>

Here you can see the service principal in the Enterprise Application screens.

Note that the App Registration and the Service Principal have their own objectIds, but that they are linked by the appId, which is also known as the client ID.

> There are a number of options here that we will not be changing, including linking the service principal to specific users. Browse the Properties, Owners, Users and Groups and Self Service if you want to see the options here.

We have one more thing to look at in the portal before moving to the CLI commands. Search for Subscriptions, select your active subscription and then _Access control (IAM)_ in the blade. Click on the Role Assignments tab and filter the type to _Apps_ and the scope to _This resource_.

![Contributor](/automation/identity/images/contributor.png)

Creating the service principal with the Azure CLI command's defaults has also assigned a Contributor role at the subscription scope. This is a very generous default and we will look at being more selective in the [RBAC lab](./lab2).

The size of the AAD directory in larger organisations can lead to slow execution of `az ad sp list` commands. You can make use of oData filters so speed up those commands. Here is a rather long example that lists all service principals beginning with azure-cli. It showcases an oData match (_eq_) combined with a _startswith_ before selecting output keys with a JMESPATH query.

```bash
az ad sp list --filter "servicePrincipalType eq 'Application' and startswith(displayName, 'azure-cli')"  --query "[].{name:displayName, appId:appId, objectId:objectId}" --output table
```

Example output:

```text
Name                           AppId                                 ObjectId
-----------------------------  ------------------------------------  ------------------------------------
azure-cli-2020-04-15-09-02-09  1ad9914d-4ff6-425b-adb9-400ff4f95cd9  b715264b-1323-49e6-b4db-47ccd1aa2ab3
```

If you want to remove the service principal then issue the following command, changing the app's name to match your own:

```bash
az ad sp delete --id "http://azure-cli-2020-04-15-09-02-09"
```

> The value for the `--id` argument can be the service principal name or the object ID.

## Managed Identities

![Managed Identities](/automation/identity/images/managedIdentity.png)

A managed identity is actually a variant on a service principal. In the last section we said that service principals are used by applications, whereas managed identities can be used by trusted compute in Azure, such as virtual machines, virtual machine scale sets and containers.

> The previous name for managed identities was managed service identity. You may still see MSI used as an initialism in some of the older doc pages or blog posts, or for command line switches.

Managed identities solve an age old problem in starting the trust chain. With service principals we have to authenticate using the password or client secret before we can get our token and get the access we need. It is common to stored it as a secret in a key vault.

But how are you then starting the authentication process and validating access to read a key vault secret? We're back to square one.

This is where managed identity comes in. The managed identity is granted the correct access to resources as per normal. But it is also linked to the Azure compute resource, which is trusted. Rather than getting a token from a traditional authentication process, the managed identity gets the token from the Azure Instance Metadata Service (IMDS). More detail on this in the next lab.

Also be aware that there are two types of managed identity, User and System:

* **System** The managed identity is linked to the lifecycle of the compute, so it is generated when the compute is instantiated, and it is removed if the compute is deleted
* **User** The managed identity is created as a separate step, much like a standard service principal, and is then associated with compute to establish the trust relationship

## Summary

OK, so now you should have a better understanding of the various service principals in Azure, the use cases they are designed for and how they differ in terms of User Principal Names, App IDs and the processes to acquire tokens.

In the next section we'll cover the RBAC models in AAD and Azure, and then the API permissions that you can assign to your service principals.

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: RBAC & API Permissions ►](../lab2){: .btn .btn--primary}
