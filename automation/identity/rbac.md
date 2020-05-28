---
title: "RBAC Models"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, RBAC, api, principal ]
toc_depth: 3
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: The RBAC models used in Azure Active Directory and in Azure
---

## Introduction

You now know about the various security principals. Let's understand more about the role based access control in AAD and Azure.

We won't cover the API permissions for you can add to apps to enable access to other APIs such as Microsoft Graph, but this will be covered in a later lab.

If you want to understand more about how the RBAC roles work with each other then the [Classic subscription administrator roles, Azure RBAC roles, and Azure AD administrator roles](https://docs.microsoft.com/azure/role-based-access-control/rbac-and-directory-admin-roles?context=azure/active-directory/users-groups-roles/context/ugr-context) documentation page is recommended reading.

## RBAC in AAD

OK, so  point number one is that the RBAC in Azure and the RBAC in Azure Active Directory are separate. You can be the Global Administrator in AAD without being a subscription Owner and vice versa.

Click on the [Roles & Administrators](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RolesAndAdministrators) in Azure Active Directory.

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

### Elevated Access

You may see doc pages that mention the AAD Global Admin using elevated privileges. This grants you the User Access Administrator role in Azure Resource Manager at the root level (/).

An example use case is temporarily elevating a Global Admin so that they can assign an Owner to a subscription, or to provide the ability to create management groups.

This toggle is found at the bottom of the [AAD Properties](https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties):

![Elevated Access](/automation/identity/images/elevatedAccess.png)

There is more info on the [elevated access](https://docs.microsoft.com/azure/role-based-access-control/elevate-access-global-admin) page.

## RBAC in ARM

The RBAC model in Azure Resource Manager is fine grained and flexible.  It allows you to control which actions a security principal can (and can't do) on any resource.  The default is that you have no access and then create role assignments to permit the correct access.

When you create a role assignment your are defining "who", "what" and "where".

### Object IDs

The "who" in a RBAC role assignment can be any objectId representing a security principal or security group.

In terms of RBAC role assignments we can classify directory accounts and guest user accounts as "Users" as they are managed in the same way.

<img alt="Security Principals" src="/automation/identity/images/securityPrincipals.png" class="powerpoint"/>

At the CLI you can specify all of these using either the objectId or name. (For users this would be the userPrincipalName.)

Example commands to get the objectIds:

**Type** | **Example Command**
User | `objectId=$(az ad signed-in-user show --query objectId --output tsv)`
| `objectId=$(az ad user show --id richeney@microsoft.com --query objectId --output tsv)`
Group | `objectId=$(az ad group show --group "Virtual Machine Admins" --query objectId --output tsv)`
Service Principal | `objectId=$(az ad sp show --id "http://billingreader" --query objectId --output tsv)`
Managed Identity | `objectId=$(az identity show --resource-group identity --name keyVaultSecretReader --query clientId --output tsv)`

### Role Definitions

The "what" in a role assignment is the role definition. In Azure these are very explicit in terms of which REST API actions are allowed and denied. At the time of writing there are 168 built in roles and growing fast:

```bash
az role definition list --query "[?roleType == 'BuiltInRole'].roleName" --output tsv
```

All of these are viewable on the [Azure built-in roles](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles) page which shows the roles in each group and the Actions, NotActions, DataActions and DataNotActions permissions.

Of the in-built roles the four most significant are:

* [Owner](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#owner)
* [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor)
* [Reader](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#reader)
* [User Access Administrator](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator)

> The Owner and User Access Administrator roles are the only ones that have full permissions in Microsoft.Authorization. You have to have one of these roles (or a custom role) to create role assignments.

Other owner, contributor and reader roles follow similar patterns, but for a smaller subset of the resource provider namespaces, e.g. [Virtual Machine Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#virtual-machine-contributor).

Some have dataActions for the PaaS endpoints, e.g. the [Storage Blob Data Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor) role definition. More on that in a later section.

Note that you can create custom role definitions if you cannot get the desired permissions through a combination of the available in-built role definitions.

### Scopes

The "where" for the role assignments are the available scopes in Azure Resource Manager. Every icon in the diagram below is a potential scope point for a role assignment:

<img alt="Scopes" src="/automation/identity/images/scopes.png" class="powerpoint"/>

The default scope for role assignments is the subscription level, but you can specify alternate scopes, such as individual resource groups or resources.

You also have the tenant (also known as the root tenant group) which is the default top level management group, plus any other management groups that you have created.

**Type** | **Example scope**
tenant | `/providers/Microsoft.Management/managementGroups/ce508eb3-7354-4fb6-9101-03b4b81f8c54`
managementGroup | `/providers/Microsoft.Management/managementGroups/7e03c69f-548c-4315-95e6-4214e2123391`
subscription | `/subscriptions/9a52c25a-b883-437e-80a6-ff4c2bccd44e`
resourceGroup | `/subscriptions/9a52c25a-b883-437e-80a6-ff4c2bccd44e/resourceGroups/myRg`
resource | `/subscriptions/9a52c25a-b883-437e-80a6-ff4c2bccd44e/resourceGroups/myRg/providers/Microsoft.Network/virtualNetworks/myVnet`

> The GUID in the tenant management group is the tenantId you see in `az account show`.

Note that the "name" for management groups is really an ID, and can be cosmetic text, numeric or a GUID. (Terraform generates a GUID for the name and that is my preferewnce.) Also the he management groups may be nested but that will not be obvious from the scope string.

Here are some example commands that generate scope IDs:

**Type** | **Example command**
tenant | `tenantId=$(az account management-group list --query "[?displayName == 'Tenant Root Group'].id" --output tsv)`
managementGroup | `mgId=$(az account management-group list --query "[?displayName == '"$mgName"'].id" --output tsv)`
subscription | `subId="/subscriptions/"$(az account show --query id --output tsv)`
resourceGroups | `rgId=$(az group show --name $rgName --query id --output tsv)`
| `rgId=$subid/resourceGroups/$rgName`
resources | `resourceId=$(az storage account show --resource-group $rgName --name $name --query id --output tsv)`
| `resourceId="$rgId/providers/$providerType/$name"`

### Role Assignment

You can [view](https://docs.microsoft.com/azure/role-based-access-control/role-assignments-list-portal) or [create](https://docs.microsoft.com/azure/role-based-access-control/role-assignments-portal) role assignments in the portal, but as we're all about the automation in this category, we'll use the CLI. Let's add ourselves as Storage Blob Contributors in the current subscription.

```bash
objectId=$(az ad signed-in-user show --query objectId --output tsv)
subId="/subscriptions/"$(az account show --query id --output tsv)
az role assignment create --assignee $objectId --role "Storage Blob Data Contributor" --scope $subId
```

> Note that the "name" for roleDefinition is a GUID, but the role assignment create command will take either the _name_ or the _roleName_ as the argument for the `--role` switch.
>
> The value for the `--assignee` may be a UPN or a service principal name (e.g. "http://billingreader")

Check the role assignment in the subscription IAM screens.

Remember that role assignments are hereditary, so the advice is to avoid assigning generous permissions at the higher levels. Always work on the principle of least privilege. This diagram from the Azure docs is good guidance:

<img alt="Least Privilege" src="https://docs.microsoft.com/azure/role-based-access-control/media/overview/rbac-least-privilege.png" class="powerpoint"/>

## References

* <https://docs.microsoft.com/azure/active-directory/users-groups-roles/>
* <https://docs.microsoft.com/azure/active-directory/users-groups-roles/directory-assign-admin-roles>
* <https://docs.microsoft.com/azure/role-based-access-control/>
* <https://docs.microsoft.com/azure/role-based-access-control/overview>
* <https://aka.ms/caf> (Cloud Adoption Framework)

## Summary

We have gone through the RBAC models in both AAD and Azure.

In the next section we'll start to automate.

[◄ Lab 2: Service Principals & Managed Identities](../lab2){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 4: Service Principals ►](../lab4){: .btn .btn--primary}
