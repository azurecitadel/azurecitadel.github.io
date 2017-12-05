---
layout: article
title: 'ARM Lab 2: Parameter files, resources'
date: 2017-11-17
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab1-firstTemplate
  title: Creating your first template
next:
  url: ../arm-lab3-moreComplex
  title: Utilising more complex functions 
---

{% include toc.html %}

## Overview

The snippets we used in lab 1 are very useful and easy to use.  They meet most basic needs, but they have a couple of significant failings:
* They are not actively maintained and therefore do not include all of the new functionality
* They do not cover all of the services available on Azure

In this lab we will create templates from some of the other major sources of resource type information to speed up the templating process and enable infrastructure as code deployments for some of the newer or more exotic services available on the Azure platform.

1. First we will use the export functionality from the portal immediately prior to submission
1. We will then use the semi-hidden ARM template editor in the portal
1. Finally we will leverage some of the IP on the Azure quickstart templates on GitHub

## A. Web Apps

This is a good lab to talk about API versions and the reference documentation.  

We'll see that the snippets are outdated and missing certain new capabilities.  We will use the export to get a more up to date version, and in combination with the reference material we will then update the template to create the parameterisation options that we want for our standardised deployment.

### Examining the snippets and comparing against the reference documentation

Let's look at the snippets for web apps.  When you create a web app, it also needs an app service plan.  

* Create a new azuredeploy.json template in a lab2a folder.
* Add in two new snippets:
  * arm-plan
  * arm-webapp

You will notice that the API versions for both are a little old:

**Resource.Provider/type** | **Snippet apiVersion** 
Microsoft.Web/serverfarms | 2014-06-01
Microsoft.Web/site | 2015-08-01

If you search on "arm template reference" then the top link will have the information onhow to access reference materials on the resource types.  The pathing is  https://docs.microsoft.com/en-gb/azure/templates/_resource.provider_/_type_, so for the two resources it would be:

