---
title: "Permissions in role definitions"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, role, permissions ]
toc_depth: 3
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: Understand the permissions in role definitions, including management plane and data plane actions and notActions.
---

## Introduction

The permissions are key to understanding the built-in role definitions, and even more so when you are definign your own custom role definitions. This page explains them a little more.

If you do not understand the resource providers and types in Azure Resource Manager then read this first:

* <https://docs.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types>

As always we will use [JMESPATH](/prereqs/cli/cli-3-jmespath) queries to drill into the output json from Azure CLI commands.

## Displaying role permissions

1. List out a full role definition

    ```bash
    az role definition list --name "Owner" --output jsonc
    ```

    > The possible output values are `json|jsonc|tsv|yaml|table`. You can set your default output type using `az configure`.

1. List out only the permissions

    ```bash
    az role definition list --query "[0].permissions[0]" --output jsonc --name "Owner"
    ```

    Example output:

    ```json
    {
      "actions": [
        "*"
      ],
      "dataActions": [],
      "notActions": [],
      "notDataActions": []
    }
    ```

## Management and data plane

The permissions object has four keys

1. actions
1. dataActions
1. notActions
1. notDataActions

The value for each is an array that may have a list of actions, including full or partial wildcards.

Think of them as two pairs of arrays: **_actions / notActions_** and **_dataActions / notDataActions_**.

The **_actions / notActions_** pair control the permissions for the **management layer** for the Azure Resource Manager, i.e the  REST API calls that hit the <https://management.azure.com> endpoint. The majority of roles relate to the management plane.

The **_dataActions / notDataActions_** pair relate to PaaS service endpoint REST API calls.

As an example, the actions required to create a storage account, including defining the name, region, SKU, access tier etc. are on the management plane. The actions required to read, write and delete blob storage itself go to <https://storageaccountname.blob.core.windows.net/>, i.e. the data plane.

This enables a sensible separation of duties, so Contributor roles do not have the ability to read and write data unless an additional role is assigned. The storage account example will be used throughout this page.

## Standard RBAC roles

We'll go through the main four roles.

Look again at the permissions for [Owner](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#owner):

```json
{
  "actions": [
    "*"
  ],
  "dataActions": [],
  "notActions": [],
  "notDataActions": []
}
```

The Owner role has a wildcard in the _actions_ array and can therefore perform all actions on the management plane.

----------

Compare against [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor):

```json
{
  "actions": [
    "*"
  ],
  "dataActions": [],
  "notActions": [
    "Microsoft.Authorization/*/Delete",
    "Microsoft.Authorization/*/Write",
    "Microsoft.Authorization/elevateAccess/Action",
    "Microsoft.Blueprint/blueprintAssignments/write",
    "Microsoft.Blueprint/blueprintAssignments/delete"
  ],
  "notDataActions": []
}
```

The Contributor's permissions follow a "grant and then deny" pattern. It has the same allow action wildcard, but certain REST API calls are denied, namely anything to do with assigning roles to others or elevating access. Note the use of wildcards in the Microsoft.Authorization namespace to remove all Delete and Write actions so that only the Read actions remain.

----------

The [Reader](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#reader) role permits read actions against all resource provider types:

```json
{
  "actions": [
    "*/read"
  ],
  "dataActions": [],
  "notActions": [],
  "notDataActions": []
}
```

----------

The last major role is [User Access Administrator](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator):

```json
{
  "actions": [
    "*/read",
    "Microsoft.Authorization/*",
    "Microsoft.Support/*"
  ],
  "dataActions": [],
  "notActions": [],
  "notDataActions": []
}
```

It is similar to the Reader role, except that it also has full permissions in the Microsoft.Authorization and Microsoft.Support namespaces.

> Note that only Owner and User ACcess Administrator are able to create or delete role assignments.

## Service specific roles

The majority of the other [built in roles]() follow a similar pattern, but are filtered to specific namespaces or provider types.

The [Storage Account Key Operator](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#storage-account-key-operator-service-role) role is a good example:

```json
{
  "actions": [
    "Microsoft.Storage/storageAccounts/listkeys/action",
    "Microsoft.Storage/storageAccounts/regeneratekey/action"
  ],
  "notActions": [],
  "dataActions": [],
  "notDataActions": []
}
```

Here are the permissions for the [DevTest Labs User](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#devtest-labs-user) role:

```json
{
  "actions": [
    "Microsoft.Authorization/*/read",
    "Microsoft.Compute/availabilitySets/read",
    "Microsoft.Compute/virtualMachines/*/read",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.DevTestLab/*/read",
    "Microsoft.DevTestLab/labs/claimAnyVm/action",
    "Microsoft.DevTestLab/labs/createEnvironment/action",
    "Microsoft.DevTestLab/labs/ensureCurrentUserProfile/action",
    "Microsoft.DevTestLab/labs/formulas/delete",
    "Microsoft.DevTestLab/labs/formulas/read",
    "Microsoft.DevTestLab/labs/formulas/write",
    "Microsoft.DevTestLab/labs/policySets/evaluatePolicies/action",
    "Microsoft.DevTestLab/labs/virtualMachines/claim/action",
    "Microsoft.DevTestLab/labs/virtualmachines/listApplicableSchedules/action",
    "Microsoft.DevTestLab/labs/virtualMachines/getRdpFileContents/action",
    "Microsoft.Network/loadBalancers/backendAddressPools/join/action",
    "Microsoft.Network/loadBalancers/inboundNatRules/join/action",
    "Microsoft.Network/networkInterfaces/*/read",
    "Microsoft.Network/networkInterfaces/join/action",
    "Microsoft.Network/networkInterfaces/read",
    "Microsoft.Network/networkInterfaces/write",
    "Microsoft.Network/publicIPAddresses/*/read",
    "Microsoft.Network/publicIPAddresses/join/action",
    "Microsoft.Network/publicIPAddresses/read",
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Resources/deployments/operations/read",
    "Microsoft.Resources/deployments/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Storage/storageAccounts/listKeys/action"
  ],
  "notActions": [
    "Microsoft.Compute/virtualMachines/vmSizes/read"
  ],
  "dataActions": [],
  "notDataActions": []
}
```

As you can see it rather surgically adds a set of permissions required for the role. And whilst the role is allowed Read actions agains virtual machines, it is not allowed to read the sizes.

## Roles with both management plane and data plane

Some role definitions have a mix of management plane and data plane permissions. A good example is the [Storage Blob Data Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor) role:

```json
{
  "actions": [
    "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
    "Microsoft.Storage/storageAccounts/blobServices/containers/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/write",
    "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action"
  ],
  "notActions": [],
  "dataActions": [
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write"
  ],
  "notDataActions": []
}
```

Here you can see that the container actions go to the management plane, whilst the data itself goes via the storage account endpoint, <https://storageaccountname.blob.core.windows.net/>. This role is not able to create storage accounts or read storage keys.

> Not all PaaS endpoints actions are represented in the dataActions RBAC role definitions. In terms of paths and actions they are more likely to resemble the management plane actions than the URI for the PaaS endpoint.

## Summary

That is an overview of the role definition permissions. If you are creating your own [custom](../custom) roles then you will need to know which [operations](../operations) are available.

<< CHANGE ME >>

[◄ Lab 2: Service Principals & Managed Identities](../lab2){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 4: Service Principals ►](../lab4){: .btn .btn--primary}
