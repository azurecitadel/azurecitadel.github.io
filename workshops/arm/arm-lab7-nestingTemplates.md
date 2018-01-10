---
layout: article
title: 'ARM Lab 7: Nesting templates'
date: 2018-01-08
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template, nesting]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab6-objectsAndArrays
  title: Using objects and arrays as parameters or resources 
next:
  url: http://aka.ms/armtemplates
  title: Placeholder - links to GitHub templates  
---

<div class="warning">WARNING: This page is a work in progress</div>

{% include toc.html %}

## Introduction

Using nested templates is a great way of managing your IP for repeatable complex deployments and helps to hide away the verbosity of the child templates.  

We will look at how inline nested templates can give us more flexibility within a building block, and then we will look at a master template using object and array parameters to call multiple linked templates.  Going through the lab will give you an understanding of how to incorporate each type into your own templates, and the examples give a good indication of when it makes sense to do so. 

We will then revisit key vaults and run through a short lab to show how nesting enables the use of dynamic key vault IDs.

Finally, we will link to some of the great documentation that is available. 

## Nested templates

First, let's start by saying that not everyone needs to work with nested templates.  You can achieve a lot with simple standalone templates, and for small to medium sized deployments they are probably the best approach.  And you can always wrap scripts around those to generate parameters on the fly, and/or to submit multiple templates into one or more resource groups.  

However, when you get into larger architectural standards, or into specific application patterns, then nested templates can be very useful.  You can see multiple use cases for this from a partner perspective, for instance:
*  a service integrator (SI) taking their high level cloud architecture design standards, and translating those into infrastructure as code with sufficient flexibility and modularity to meet different customers' needs
* an independent software vendor (ISV) defining an application pattern for their software for consistent deployment from the Azure Marketplace, Azure Stack syndicated marketplace or simply with a GitHub hosted set of templates  

We'll run through how they work, looking at:

1. options for both parameters and templates
1. an example of an inline template
1. an example of a master template calling linked templates
1. a quick lab to revisit our key vault, and make that static parameter into a dynamic one using nesting
1. a discussion on a sensible structure for an SI or ISV partner creating IP 
    * defining your building blocks
    * t-shirt sizes
    * default parameterisation
    * master templates to match reference architectures and application patterns
1. a review of some of the excellent resources available online

### Options for parameters and templates 

