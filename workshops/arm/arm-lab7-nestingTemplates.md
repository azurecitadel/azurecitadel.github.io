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
       "uri":"https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/vnet-spoke.json",
       "contentVersion":"1.0.0.0"
    },
```  

The URI must be an http or https file.  You cannot use FTP or local files.  A Git repository is common (either GitHub or a private repo), as is using blob storage, potentially with SAS tokens to control access.

For the URI itself, you can hardcode them, but it is more common to [use variables](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates#using-variables-to-link-templates) to define them dynamically. The `deployment().properties.templateLink.uri` function can be used to return the base URL for the current template, and the uri() function.  The [functions](https://aka.ms/armfunc) area goes into more detail on the usage.

The contentVersion string is not required.  So far we have not been versioning our templates as we have modified them, but using linked templates is a good reason to consider doing so. When you specify the contentVersion string then the deployment will check that the contentVersion is a direct match.  For example, imagine you substantially change a building block template to the point that the parameters change.  If that template is linked to by a number of master templates then this would fail.  An update to the master templates with a correctly configured parameters section and an updated contentVersion string would be required before the deployment would go through successfully.

You'll also notice the optional 'resourceGroup' string. This permits us to have templates that deploy to different resource groups.  Let's take a look at an example of that.

### Example of an inline template

For larger organisations a [hub and spoke topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) is a recommended virtual data centre architecture to provide service isolation, network traffic control, billing and role based access control (RBAC).

Use CTRL+O in vscode and open up the `https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/vnet-spoke.json` file.

The vnet-spoke.json will create a spoke vNet, and will also create a vNet peering back to a pre-existing hub vNet.  For that peering to work, the Microsoft.Network/virtualNetworks/virtualNetworkPeerings resource type needs to be created at both ends to create the connection.  Therefore the vNet peering from the hub to the spoke needs to be created in the hub's resource group.  

The hub vNet name and resource group are part of the expected parameters, but let's look at the two ends of the peering:

```json
    {
      "condition": "[parameters('peer')]",
      "name": "[concat(parameters('spoke').vnet.name, '/peering-to-', parameters('hub').vnet.name)]",
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
      "name": "[concat('peer-', parameters('hub').vnet.name, '-to-', parameters('spoke').vnet.name)]",
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
                "name": "[concat(parameters('hub').vnet.name, '/peering-to-', parameters('spoke').vnet.name)]",
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

The second peering, however, is a nested inline template deployment (`Microsoft.Resources/deployments`) which gives us the flexibility to deploy into a different resource group.   We have the embedded inline template deploying the peering into the hub vNet and into the hub's resource group. Once both ends are in place then the peering is established.

Taking this approach has made the vnet-spoke.json building block more functional and rather neat and tidy.

There is a corresponding `https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/vnet-hub.json` file for creating the hub, and it creates the hub vNet with a couple of standard subnets, plus a GatewaySubnet containing a VPN gateway with a public IP. As the public IP is dynamically allocated we ideally want to be able to determine the value and output that at the end.

However, this brings up an interesting problem with public IPs in that the dynamic IP address is only allocated once the NIC is online, i.e.when the gateway itself is up.  As the reference() function shows the current runtime state of the resource, trying to return `"[reference(variables('gatewayPipId')).ipAddress]` would fail first time round as the IP address isn't allocated, but will work for a redeployment. So we'll avoid that by returning just the resource ID instead, as it is a simple one line CLI command to find out the IP address once you have that resource ID:  

```json
  "outputs": {
    "gatewayPipId": {
      "type": "string",
      "value": "[variables('gatewayPipId')]"    
    }
  }
```

OK, let's take a look at how those two building blocks could be used by a master template.

### Example of a master template calling linked templates

Open up the `https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/azuredeploy.json` master template, and the corresponding `https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/azuredeploy.parameters.json` parameters file.

The template will create:
* a single hub vNet, containing a number of subnets, and the GatewaySubnet can also include an optional VPN Gateway and public IP address
* one or more spoke vNets, also containing a number of subnets, with a vNet peering back to the hub vNet

First of all, take a look at the parameters.  The main template has defaults, which are pretty much there for testing and to describe the expected parameter objects.  Below are the ones from the parameters file:

###### Parameters
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

Before we move onto the resources themselves, take a look at the first two variables:

###### Variables Section
```json
  "variables": {
    "hubUrl": "[uri(deployment().properties.templateLink.uri, 'vnet-hub.json')]",
    "spokeUrl": "[uri(deployment().properties.templateLink.uri, 'vnet-spoke.json')]",
    "hubDeploymentName": "[concat('deployHub-', parameters('hub').vnet.name)]"
  },
```

Using a combination of the uri() and deployment() functions is a great way of determining the path for the master template and deriving the linked template names from it.  These files are in the same directory as the master template and parameters file, but you will often see the linked templates in a subdirectory, e.g. `"spokeUrl": "[uri(deployment().properties.templateLink.uri, '/nested/vnet-spoke.json')]"`.

<div class="warning">WARNING: Using deployment().properties.templateLink.uri will only return a value if the --template-uri switch is used. The deployment will fail validation if --template-file is used.</div>

OK, here is the hub deployment.  Note how we are sending all of the parameters individually:

###### Hub Resource
```json
  "resources": [
    {
      "name": "[variables('hubDeploymentName')]",
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2017-05-10",
      "resourceGroup": "[parameters('hub').resourceGroup]",
      "properties": {
        "mode": "Incremental",
        "parameters": {
          "vnetName": {
              "value": "[parameters('hub').vnet.name]"
          },
          "vNetAddressPrefixes": {
              "value": "[parameters('hub').vnet.addressPrefixes]"
          },
          "subnets": {
              "value": "[parameters('hub').subnets]"
          },
          "createGateway": {
              "value": "[parameters('hub').createGateway]"
          },
          "gatewaySku": {
              "value": "[parameters('hub').gatewaySku]"
          }
        },
        "templateLink": {
          "uri": "[variables('hubUrl')]",
          "contentVersion": "1.0.0.0"
        }
      }
    }, ...
```
We are pulling out a number of elements from our main hub parameter object.  The .vnet.name and .gatewaySku are strings, .createGateway is a boolean, and both .vnet.addressPrefixes and .subnets are arrays, and these match the parameter types expected by the parameters section of the vnet-hub.json template.

###### Spoke Resources
```json
    ...,
    {
        "name": "[concat('deploySpoke', copyIndex(1), '-', parameters('spokes')[copyIndex()].vnet.name)]",
        "type": "Microsoft.Resources/deployments",
        "apiVersion": "2017-05-10",
        "resourceGroup": "[parameters('spokes')[copyIndex()].resourceGroup]",
        "dependsOn": [
            "[concat('Microsoft.Resources/deployments/', variables('hubDeploymentName'))]"
        ],
        "copy": {
            "name": "spokecopy",
            "count": "[length(parameters('spokes'))]",
            "mode": "Serial",
            "batchSize": 1
        },
        "properties": {
          "mode": "Incremental",
          "parameters": {
            "peer": {
                "value": true
            },
            "hub": {
                "value": "[parameters('hub')]"
            },
            "spoke": {
                "value": "[parameters('spokes')[copyIndex()]]"
            }
          },
          "templateLink": {
            "uri": "[variables('spokeUrl')]",
            "contentVersion": "1.0.0.0"
          }
        }
      }
```

There are a few interesting points for this section.  

1. The resource deployment has a copy, based on the number of members in that spoke parameter array.  Therefore if the parameters have, say six spokes, then there will be six deployments, all individually named with the spoke number and suffixed by the vNet name for that spoke.  We have a dependency on the hub deployment (as we are peering to it) and the copy overrides the default parallel mode to deploy the spokes one by one.  The main reason is that the two way vNet peering resources in the spoke template can throw up a conflict if multiple jobs are peppering the hub vNet at the same time.  Running them sequentially avoids that scenario.
2. The parameter section is more of a passthrough than the section we saw earlier for the hub linked template.  The format of the hub parameter closely matches what is expected by the spoke linked template.  In this way, using objects is much more flexible.  There are some elements of the main hub parameter object that are not used by the spoke linked template, but that does not matter; the spoke template just expects an object to be passed.  Therefore this proves a little more extensible.
3. The spokes parameter for the master template is an array.  However we are not passing that full array through to the linked template.  Instead the spoke parameter is the individual member spoke object within that array, based on the copyIndex(), and matches the object expected by the parameters section in that template.  

The last thing we want the master template to do for us is to surface the resource ID for the VPN gateway's public IP.  If you remember, the output section of the vnet-hub.json template looked like this:

###### Outputs section for vnet-hub.json 
```json
  "outputs": {
    "gatewayPipId": {
      "type": "string",
      "value": "[variables('gatewayPipId')]"    
    }
  }
```

We can use the reference() function against the hub deployment resource itself to pull out the gatewayPipID string that the linked template will put in its output section.

###### Outputs section for vnet-hub.json 
```json
  "outputs": {
    "vpnGatewayPipId": {
        "type": "string",
        "value": "[reference(variables('hubDeploymentName')).outputs.gatewayPipId.value]"
    }
  }
``` 

Here are a few lines selected from an example [deploy.sh](https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/deploy.sh) script to show how the resource ID is pulled from the deployment and then the single az command is used to output the VPN gateway IP address which will have been allocated by that point:

###### deploy.sh (partial)
```bash
templateUri="https://raw.githubusercontent.com/richeney/arm/master/nestedTeamples/azuredeploy.json"
parametersUri="https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/azuredeploy.parameters.json"

# Pull out parameters into a multi line variable
parameters=$(curl --silent "$parametersUri?$(date +%s)" | jq .parameters)

# Determine the resource groups from the parameters variable
hubrg=$(jq --raw-output .hub.value.resourceGroup <<< $parameters)
spokergs=$(jq --raw-output .spokes.value[].resourceGroup <<< $parameters)

# Create the resource groups is they do not exist
echo "Checking or creating resource groups:" >&2
for rg in $hubrg $spokergs
do az group create --location $loc --name $rg --output tsv --query name | sed 's/^/- /1'
done 

# Deploy the templates and find out the gateway's PIP
query="properties.outputs.vpnGatewayPipId.value"
vpnGatewayPipId=$(az group deployment create --resource-group $hubrg --template-uri $templateUri --query $query --output tsv --parameters "$parameters" --verbose)
az network public-ip show --ids $vpnGatewayPipId --query ipAddress --output tsv
```

The full script includes some good descriptive comments, but you can see from these commands that we are pulling out the PIP ID from the outputs of the master template, and then using that with a short JMESPATH query to grab the IP address. (For more information on using JMESPATH queries then look at the [CLI guide](https://azurecitadel.github.io/guides/cli/).) 

## Lab to dynamically handle key vault and secret names

OK, do you remember first using key vault secrets back in lab3? If you remember, the adminPassword's type in the [azuredeploy.json](https://raw.githubusercontent.com/richeney/arm/master/lab3/azuredeploy.json) template is set to securetext as per normal.  This ensures that the deployment logs never include the password.  In the parameter file, [azuredeploy.parameters.json](https://raw.githubusercontent.com/richeney/arm/master/lab3/azuredeploy.parameters.json) used the reference() function to grab the value of secret held in the key vault so that it wasn't shown as plaintext in that file as well.  However the values for both the key vault name and the secret name were hardcoded as the parameters file does not support any of the functions that we can use in the main ARM templates.

This lab will make use of nested templates to make the key vault name and the secret name dynamic.  Labs 4 and 5 improved on our lab 3 virtual machine templates so we'll use lab 5 as the base for lab 7.


Here is a loose guide of what to do, rather than a set of explicit instructions.  

1. Create a lab7 folder
1. Copy the lab5 [azuredeploy.json](https://raw.githubusercontent.com/richeney/arm/master/lab5/azuredeploy.json) into lab7 as vm.json
1. Create a new azuredeploy.json file. 
1. The parameters section should be consistent with vm.json, with the following changes:
    * remove adminPassword
    * add strings for keyVaultName and secretName
1. In your variables section, derive the uri for the vm.json file 
1. Create a deployment resource to use that uri as a linked template
1. Ensure the parameters section for the deployment resource passes through adminPassword to the linked template
1. Create a new parameters file, based on the lab5 [azuredeploy.parameters.json](https://raw.githubusercontent.com/richeney/arm/master/lab5/azuredeploy.parameters.json), but with the required changes
1. Feel free to create additional key vaults and/or secrets and then test your new template

For bonus points, feel free to incorporate complex parameter objects and/or variable objects for the t-shirt sizes. 

## Final files

There are many ways of completing that lab, so if you got it to work then it's all good.  If you want to see my files then here you go:

###### Lab 7 Files:
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

This lab also used a collection of files to describe how to use nested templates.  If you would like to see the full set then here is the directory within my GitHub repository:

###### Nested Template Files:
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