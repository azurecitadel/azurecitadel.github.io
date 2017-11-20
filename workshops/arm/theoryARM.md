---
layout: article
title: Azure Resource Manager
date: 2017-11-14
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
previous:
  url: ../../arm
  title: Back up to ARM workshop contents
next:
  url: ../theoryTemplates
  title: Azure Resource Manager Templates
---

{% include toc.html %}

## Background

Azure Resource Manager, or ARM, is the dominant deployment type for Azure, spanning the public clouds, government clouds and Azure Stack private cloud deployments.  It superseded the Azure Service Manager which is expected to be slowly deprecated over time, and will be ignored in this lab except as a comparison point. 

Before the workshop moves on to using templates to configure Infrastructure as Code through Azure Resource Manager, it is worth revisiting some of the theory behind ARM, resource providers and resource groups as it will give the template sections some real context.

## What is ARM?

> Azure Resource Manager sits at the heart of Azure as the control plane for managing the lifecycle of every resource in the platform.
> Azure Resource Manager consists of a common API surface, consistent tooling and templating mechanisms

The Azure Resource Manager (ARM) layer sits between 
* the user interfaces, i.e. 
  * Azure Portal
  * CLIs (PowerShell, CLI 2.0)
  * SDKs (Ruby, Python, node.js, .NET, etc.)
  * REST API
* and the resource providers
  * Microsoft.Compute
  * Microsoft.Network
  * Microsoft.Storage
  * ...

The ARM layer takes the requests from the users and executes against the various resource providers and therefore works as an extensible abstraction layer. 

The resources that are then created, modified, listed and deleted by those Resource Providers are managed in the context of Resource Groups.

## Resource Groups

If you have used the ARM portal ([http://portal.azure.com](http://portal.azure.com)), then you will be familiar with deploying various resources into resource groups:

Resource Groups:
* containers for multiple resources
* a resource exists in one (and only one) resource group
* the resources in a group can be from various services
* the resources in a group can span multiple regions

> Note that a resource group itself will be located in a region, but this does not limit the regions that can be used by its resource.  The resource group's region determines where the metadata for that group resides.

![](/workshops/arm/images/armResourceGroups.png)

How the resources are grouped depends on the natural organisation of applications, or on how the various resources will be managed.  As a guiding rule it is sensible to group together resources that share the same lifecycle, i.e. they will be instantiated in the same period, and may also be deleted in the future at the same time.

## Managing Resource Groups

Resource groups are designed as a natural management point for related resources, based on groupings, linked lifecycle, use case, billing aggregation, role based access control, etc.

![](/workshops/arm/images/armManageResourceGroups.png)

#### Tagging
* Assign metadata to resource
* Multiple tags per group or resource (max 15 name/value pairs)
* Used with billing, reporting and automation

#### Role Based Access Control (RBAC) 
* Control access to resources
* Fine grained roles and operations
* Scoped at subscription, resource group and resource level
* Backed by Azure AD

#### Policies
* Govern resources using rule based policies
* Apply restrictions on type, region, size, name, etc.
* Apply at subscription or resource group level
* Use Azure Policy to ascertain compliancy against policy for existing resources

#### Locks
* Protect live resource
* Prevent accidental changes with RBAC
* Lock against deletion or modification

## Resource Providers

The resources themselves are provisioned by [resource providers](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#resource-providers).  Each *resource provider* will provide one or more *resource types*. To see which providers are registered (and unregistered) on your subscription, use the CLI 2.0 command below: 
```bash
az provider list --output table

Namespace                               RegistrationState
--------------------------------------  -------------------
Microsoft.Advisor                       Registered
Microsoft.ApiManagement                 Registered
Microsoft.Automation                    Registered
Microsoft.Cache                         Registered
Microsoft.Cdn                           Registered
Microsoft.Compute                       Registered
Microsoft.ContainerRegistry             Registered
Microsoft.ContainerService              Registered
...
``` 

Type `az provider show --namespace Microsoft.Network` to view the JSON detail of a resource provider.  Note 
* the ID is specific to your subscription
* each resource type has numerous API versions relecting the innovation within Azure
* will be supported in a number of named locations, or will be specified as a global service

> There are over 100 resource providers (from both Microsoft and third parties) and over 700 resource types. 

## Resource Explorer

You can see the definitions of the resources, resource groups and resource providers in use within your subscription in the resource explorer ([http:/resources.azure.com](http:/resources.azure.com)).  

Drill into an existing resource group, select a resource within it and examine the *id* key's value.  

![](/workshops/arm/images/armResourceExplorer.png)

Here is an example:
```
/subscriptions/2ca76be1-7e80-4f2b-92f7-06b2763a68cc/resourceGroups/networkCore/providers/Microsoft.Network/publicIPAddresses/VpnGateway-pip
```
This can be broken down into:

**Name** | **Section** | **Value**
Subscription ID | /subscriptions/2ca76be1-7e80-4f2b-92f7-06b2763a68cc | 2ca76be1-7e80-4f2b-92f7-06b2763a68cc
Resource Group | resourceGroups/networkCore | networkCore
Resource Provider | providers/Microsoft.Network | Microsoft.Network
Resource Type | publicIPAddresses | Microsoft.Network/publicIPAddresses
Resource Name | VpnGateway-pip | VpnGateway-pip

Note that the resource provider type can be multi-level for nested resource types.

The *type* is the resource type in the *Resource.Provider/resourceType* naming type, e.g. "Microsoft.Logic/workflows"   

> A resource ID will always be unique.
    

## Recommended reading

For more background information on Azure Resource Manager, start with the following links:

* [Azure Resource Manager landing page](https://docs.microsoft.com/en-us/azure/azure-resource-manager/)
* [What is Resource Manager?](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview)
* [Resource Providers and Types](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-supported-services)

