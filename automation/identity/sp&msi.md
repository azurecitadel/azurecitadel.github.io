---
title: "Service Principals and Managed Identities"
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
excerpt: Service principals for applications, including the relationship with app registrations, plus managed identities for trusted compute.
---

## Introduction

In the previous page we looked at standard user principals, including directory accounts and guest accounts, plus security groups.

This page will run through the other types of security principals available in AAD and how they are used:

* Service Principals
* Managed Identities

We will also cover object IDs, app IDs, app registrations, authentication and tokens.

## Service Principals

<img alt="Service Principal" src="/automation/identity/images/servicePrincipal.png" class="powerpoint"/>

Service Principals are the security identities that we use within services or applications when you want to have specific access rather than authenticate the user and make use of their access levels.

Here are a few common use cases:

* CI/CD pipelines within DevOps
* configuration management software such as Terraform, Packer, Ansible, etc.
* bespoke applications

When you create a service principal you create both an app registration and the service principal belonging to it:

<img alt="App Registrations & Service Principals" src="/automation/identity/images/appRegistrationAndServicePrincipal.png" class="powerpoint"/>

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

**It is important to protect these credentials to prevent unauthorised access.**

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

<img alt="Managed Identities" src="/automation/identity/images/managedIdentity.png" class="powerpoint"/>

A managed identity is actually a variant on a service principal. In the last section we said that service principals are used by applications, whereas managed identities can be used by trusted compute in Azure, such as virtual machines, virtual machine scale sets and containers.

> The previous name for managed identities was managed service identity. You may still see MSI used as an initialism in some of the older doc pages or blog posts, or for command line switches.

Managed identities solve an age old problem in starting the trust chain. With service principals we have to authenticate using the password or client secret before we can get our token and get the access we need. It is common to stored it as a secret in a key vault.

But how are you then starting the authentication process and validating access to read a key vault secret? We're back to square one.

This is where managed identity comes in. The managed identity is granted the correct access to resources as per normal. But it is also linked to the Azure compute resource, which is trusted.

How does the managed identity acquire its token? Rather than having to use a secret or go through a traditional authentication process, the managed identity grabs the token from the Azure Instance Metadata Service (IMDS).

Also be aware that there are two types of managed identity, User and System:

* **System** The managed identity is linked to the lifecycle of the compute, so it is generated when the compute is instantiated, and it is removed if the compute is deleted
* **User** The managed identity is created as a separate step, much like a standard service principal, and is then associated with compute to establish the trust relationship

## References

* <https://docs.microsoft.com/azure/active-directory/develop/>
* <https://docs.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals>
* <https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/>
* <https://docs.microsoft.com/azure/virtual-machines/linux/instance-metadata-service>

## Summary

OK, so now you should have a better understanding of the various service principals in Azure, the basic use cases they are designed for.

In the next section we'll cover the RBAC models in AAD and Azure.

[◄ Users and Groups](../users){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [RBAC ►](../rbac){: .btn .btn--primary}
