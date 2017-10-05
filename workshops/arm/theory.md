---
layout: article
title: Authoring ARM Templates
date: 2017-07-04
categories: null
#permalink: /armtemplates/theory/
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney`
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
Understanding the theory behind Azure Resource Manager.


{% include toc.html %}

## Background

Azure Resource Manager, or ARM, is the dominant deployment type for Azure, spanning the public clouds, government clouds and Azure Stack private cloud deployments.  It superseded the Azure Service Manager which is expected to be slowly deprecated over time, and will be ignored in this lab except as a comparison point. 

## Resources, resource groups and resource providers

If you have used the ARM portal ([http://portal.azure.com](http://portal.azure.com)), then you will be familiar with deploying various resources into resource groups.  Resource groups are designed as a natural management point for related resources, based on groupings, linked lifecycle, use case, billing aggregation, role based access control, etc.

The resources themselves are provided by [resource providers](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#resource-providers).  Each *resource provider* will provider one or more *resource types*. To see which providers are registered (and unregistered) on your subscription, use the CLI 2.0 command below: 
```
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

Type ```az provider show --namespace Microsoft.Network``` to view the JSON detail of a resource provider.  Note 
* the ID is specific to your subscription
* each resource type has numerous API versions relecting the innovation within Azure
* will be supported in a number of named locations, or will be specified as a global service

## Resource Explorer

You can see the definitions of the resources, resource groups and resource providers in use within your subscription in the resource explorer ([http:/resources.azure.com](http:/resources.azure.com)).  

Drill into an existing resource group, select a resource within it and examine the *id* key's value.  

**ADD IN THE PROPER TEXT FOR THE CURRENT DIRS IMAGES SUBDIR**
![](./images/armResourceExplorer.png)

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
    
## Azure Resource Manager JSON template format

The ARM template format is JSON format. 

Note that the curly brace objects in JSON contain key:value pairs.  The value in the key:value pair can also be another object.  Square brackets are another object type, and contain lists of unnamed (but indexed) objects.

Here is an empty template to show the structure.

```
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
  },
  "variables": {
  },
  "resources": [
    {
    }
  ],
  "outputs": {  }
}
```

**Section** | Description
**schema** | JSON schema that describes the template format
**contentVersion** | version of the schema 
**parameters** | user (or script) inputs to the template
**variables** | used within the template to simplify the resources later
**resources** | list of resources to deploy
**outputs** | optional output JSON information


Of these, the schema and contentVersion are mandatory, as are the resources.  Parameters and variables are almost always included. Outputs are rarer, and only really used when nesting templates.  More on that later.  

## Recommended reading

For more background information on JSON templates and how they deploy using into Azure Resource Manager, start with the following links:

* [Azure Resource Manager landing page](https://docs.microsoft.com/en-us/azure/azure-resource-manager/)
* [What is Resource Manager?](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview)
* [Resource Providers and Types](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-supported-services)
* [Template Sections](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates)