---
title: 'ARM Lab 7: Nesting templates'
date: 2018-04-17
category: automation
author: Richard Cheney
sidebar:
  nav: "arm"
hidden: true
---

## Introduction

Using nested templates is a great way of managing your IP for repeatable complex deployments and helps to hide away the verbosity of the child templates.

We will look at how inline nested templates can give us more flexibility within a building block, and then we will look at a master template using object and array parameters to call multiple linked templates.  Going through the lab will give you an understanding of how to incorporate each type into your own templates, and the examples give a good indication of when it makes sense to do so.

We will use a nested deployment to create a basic network hub environment and then you'll create a new master template to create a spoke that is vNet peered to it. We will also create a public load balancer fronting an availability set containing three VMs.

Finally, we will link to some of the great documentation that is available.

## Nested templates

First, let's start by saying that not everyone needs to work with nested templates.  You can achieve a lot with simple standalone templates, and for small to medium sized deployments they are probably the best approach.  And you can always wrap scripts around those to generate parameters on the fly, and/or to submit multiple templates into one or more resource groups.

However, when you get into larger architectural standards, or into specific application patterns, then nested templates can be very useful.  You can see multiple use cases for this from a partner perspective, for instance:

* a service integrator (SI) taking their high level cloud architecture design standards, and translating those into infrastructure as code with sufficient flexibility and modularity to meet different customers' needs
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

## Options for parameters and templates

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

You can define both the parameters and the template as inline JSON objects.  The spoke.json example in the next section defines the template inline.  As you'll remember from the first lab, the template is always required whilst the parameters are optional.

Alternatively you can replace either of these with links to an external URI, using the templateLink and parametersLink objects.  We'll see an example of that in the master template.  Note that both objects are structured the same:

```json
    "templateLink": {
       "uri":"https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/vnet-spoke.json",
       "contentVersion":"1.0.0.0"
    },
```

The URI must be an http or https file.  You cannot use FTP or local files.  A Git repository is common (either GitHub or a private repo), as is using blob storage, potentially with SAS tokens to control access.

For the URI itself, you can hardcode them, but it is also very common to [use variables](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates#using-variables-to-link-templates) to define them dynamically. The `deployment().properties.templateLink.uri` function can be used to return the base URL for the current template, and the uri() function.  The [functions](https://aka.ms/armfunc) area goes into more detail on the usage.

The contentVersion string is not required.  So far we have not been versioning our templates as we have modified them, but using linked templates is a good reason to consider doing so. When you specify the contentVersion string then the deployment will check that the contentVersion is a direct match.  For example, imagine you substantially change a building block template to the point that the parameters change.  If that template is linked to by a number of master templates then this would fail.  An update to the master templates with a correctly configured parameters section and an updated contentVersion string would be required before the deployment would go through successfully.

You'll also notice the optional 'resourceGroup' string. This permits us to have templates that deploy to different resource groups.  Let's take a look at an example of that.

## Example of an inline template

For larger organisations a [hub and spoke topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) is a recommended virtual data centre architecture to provide service isolation, network traffic control, billing and role based access control (RBAC).

Take a look at the repository used for the [Virtual Data Centre](https://github.com/azurecitadel/vdc-networking-lab) workshop. Navigate into the nested subdirectory and look at the [spoke.json](https://github.com/azurecitadel/vdc-networking-lab/blob/master/nested/spoke.json) file.

The spoke.json will create a spoke vNet, and will also create a vNet peering back to a pre-existing hub vNet.  For that peering to work, the Microsoft.Network/virtualNetworks/virtualNetworkPeerings resource type needs to be created at both ends to create the connection.  Therefore the vNet peering from the hub to the spoke needs to be created in the hub's resource group.

The hub vNet name and resource group are part of the expected parameters, but let's look at the two ends of the peering:

```json
    {
        "comments": "Optional vnet to hub peering",
        "condition": "[parameters('peer')]",
        "name": "[concat(parameters('spoke').vnet.name, '/to-', parameters('hub').vnet.name)]",
        "type": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
        "apiVersion": "2017-10-01",
        "location": "[resourceGroup().location]",
        "properties": {
            "allowVirtualNetworkAccess": true,
            "allowForwardedTraffic": false,
            "allowGatewayTransit": false,
            "useRemoteGateways": false,
            "remoteVirtualNetwork": {
                "id": "[resourceId(parameters('hub').resourceGroup,'Microsoft.Network/virtualNetworks/', parameters('hub').vnet.name)]"
            }
        },
        "dependsOn": [
            "[concat(parameters('spoke').vnet.name)]"
        ]
    },
    {
        "comments": "Inline deployment for reverse peering",
        "condition": "[parameters('peer')]",
        "name": "[concat('DeployVnetPeering-', parameters('hub').vnet.name, '-to-', parameters('spoke').vnet.name)]",
        "type": "Microsoft.Resources/deployments",
        "apiVersion": "2017-05-10",
        "resourceGroup": "[parameters('hub').resourceGroup]",
        "properties": {
            "mode": "Incremental",
            "template": {
                "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
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
                                "id": "[resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks/', parameters('spoke')t.name)]"
                            }
                        }
                    }
                ]
            }
        },
        "dependsOn": [
            "[concat(parameters('spoke').vnet.name)]"
        ]
    }
```

The first peering resource is a straightforward `Microsoft.Network/virtualNetworks/virtualNetworkPeerings` sub-resource type and naturally it goes straight into the resource group we are deploying to as part of the `az group deployment create` command, once the spoke vNet has been created.

The second peering, however, is a nested inline template deployment (`Microsoft.Resources/deployments`) which gives us the flexibility to deploy into a different resource group.   We have the embedded inline template deploying the peering into the hub vNet and into the hub's resource group. Once both ends are in place then the peering is established.

Taking this approach has made the spoke.json building block both more functional and rather neat and tidy. Click on the 'Raw' button on the GitHub page. This will take you through to the raw URI, <https://raw.githubusercontent.com/azurecitadel/vdc-networking-lab/master/nested/spoke.json>.

Open up a Bash terminal session. You can use the curl command to prove that the raw URI can be accessed:

```bash
curl https://raw.githubusercontent.com/azurecitadel/vdc-networking-lab/master/nested/spoke.json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "peer": {
           "type": "bool",
           "defaultValue": true,
           "metadata": {
                "description": "Boolean to control whether spoke is peered to the hub"
            }
        },
        "hub": {
            "type": "object",
            "defaultValue": {
                "resourceGroup": "westeurope",
                "vnet": {
                    "name": "hub"
                }
            },
:
:
```

> Quick tip: If your machine is caching web content and not showing the most up to date version of a template then you can always use a unique query string to force a fresh version, e.g. `curl -sL https://path/to/template.json?$(date +%s)`.

OK, let's take a look at how this template is called by a master template.

## Example of a master template calling linked templates

Open up the `https://raw.githubusercontent.com/azurecitadel/vdc-networking-lab/master/DeployVDCwithNVA.json` master template. (You can use `CTRL`+`O` in vscode and then paste in the raw URI.)

The template creates the environment used in the [Virtual Data Centre](https://aka.ms/citadel/vdc) workshop. The template uses the nested templates to create the following:

* OnPrem vNet including VPN gateway and single VM with a public IP
* Hub vNet including the other VPN gateway, plus two subnets
* Cisco CSR 1000v in the VDC-NVA resource group
* Two spoke vNets, peered to the hub vNet, with each containing load balanced HA VMs running a simple node.js app

Take a look at the variables section.  There are two main types of variables used here, to reference the URIs of the nested templates and also the hardcoded complaex objects that are used as the parameters to some of the nested templates.  Let's look at the URIs first:

```json
    "variables": {
        "vnetUri": "[uri(deployment().properties.templateLink.uri, 'nested/vnet.json')]",
        "spokeUri": "[uri(deployment().properties.templateLink.uri, 'nested/spoke.json')]",
        "avsetUri": "[uri(deployment().properties.templateLink.uri, 'nested/avset.json')]",
        "vpngwUri": "[uri(deployment().properties.templateLink.uri, 'nested/vpngw.json')]",
        "vmUri": "[uri(deployment().properties.templateLink.uri, 'nested/vm.json')]",
        "csrUri": "[uri(deployment().properties.templateLink.uri, 'nested/ciscoCSR.json')]",
        :
```

Using a combination of the uri() and deployment() functions is a great way of determining the path for the master template and deriving the linked template names from it.  The deployment() function will return the full URI of the current template.  The uri() function takes the directory name of that template and then appends the second string.

<div class="warning">WARNING: Using deployment().properties.templateLink.uri will only return a value if the --template-uri switch is used. The deployment will fail validation if --template-file is used.</div>

OK, let's look at the rest of the variables:

```json
        "hub": {
            "resourceGroup": "VDC-Hub",
            "vnet": {
                "name": "Hub-vnet",
                "addressPrefixes": [  "10.101.0.0/16" ]
            },
            "subnets": [
                { "addressPrefix": "10.101.0.0/24", "name": "GatewaySubnet" },
                { "addressPrefix": "10.101.1.0/24", "name": "Hub-vnet-subnet1" },
                { "addressPrefix": "10.101.2.0/24", "name": "Hub-vnet-subnet2" }
            ],
            "vpnGwName": "Hub-vpn-gw"
        },
        "onprem": {
            "resourceGroup": "VDC-OnPrem",
            "vnet": {
                "name": "OnPrem-vnet",
                "addressPrefixes": [  "10.102.0.0/16" ]
            },
            "subnets": [
                { "addressPrefix": "10.102.0.0/24", "name": "GatewaySubnet" },
                { "addressPrefix": "10.102.1.0/24", "name": "OnPrem-vnet-subnet1" },
                { "addressPrefix": "10.102.2.0/24", "name": "OnPrem-vnet-subnet2" }
            ],
            "vpnGwName": "OnPrem-vpn-gw"
        },
        "spokes": [
            {
                "resourceGroup": "VDC-Spoke1",
                "vnet": {
                    "name": "Spoke1-vnet",
                    "addressPrefixes": [  "10.1.0.0/16" ]
                },
                "subnets": [
                    { "addressPrefix": "10.1.1.0/24", "name": "Spoke1-vnet-subnet1" },
                    { "addressPrefix": "10.1.2.0/24", "name": "Spoke1-vnet-subnet2" }
                ]
            },
            {
                "resourceGroup": "VDC-Spoke2",
                "vnet": {
                    "name": "Spoke2-vnet",
                    "addressPrefixes": [  "10.2.0.0/16" ]
                },
                "subnets": [
                    { "addressPrefix": "10.2.1.0/24", "name": "Spoke2-vnet-subnet1" },
                    { "addressPrefix": "10.2.2.0/24", "name": "Spoke2-vnet-subnet2" }
                ]
            }
        ],
        "nva": {
            "resourceGroup": "VDC-NVA"
        }
    },
```

These are good examples of the complex objects that were discussed in the previous lab, and densely describe the environment.  Note that the structure of both hub and onprem, and the objects within the spokes array have a consistent structure.  The variables could easily be parameters (with defaultValues used to describe the expected object), but the template is using variables as this environment is fairly hardcoded at the master template level.

Finally, let's take a look at the parameters sections for the various deployments.  For the hub and onprem networking deployments you'll notice that the whole object is passed through.

```json
        {
            "comments": "Create OnPrem vNet",
            "name": "Deploy-OnPrem-vNet",
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2017-05-10",
            "resourceGroup": "[variables('onprem').resourceGroup]",
            "properties": {
                "mode": "Incremental",
                "templateLink": {
                    "uri": "[variables('vnetUri')]",
                    "contentVersion": "1.0.0.0"
                },
                "parameters": {
                    "vnet": {
                        "value": "[variables('onprem')]"
                    }
                }
            }
        },
```

The vnet.json then takes that object and uses parts of it.

And the same is true for the spokes, although here we are using a copy argument to loop through the elements in the spokes array.  Again we are passing in the whole spoke object, plus the hub object.  Note that the spoke.json template only requires parts of the hub object, i.e. the name of the hub vnet and the resourceGroup, and happily oignores the rest of the information.

Creating good complex object structures that can be used in multiples building block templates is pretty powerful and keeps the template deployments short.

If you look at some of the other resource deployments in this master template then some pass in a few simple strong values pulled from those objects.  The Cisco CSR template takes no parameters at all, only determining which resource group to deploy to.

<<<<<<YOU ARE HERE>>>>>>

###### Lab 7 Files

<div class="success">
    <b>
        <li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab7/azuredeploy.json" target="_blank">azuredeploy.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab7/azuredeploy.parameters.json" target="_blank">azuredeploy.parameters.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab7/vm.json" target="_blank">vm.json</a>
        </li>
    </b>
</div>

I have duplicated the vmUri assignment in the azuredeploy.json in case you needed to see the hardcoded version mentioned in the section about submission.

This lab also used a collection of files to describe how to use nested templates.  If you would like to see the full set then here is the directory within my GitHub repository:

###### Nested Template Files

<div class="success">
    <b>
        <li>
          <a href="https://github.com/richeney/arm/tree/master/nestedTemplates" target="_blank">Azure Resource Manager Workshop Nested Template files</a>
        </li>
    </b>
</div>

## Summary

We have worked through a lot of labs, and hopefully you have built up a wealth of capability and knowledge of the resources available to you.  For the larger deployments, making use of the various constructs makes sense.  From the partner perspective there are a number of ways of leveraging them, but the following is one way of doing it:

1. Invest the time to create flexible and functionally rich building blocks that meet as many scenarios as possible
1. Incorporate t-shirt sizes to group properties together and standardise
1. Create master templates to fit different architectural standards or application patterns with sensible default parameter values
1. Use parameter files to define the customer's default values
1. Override as required on submission

One key thing to remember is that all of this only makes sense if you know that you will have sufficient reuse of the templates to justify the time investment. However, defining ARM templates is one of the ways that will help you to define your Azure offering and most customers will prefer using proven IP to designing a bespoke (and arguably less supportable) design from a blank piece of paper.

Now that you have some idea of the capabilities then it is a great time to take a look at some of the excellent information provided by the Azure Customer Advisory Team (AzureCAT).  There is a great Azure documentation page on [best practices for complex designs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/best-practices-resource-manager-design-templates), and that includes a link to a fuller whitepaper.  This information has been pulled together with some of the design learning gained from deployments with large enterprises, service integrators and ISVs, including some of the largest open source software.

This is highly recommended reading before you go from here and start producing your own world class Azure templates.  Good luck!

[◄ Lab 6: Complex](../arm-lab6-complex){: .btn-subtle} [▲ Index](../#index){: .btn-success}
