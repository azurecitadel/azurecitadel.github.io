---
title: "Listing Provider Types and Operations"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, RBAC, custom, role definition, operations ]
toc_depth: 3
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: List out the resource providers, provider types and provider type operations. Split the operations into management plane and data plane actions for use in custom role definitions.
---

## Introduction

You will have see the resource providers and provider types in the middle of the resource IDs used in Azure.

This lab is focused on the CLI commands working with provider types and their available REST operations, in the context of creating custom role definitions.

## Background reading

Azure docs overview on resource providers and types:

* <https://docs.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types>

If you are unfamiliar with JMESPATH query then the following may help:

* <https://jmespath.org/>
* [Azure Citadel JMESPATH lab](/prereqs/cli/cli-3-jmespath)

## Provider namespaces

1. List all provider namespaces and registration status

    ```bash
    az provider list --output table
    ```

    ```text
    Namespace                               RegistrationPolicy    RegistrationState
    --------------------------------------  --------------------  -------------------
    Microsoft.Storage                       RegistrationRequired  Registered
    Microsoft.KeyVault                      RegistrationRequired  Registered
    Microsoft.Network                       RegistrationRequired  Registered
    Microsoft.Compute                       RegistrationRequired  Registered
    Microsoft.ManagedServices               RegistrationRequired  Registered
    Microsoft.ApiManagement                 RegistrationRequired  Registered
    Microsoft.Management                    RegistrationRequired  Registered
    Microsoft.Logic                         RegistrationRequired  Registered
    Microsoft.ContainerInstance             RegistrationRequired  Registered
    ```

    _(Truncated)_

1. Register a namespace

    ```bash
    az provider register --name Microsoft.Advisor
    ```

    ```text
    Registering is still on-going. You can monitor using 'az provider show -n Microsoft.Advisor'
    ```

1. Show the registration status of a namespace

    ```bash
    az provider show --name Microsoft.Advisor --query registrationState --output tsv
    ```

    ```text
    Registered
    ```

1. List the registered namespaces

    ```bash
    az provider list --query "[? registrationState == 'Registered'].namespace" --output tsv
    ```

## Provider types

1. List the provider types in a provider namespace

    ```bash
    az provider show --name Microsoft.Network --query "resourceTypes[].resourceType" --output tsv
    ```

    ```text
    virtualNetworks
    natGateways
    publicIPAddresses
    networkInterfaces
    privateEndpoints
    privateEndpointRedirectMaps
    loadBalancers
    networkSecurityGroups
    applicationSecurityGroups
    serviceEndpointPolicies
    networkIntentPolicies
    routeTables
    ```

    _(Truncated)_

1. List the provider types in a provider namespace, sorted alphabetically

    ```bash
    az provider show --name Microsoft.Network --query "sort_by(resourceTypes, &resourceType)[].resourceType" --output tsv
    ```

    ```text
    applicationGatewayAvailableRequestHeaders
    applicationGatewayAvailableResponseHeaders
    applicationGatewayAvailableServerVariables
    applicationGatewayAvailableSslOptions
    applicationGatewayAvailableWafRuleSets
    applicationGatewayWebApplicationFirewallPolicies
    applicationGateways
    applicationSecurityGroups
    azureFirewallFqdnTags
    azureFirewalls
    bastionHosts
    ```

    _(Truncated)_

1. As above, filtered on those services available in a location

   ```bash
   az provider show --name Microsoft.Network --query "sort_by(resourceTypes, &resourceType)[?contains(locations, 'UK South')].resourceType"
   ```

1. List the locations that support zone pinned virtual machines

    ```bash
    az provider show --name Microsoft.Compute --query "resourceTypes[?resourceType == 'virtualMachines'].zoneMappings[]|sort_by(@, &location)[?not_null(zones)].location" --output tsv
    ```

    ```text
    Central US
    East US
    East US 2
    France Central
    Japan East
    North Europe
    Southeast Asia
    UK South
    West Europe
    West US 2
    ```

## Provider operations

You can use the CLI to list out all of the provider types in a provider namespace.

```bash
namespace="Microsoft.Storage"
az provider operation show --namespace $namespace --query resourceTypes[].name --output tsv | sort -u
```

If you need to list the specific operations then use the following.

```bash
namespace="Microsoft.Storage"
type="storageAccounts/blobServices/containers/blobs"
az provider operation show --namespace $namespace --query "resourceTypes[?name == '"$type"'].operations[].name[]" --output tsv | sort -u
```

Example output:

```text
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/deleteBlobVersion/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/filter/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/manageOwnership/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/modifyPermissions/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/runAsSuperUser/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write
```

As you can see, the Storage Blob Data Contributor only has a subset of the possible actions within this area, which is why it does not have `Microsoft.Storage/storageAccounts/blobServices/containers/blobs/*`.

If you want to see the list split by actions or dataActions then you can make use of the isDataAction boolean property within the operation objects. We'll have to go a bit more complex with the JMESPATH query, using starts_with, before piping through to the a filter based on the boolean. We'll also have to swap the delimiters to use the shriek as a not.

Let's list out the actions for the whole of the storageAccounts/fileServices provider type within Microsoft.Storage:

```bash
echo "actions"
az provider operation show --namespace Microsoft.Storage --query 'resourceTypes[?starts_with(name, `storageAccounts/fileServices`)].operations[]|[? !isDataAction].name' --output tsv | sort -u
```

And again for the possible dataActions:

```bash
echo "notActions"
az provider operation show --namespace Microsoft.Storage --query 'resourceTypes[?starts_with(name, `storageAccounts/fileServices`)].operations[]|[? isDataAction].name' --output tsv | sort -u
```

Or finally as a table.

```bash
az provider operation show --namespace Microsoft.Storage --query 'resourceTypes[?starts_with(name, `storageAccounts/fileServices`)].operations[]|[].{dataAction:isDataAction, action:name}' --output table
```

Example output:

```text
DataAction    Action
------------  ----------------------------------------------------------------------------------------------------
False         Microsoft.Storage/storageAccounts/fileServices/providers/Microsoft.Insights/metricDefinitions/read
False         Microsoft.Storage/storageAccounts/fileServices/providers/Microsoft.Insights/diagnosticSettings/read
False         Microsoft.Storage/storageAccounts/fileServices/providers/Microsoft.Insights/diagnosticSettings/write
False         Microsoft.Storage/storageAccounts/fileServices/providers/Microsoft.Insights/logDefinitions/read
False         Microsoft.Storage/storageAccounts/fileServices/shares/action
False         Microsoft.Storage/storageAccounts/fileServices/read
False         Microsoft.Storage/storageAccounts/fileServices/write
False         Microsoft.Storage/storageAccounts/fileServices/read
True          Microsoft.Storage/storageAccounts/fileServices/fileshares/files/read
True          Microsoft.Storage/storageAccounts/fileServices/fileshares/files/write
True          Microsoft.Storage/storageAccounts/fileServices/fileshares/files/delete
True          Microsoft.Storage/storageAccounts/fileServices/fileshares/files/modifypermissions/action
True          Microsoft.Storage/storageAccounts/fileServices/fileshares/files/actassuperuser/action
False         Microsoft.Storage/storageAccounts/fileServices/shares/delete
False         Microsoft.Storage/storageAccounts/fileServices/shares/read
False         Microsoft.Storage/storageAccounts/fileServices/shares/read
False         Microsoft.Storage/storageAccounts/fileServices/shares/write
```

## Summary

<< CHANGE ME >>

[◄ Lab 2: Service Principals & Managed Identities](../lab2){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 4: Service Principals ►](../lab4){: .btn .btn--primary}