**Resource.Provider/type** | **Snippet apiVersion** 
[Microsoft.Web/serverfarms](https://docs.microsoft.com/en-gb/azure/templates/Microsoft.Web/serverfarms) | 2016-09-01
[Microsoft.Web/sites](https://docs.microsoft.com/en-gb/azure/templates/Microsoft.Web/sites) | 2016-08-01

Note that not all enhancements to an Azure service require a change to the JSON schema for the service.  Many enhancements can be accommodated as additional values for existing properties within the current schema.

Note that there does not appear to be a way of seeing the full reference documentation for older API versions.  Also there can be a slight lag between new functionality being available and the reference documentation being updated.  For that you can search for the resource type in the [GitHub repo](https://github.com/Azure/azure-resource-manager-schemas/tree/master/schemas).  This will find the updated schema sections for the resource type that are pulled together for the full resource provider schema.  Understanding this in depth is outside of the scope of the lab.

### Exporting from the portal

OK, let's export an example template and parameters file.

**Follow the steps below, but make sure you stop just prior to submission via the final 'Create' button.**

* Open the Azure [portal(https://portal.azure.com)]
* Click **+ Add** on the left
* Search for "Web App"
* Select and click on Create
  * App Name: **\<yourname>arm** (has to be unique)
  * Resource Group: Create New, called **lab2a**
  * App Service Plan / Location: Click on the **>** arrow
    * Create new
    * App Service Plan: **Free**
    * Location: **West Europ**
    * Pricing tier: **F1 Free**

**_DO NOT CLICK ON THE CREATE BUTTON!_** Click on the _Automation Options_ link instead.

This will open up the template that the portal has created on the fly.  If you tab through the Template, Parameters, CLI, PowerShell, .NET and Ruby tabs then you will see the two JSON templates, plus deployment code for the various CLIs and key SDKs.

Let's copy out the template and parameter file into lab2a folder of our project as azuredeploy.json and azuredeploy.parameters.json respectively.  

### Factoring parameters and variables

Examine the resources.  You'll notice that both are newer than the snippets, but whilst the App Service plan (serverfarm) is up to date, the Web App (sites) is a little out.  You will also notice that pretty much everything is parameterised.

Here are example inital files: 

```json
{
    "parameters": {
        "name": {
            "type": "string"
        },
        "hostingPlanName": {
            "type": "string"
        },
        "hostingEnvironment": {
            "type": "string"
        },
        "location": {
            "type": "string"
        },
        "sku": {
            "type": "string"
        },
        "skuCode": {
            "type": "string"
        },
        "workerSize": {
            "type": "string"
        },
        "serverFarmResourceGroup": {
            "type": "string"
        },
        "subscriptionId": {
            "type": "string"
        }
    },
    "resources": [
        {
            "apiVersion": "2016-03-01",
            "name": "[parameters('name')]",
            "type": "Microsoft.Web/sites",
            "properties": {
                "name": "[parameters('name')]",
                "serverFarmId": "[concat('/subscriptions/', parameters('subscriptionId'),'/resourcegroups/', parameters('serverFarmResourceGroup'), '/providers/Microsoft.Web/serverfarms/', parameters('hostingPlanName'))]",
                "hostingEnvironment": "[parameters('hostingEnvironment')]"
            },
            "location": "[parameters('location')]",
            "tags": {
                "[concat('hidden-related:', '/subscriptions/', parameters('subscriptionId'),'/resourcegroups/', parameters('serverFarmResourceGroup'), '/providers/Microsoft.Web/serverfarms/', parameters('hostingPlanName'))]": "empty"
            },
            "dependsOn": [
                "[concat('Microsoft.Web/serverfarms/', parameters('hostingPlanName'))]"
            ]
        },
        {
            "apiVersion": "2016-09-01",
            "name": "[parameters('hostingPlanName')]",
            "type": "Microsoft.Web/serverfarms",
            "location": "[parameters('location')]",
            "properties": {
                "name": "[parameters('hostingPlanName')]",
                "workerSizeId": "[parameters('workerSize')]",
                "reserved": false,
                "numberOfWorkers": "1",
                "hostingEnvironment": "[parameters('hostingEnvironment')]"
            },
            "sku": {
                "Tier": "[parameters('sku')]",
                "Name": "[parameters('skuCode')]"
            }
        }
    ],
    "$schema": "http://schema.management.azure.com/schemas/2014-04-01-preview/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0"
}
```

Configure vscode to have both the azuredeploy.json and the azuredeploy.parameters.json side by side.

![vscode](/workshops/arm/images/lab2-1-vscode.png)

We have a few too many parameters for our service so let's refactor it down to a completely minimal set of parameters, i.e. just the Web App name.  The quickest way to hardcode or derive certain options is to move them down to the variables section.   

Quick guide:

1. Add in a variables section
1. Create variable names to match the names of parameters to be "moved"
  1. Hardcode the values where sensible
  1. Derive th evalues where possible
1. Remove parameters that are no longer required
1. Change the appropriate parameter calls in the resources section to variable calls
1. Add in default values and allowed values for remaining parameters
1. Strip down the parameters file to only the required parameter values
1. Test

<video video width="800" height="600" controls autoplay muted>
  <source type="video/mp4" src="/workshops/arm/arm-lab2-portalExport.md/images/refactoringExport.mp4}"></source>
  <p>Your browser does not support the video element.</p>
</video>

Note that from this point onwards only the bash commands will be shown for brevity.  It is not difficult to create the corresponding PowerShell commands.  If you are running CLI 2.0 within PowerShell then explicitly state the string variables rather than derive them from other variables or command output.

```bash
rg=lab2
template=$(pwd)/lab2a/azuredeploy.json
parms=$(pwd)/lab2a/azuredeploy.parameters.json
job=job.$(date --utc +"%Y%m%d.%H%M")
az group deployment create --name $job --parameters "@$parms" --template-file $template --resource-group $rg
```

Here is my final azuredeploy.json file:

```json
{
    "parameters": {
        "name": {
            "type": "string"
        }  
    },
    "variables": {
        "hostingPlanName": "[concat(parameters('name'), '-plan')]",
        "hostingEnvironment": "",
        "location": "[resourceGroup().location]",
        "sku": "Free",
        "skuCode": "F1",
        "workerSize": "0",
        "serverFarmResourceGroup": "[resourceGroup().name]",
        "subscriptionId": "[subscription().subscriptionId]"
    },
    "resources": [
        {
            "apiVersion": "2016-03-01",
            "name": "[parameters('name')]",
            "type": "Microsoft.Web/sites",
            "properties": {
                "name": "[parameters('name')]",
                "serverFarmId": "[concat('/subscriptions/', variables('subscriptionId'),'/resourcegroups/', variables('serverFarmResourceGroup'), '/providers/Microsoft.Web/serverfarms/', variables('hostingPlanName'))]",
                "hostingEnvironment": "[variables('hostingEnvironment')]"
            },
            "location": "[variables('location')]",
            "tags": {
                "[concat('hidden-related:', '/subscriptions/', variables('subscriptionId'),'/resourcegroups/', variables('serverFarmResourceGroup'), '/providers/Microsoft.Web/serverfarms/', variables('hostingPlanName'))]": "empty"
            },
            "dependsOn": [
                "[concat('Microsoft.Web/serverfarms/', variables('hostingPlanName'))]"
            ]
        },
        {
            "apiVersion": "2016-09-01",
            "name": "[variables('hostingPlanName')]",
            "type": "Microsoft.Web/serverfarms",
            "location": "[variables('location')]",
            "properties": {
                "name": "[variables('hostingPlanName')]",
                "workerSizeId": "[variables('workerSize')]",
                "reserved": false,
                "numberOfWorkers": "1",
                "hostingEnvironment": "[variables('hostingEnvironment')]"
            },
            "sku": {
                "Tier": "[variables('sku')]",
                "Name": "[variables('skuCode')]"
            }
        }
    ],
    "$schema": "http://schema.management.azure.com/schemas/2014-04-01-preview/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0"
}
```

And the corresponding azuredeploy.parameters.json:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "name": {
            "value": "richeneyarm"
        }
    }
}
```

Note the 'dependsOn' property.  This is an explicit dependency.

You will also see implicit dependencies, where resource properties in one resource are derived from the properties of another resources.  Again, the Azure Resource Manager layer will intelligently understand the implicit relationship and will order the resource creation accordingly.    

It is possible to export a whole resource group definition as ARM JSON.  This is very verbose and it will hardcode many of the property values.  However, it is useful to compare the files before and after a manual change to see how that can be driven using ARM.

1. Open up the blade for the resource group once it has succesafully deployed 
1. Click on Automation Script in the Settings section
1. Copy out the JSON into a new file within vscode
1. Open up the Web App blade
1. Select CORS in the API section
1. Enter in a valid origin site and port, e.g. `http://azurecitadel.github.io:1976`
1. Click on Save
1. Go back up to the resource group and click on Automation Script again
1. Copy out the "after" version of the JSON and paste it into another new file in vscode
1. Use the 'File: Compare Active File With...' to see the difference

![Compare](/workshops/arm/images/lab2-3-compareRgExports.png)

## Hidden Template Editor

The second way of getting resources is to use the Azure Resource Manager template editor that is built into the portal itself.  The Templates area in the portal allows you to save templates you use repeatedly, and the portal is one of the many possible deployment types.  

The Templates editor is a little hidden away, so you have to search on "templates" in the search bar at the top of the [portal](https://ms.portal.azure.com/#create/Microsoft.Template).

![Template Editor](/workshops/arm/images/searchTemplatesInPortal.png)

1. Click on the "Build you own template in the editor" link 
1. Add in a Storage Account, with "sa" as the prefix
1. Add in a Virtual Network, called "vnet"
1. Add in an Ubuntu server, called "myUbuntuServer"
  1. Select the "sa" Storage Account
  1. Select the "vnet" Virtual Network
1. Save, or copy and paste out the contents into your own azuredeploy.json file in a lab2b folder.

Here is the resulting template:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "saType": {
            "type": "string",
            "defaultValue": "Standard_LRS",
            "allowedValues": [
                "Standard_LRS",
                "Standard_ZRS",
                "Standard_GRS",
                "Standard_RAGRS",
                "Premium_LRS"
            ]
        },
        "myUbuntuServerName": {
            "type": "string",
            "minLength": 1
        },
        "myUbuntuServerAdminUserName": {
            "type": "string",
            "minLength": 1
        },
        "myUbuntuServerAdminPassword": {
            "type": "securestring"
        },
        "myUbuntuServerUbuntuOSVersion": {
            "type": "string",
            "defaultValue": "14.04.2-LTS",
            "allowedValues": [
                "12.04.5-LTS",
                "14.04.2-LTS",
                "15.04"
            ]
        }
    },
    "resources": [
        {
            "name": "[variables('saName')]",
            "type": "Microsoft.Storage/storageAccounts",
            "location": "[resourceGroup().location]",
            "apiVersion": "2015-06-15",
            "dependsOn": [],
            "tags": {
                "displayName": "sa"
            },
            "properties": {
                "accountType": "[parameters('saType')]"
            }
        },
        {
            "name": "vNet",
            "type": "Microsoft.Network/virtualNetworks",
            "location": "[resourceGroup().location]",
            "apiVersion": "2015-06-15",
            "dependsOn": [],
            "tags": {
                "displayName": "vNet"
            },
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "[variables('vNetPrefix')]"
                    ]
                },
                "subnets": [
                    {
                        "name": "[variables('vNetSubnet1Name')]",
                        "properties": {
                            "addressPrefix": "[variables('vNetSubnet1Prefix')]"
                        }
                    },
                    {
                        "name": "[variables('vNetSubnet2Name')]",
                        "properties": {
                            "addressPrefix": "[variables('vNetSubnet2Prefix')]"
                        }
                    }
                ]
            }
        },
        {
            "name": "[variables('myUbuntuServerNicName')]",
            "type": "Microsoft.Network/networkInterfaces",
            "location": "[resourceGroup().location]",
            "apiVersion": "2015-06-15",
            "dependsOn": [
                "[concat('Microsoft.Network/virtualNetworks/', 'vNet')]"
            ],
            "tags": {
                "displayName": "myUbuntuServerNic"
            },
            "properties": {
                "ipConfigurations": [
                    {
                        "name": "ipconfig1",
                        "properties": {
                            "privateIPAllocationMethod": "Dynamic",
                            "subnet": {
                                "id": "[variables('myUbuntuServerSubnetRef')]"
                            }
                        }
                    }
                ]
            }
        },
        {
            "name": "[parameters('myUbuntuServerName')]",
            "type": "Microsoft.Compute/virtualMachines",
            "location": "[resourceGroup().location]",
            "apiVersion": "2015-06-15",
            "dependsOn": [
                "[concat('Microsoft.Storage/storageAccounts/', variables('saName'))]",
                "[concat('Microsoft.Network/networkInterfaces/', variables('myUbuntuServerNicName'))]"
            ],
            "tags": {
                "displayName": "myUbuntuServer"
            },
            "properties": {
                "hardwareProfile": {
                    "vmSize": "[variables('myUbuntuServerVmSize')]"
                },
                "osProfile": {
                    "computerName": "[parameters('myUbuntuServerName')]",
                    "adminUsername": "[parameters('myUbuntuServerAdminUsername')]",
                    "adminPassword": "[parameters('myUbuntuServerAdminPassword')]"
                },
                "storageProfile": {
                    "imageReference": {
                        "publisher": "[variables('myUbuntuServerImagePublisher')]",
                        "offer": "[variables('myUbuntuServerImageOffer')]",
                        "sku": "[parameters('myUbuntuServerUbuntuOSVersion')]",
                        "version": "latest"
                    },
                    "osDisk": {
                        "name": "myUbuntuServerOSDisk",
                        "vhd": {
                            "uri": "[concat('http://', variables('saName'), '.blob.core.windows.net/', variables('myUbuntuServerStorageAccountContainerName'), '/', variables('myUbuntuServerOSDiskName'), '.vhd')]"
                        },
                        "caching": "ReadWrite",
                        "createOption": "FromImage"
                    }
                },
                "networkProfile": {
                    "networkInterfaces": [
                        {
                            "id": "[resourceId('Microsoft.Network/networkInterfaces', variables('myUbuntuServerNicName'))]"
                        }
                    ]
                }
            }
        }
    ],
    "variables": {
        "saName": "[concat('sa', uniqueString(resourceGroup().id))]",
        "vNetPrefix": "10.0.0.0/16",
        "vNetSubnet1Name": "Subnet-1",
        "vNetSubnet1Prefix": "10.0.0.0/24",
        "vNetSubnet2Name": "Subnet-2",
        "vNetSubnet2Prefix": "10.0.1.0/24",
        "myUbuntuServerImagePublisher": "Canonical",
        "myUbuntuServerImageOffer": "UbuntuServer",
        "myUbuntuServerOSDiskName": "myUbuntuServerOSDisk",
        "myUbuntuServerVmSize": "Standard_D1",
        "myUbuntuServerVnetID": "[resourceId('Microsoft.Network/virtualNetworks', 'vNet')]",
        "myUbuntuServerSubnetRef": "[concat(variables('myUbuntuServerVnetID'), '/subnets/', variables('vNetSubnet1Name'))]",
        "myUbuntuServerStorageAccountContainerName": "vhds",
        "myUbuntuServerNicName": "[concat(parameters('myUbuntuServerName'), 'NetworkInterface')]"
    }
}
```

This is a very quick way of creating some of the most commonly used template resources, and it is nice in that it creates a mix of resources, variables and parameters. Note that the OS disks in this template are the older storage account version, rather than Managed Disks.

You'll also notice the lack of a parameters file.  This is because it is intended for you to deploy interactively in the portal, but once you save you can edit the template and the parameters file, and that gives you an opportunity to save them both out and then refactor as you see fit. However it should be noted that the password will not follow our best practices for secure strings.  More in that in lab 3. 

## Azure Quickstart templates

In the previous section we were working in the portal, and you may have noticed the "Load a GitHub quickstart template" option.  There is a GitHub repo that has a wide selection of ARM templates that have been contributed by both Microsoft employees and by the wider community.  You can find it by searching for "Azure quickstart templates", which will find both the main [Azure Quickstart GitHub repo](https://github.com/Azure/azure-quickstart-templates) and the [Azure Quickstart Templates portal](https://azure.microsoft.com/en-gb/resources/templates/) site that helps to navigate some of the content.  

Go via either route and search for "deploy a simple linux VM".  You'll find a number of templates, but we'll take a look at the "201-multi-vm-lb-zones" template that has been contributed by Brian Moore, one of the Microsoft employees based in Fargo.  If you have gone through the Microsoft Azure route, then select the  Browse on GitHub button.  You should now be [here](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-simple-linux).

You will find the azuredeploy.json and azuredeploy.parameters.json as expected.  There are also a couple of other files that are there for the repo to work as expected:

1. **metadata.json** contains the information that dictates how the entry is shown in the Microsoft Azure Quickstart Templates site.  The parameters information is pulled directly from the azuredeploy.json, pulling out the parameter name and metadata description.
1. **readme.md** is a readme file in markdown format.  Click on the raw format to see how the markdown is written and rendered into the static HTML that you see when browsing the GitHub repo itself.

Copy out the azuredeploy.json and azuredeploy.parameters.json out into new files in a lab2c folder. Thi sis easier when looking at the raw versions.

The 101-vm-simple-linux template is one of the simpler templates, but it gives us an opportunity to see how a virtual machine is constructed, and some of the common practices when developing templates.

#### Parameters

The parameters are well defined with good defaults and allowed values for the ubuntuOSVersion.  As mentioned above, the metadata.description is set for each as this is used in the Microsoft Azure overview page.

Looking at the corresponding azuredeploy.parameters.json file, it is usual to pass the first three parameters, admin user and password, and the DNS label for the public IP.  Note again that the password string is defined as a securestring, so once deployed you will not be able to see the value, but the password will be in clear text in the parameters file.  

We will address this soon enought, looking at both using secrets held in Key Vault and also controlling access to JSON files hosted centrally.   

#### Variables

There are a large number of variables.  There is always the option to refactor some of these up into the parameters section, such as vmName, vmSize, subnet names etc.  

Using good variable names makes the main resource section much easier to read and understand, especially if it means that you avoid length concat functions for the resource IDs.

#### Resources

One thing that is not necessary, but is very good practice, is to put the resources in rough order of instantiation.  You can see that in this template.

The  storage account, public IP (PIP) and vNet are created first as they have no dependencies.  They will be deployed in parallel by ARM.  Note also that a single subnet is created as a child resource in the vNet.

The NIC is then created.  Pay attention to the dependsOn array, which contains the resourceId function for both the vNet and the PIP.  These cannot be predefined as a variable as those resources are not available at the time of interpretation.  But ARM will see those and make the appropriate dependencies, taking the ID from those resources once they have been created.

**YOU ARE HERE**