To nest templates, all you have to do is call another template from within the current template.  This uses the [Microsoft.Resources/deployments](https://docs.microsoft.com/en-gb/azure/templates/microsoft.resources/deployments) resource type. The main reference page is useful, but you will probably find the [Linked Templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates) documentation page easier to follow.  

```json
"resources": [
  {
      "name": "linkedTemplate",
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2017-05-10",
      "resourceGroup": "[resourceGroup().name]",
      "properties": {
          "mode": "Incremental",
          <inline-template-or-external-template>
      }
  }
]
```

The name, type and apiVersion are required as per normal.  

In the properties section the mode property is also required.  (Again, if you set this to 'Complete' rather than 'Incremental' then be aware that the ARM layer will merrily remove any resources from the resource group that are not described in the master template, so only use this option if you are 100% confident in what you are doing!)

You can define both the parameters and the template as inline JSON objects.  The vnet-spoke.json example in the next section defines the template inline.  As you'll remember from the first lab, the template is always required whilst the parameters are optional.

Alternatively you can replace either of these with links to an external URI, using the templateLink and parametersLink objects.  We'll see an example of that in the master template.  Note that both objects are structured the same:

```json
    "templateLink": {
       "uri":"https://raw.githubusercontent.com/richeney/arm/master/lab7/vnet-spoke.json",
       "contentVersion":"1.0.0.0"
    },
```  

The URI must be an http or https file.  You cannot use FTP or local files.  A Git repository is common (either GitHub or a private repo), as is using blob storage, potentially with SAS tokens to control access.

For the URI itself, you can hardcode them, but it is more common to [use variables](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates#using-variables-to-link-templates) to define them dynamically. The `deployment().properties.templateLink.uri` function can be used to return the base URL for the current template, and the uri() function.  The [functions](https://aka.ms/armfunc) area goes into more detail on the usage.

The contentVersion string is not required.  So far we have not been versioning our templates as we have modified them, but using linked templates is a good reason to consider doing so. When you specify the contentVersion string then the deployment will check that the contentVersion is a direct match.  For example, imagine you substantially change a building block template to the point that the parameters change.  If you were  that template is linked to by a number of master templates then this would fail.  An update to the master templates with a correctly configured parameters section and an updated contentVersion string would be required before the deployment would go through successfully.

You'll also notice the optional 'resourceGroup' string. This permits us to have templates that deploy to differrent resource groups.  Let's take a look at an example of that.

### Example of an inline template

For larger organisations a [hub and spoke topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) is a recommended virtual data centre architecture to provide service isolation, network traffic control, billing and role based access control (RBAC).

Use CTRL+O in vscode and open up the `https://raw.githubusercontent.com/richeney/arm/master/lab7/vnet-spoke.json` file.

The vnet-spoke.json will create a spoke vNet, and will also create a vNet peering back to a pre-existing hub vNet.  For that peering to work, the Microsoft.Network/virtualNetworks/virtualNetworkPeerings resource type needs to be created at both ends to create the connection.  Therefore the vNet peering from the hub to the spoke needs to be created in the hub's resource group.  

The hub vNet name and resource group are part of the expected parameters, but let's look at the two ends of the peering:

```json
    {
      "condition": "[parameters('peer')]",
      "name": "[concat(parameters('spoke').vnet.name, '/to-', parameters('hub').vnet.name)]",
      "type": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
      "apiVersion": "2017-10-01",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[variables('spokeID')]"
      ],
      "properties": {
        "allowVirtualNetworkAccess": true,
        "allowForwardedTraffic": false,
        "allowGatewayTransit": false,
        "useRemoteGateways": false,
        "remoteVirtualNetwork": {
          "id": "[variables('hubID')]"
        }
      }
    },
    {
      "condition": "[parameters('peer')]",
      "name": "nestedTemplateForHubToSpokeVnetPeering",
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2017-05-10",
      "resourceGroup": "[parameters('hub').resourceGroup]",
      "dependsOn": [
        "[variables('spokeID')]"
      ],
      "properties": {
        "mode": "Incremental",
        "template": {
          "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
          "contentVersion": "1.0.0.0",
          "parameters": {},
          "variables": {},
          "resources": [
              {
                "apiVersion": "2017-10-01",
                "type": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
                "name": "[concat(parameters('hub').vnet.name, '/to-', parameters('spoke').vnet.name)]",
                "location": "[resourceGroup().location]",
                "properties": {
                    "allowVirtualNetworkAccess": true,
                    "allowForwardedTraffic": false,
                    "allowGatewayTransit": true,
                    "useRemoteGateways": false,
                    "remoteVirtualNetwork": {
                      "id": "[variables('spokeID')]"
                    }
                }
              }
          ]
        }
      }
    }
```

The first peering resource is a straightforward `Microsoft.Network/virtualNetworks/virtualNetworkPeerings` sub-resource type and naturally it goes straight into the resource group we are deploying to as part of the `az group deployment create` command, once the spoke vNet has been created.

The second peering, however, is a nested inline template deployment (`Microsoft.Resources/deployments`) which gives us the flexibility to deploy into a different resource group.   We have the embedded inline template deploying the peering into the hub vNet and into the hub's resource group. Once both ends are in place then the 

Taking this approach has made the vnet-spoke.json building block more functional and neat and tidy.

There is a corresponding `https://raw.githubusercontent.com/richeney/arm/master/lab7/vnet-hub.json` file for creating the hub vNet with a couple of standard subnets, plus a GatewaySubnet containing a VPN gateway with a public IP.  Notice that the IP address for the VPN gateway's public IP is being returned in the outputs section:

```json
  "outputs": {
    "vpnGatewayIpAddress": {
      "type": "string",
      "value": "[reference(variables('gatewayPublicIpName')).ipAddress]"
    },
    "pip": {
      "type": "object",
      "value": "[reference(variables('gatewayPublicIpName'))]"
    }
  }
```

This is really the key value that we want to know about following deployment as it is not specified in the azuredeploy.parameters.json file. 

OK, let's take a look at how those two building blocks could be used by a master template.

### Example of a master template calling linked templates

Open up the `https://raw.githubusercontent.com/richeney/arm/master/lab7/azuredeploy.json` master template, and the corresponding `https://raw.githubusercontent.com/richeney/arm/master/lab7/azuredeploy.parameters.json` parameters file.

The template will create:
* a single hub vNet, containing a number of subnets, and the GatewaySubnet can also include an optional VPN Gateway and public IP address
* one or more spoke vNets, also containing a number of subnets, with a vNet peering back to the hub vNet

First of all, take a look at the parameters.  The main template has defaults, which are pretty much there for testing and to describe the expected parameter objects.  Below are the ones from the parameters file:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "hub": {
            "value": {
                "resourceGroup": "shared",
                "vnet": { "name": "shared", "addressPrefixes": [ "10.0.0.0/16" ] },
                "subnets": [
                    { "name": "GatewaySubnet", "addressPrefix": "10.0.0.0/24" },
                    { "name": "outside", "addressPrefix": "10.0.1.0/24" },
                    { "name": "inside", "addressPrefix": "10.0.2.0/24" },
                    { "name": "shared", "addressPrefix": "10.0.3.0/24" }
                ],
                "createGateway": true,
                "gatewaySku": "VpnGw1"
            }
        },
        "spokes": {
            "value": [
                {
                    "resourceGroup": "erp",
                    "vnet": { "name": "erp", "addressPrefixes": [ "10.1.0.0/16"  ] },
                    "subnets": [
                        { "name": "presentation", "addressPrefix": "10.1.0.0/24" },
                        { "name": "application", "addressPrefix": "10.1.1.0/24" },
                        { "name": "business", "addressPrefix": "10.1.2.0/24" },
                        { "name": "data", "addressPrefix": "10.1.3.0/24" }
                    ]
                },
                {
                    "resourceGroup": "test",
                    "vnet": { "name": "test", "addressPrefixes": [ "10.76.0.0/16" ] },
                    "subnets": [
                        { "name": "test1", "addressPrefix": "10.76.0.0/24" },
                        { "name": "test2", "addressPrefix": "10.76.1.0/24" }
                    ]
                },
                {
                    "resourceGroup": "dev",
                    "vnet": { "name": "dev", "addressPrefixes": [ "10.77.0.0/16" ] },
                    "subnets": [
                        { "name": "dev", "addressPrefix": "10.77.0.0/16" }
                    ]
                }
            ]
        }
    }
}
```   

The hub parameter object specifies the resource group, vNet name and address space, plus the array of subnets.  It also has controls for whether a VPN Gateway is created and if so, with which SKU.

The spokes parameter is actually an array, and each member of the array (i.e. each spoke) is an object which is structurally very similar to the hub object, except with no gateway properties.  Some level of consistency is usually a good idea.

Let's take a look at how the master templates is calling the 

1. an example of an inline template
1. an example of a master template calling linked templates
1. a quick lab to revisit our key vault, and make that static parameter into a dynamic one using nesting
1. a discussion on a sensible structure for an SI or ISV partner creating IP 
    * defining your building blocks
    * t-shirt sizes
    * default parameterisation
    * master templates to match reference architectures and application patterns
1. a review of some of the excellent resources available online

## Final files

This lab uses a collection of files, so it is more useful to see them as a set:

###### Lab 7 Files:
<div class="success">
    <b>
        <li>
          <a href="https://github.com/richeney/arm/tree/master/lab7" target="_blank">Azure Resource Manager Workshop Lab 7 files</a>
        </li>
    </b>
</div>


