---
layout: article
title: 'ARM Lab 2: Functions & sources of template information'
date: 2018-01-08
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template, functions]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab1-firstTemplate
  title: Creating your first template
next:
  url: ../arm-lab3-referencesAndSecrets
  title: Referencing resource properties and using secrets 
---

{% include toc.html %}

## Overview

The snippets we used in lab 1 are very useful and easy to use.  They meet most basic needs, but they have a couple of significant failings:
* They are not actively maintained and therefore do not include all of the new functionality
* They do not cover all of the services available on Azure

In this lab we will create templates from some of the other major sources of resource type information to speed up the templating process and enable us to deploy infrastructure as code for some of the higher value services available on the Azure platform, or to make use of newer functionality.

1. First we will use the export functionality from the portal immediately prior to submission
1. We will then use the semi-hidden ARM template editor in the portal
1. Finally we will leverage some of the IP on the Azure quickstart templates on GitHub

But before we start moving through those areas, let's take a few moments to look at the wealth of functions that are available to the ARM templates.  We'll start to see more of them as we work through the various sections of the lab so it is worth spending some time to understand that range of capability.

## ARM Template Functions

The documentation for the ARM template functions is one of those areas that you will visit often, and the short URL **https://aka.ms/armfunc** will take you straight there.   

We'll now step through some of the functions available to ARM templates, and how they can be used.  This will not cover all of them, as the [documentation](https://aka.ms/armfunctions) for the templates is pretty good, so if you need to understand something trivial like how to trim a string with whitespace then dive in to that area and dig out the information.

The functions are split into seven groups: 
1. **[Array and object](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-array)**: used to manipulate or test JSON arrays and objects
1. **[Comparison](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-comparison)**: which are a group of test operators used by the **condition** function
1. **[Deployment](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-deployment)**: which covers those related to the deployment job, e.g. the parameters and variables functions
1. **[Logical](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-logical)**: which are a group used in logical expressions, such as _if_,  _and_ and _or_, or converting strings to booleans
1. **[Numerical](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-numeric)**: the group providing integer and floating point arithmetic operators
1. **[Resource](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-resource)**: a very useful set for working with Azure Resource Manager constructs, such as info and IDs for the subscription, resource group, resources and providers, plus keys of resources, and references to a resources current state
1. **[Strings](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-string)**: and the final set provides a large set of functions to manipulate and test strings

Browse through the section to understand the breadth of functions available.  

Another way of thinking about functions is to split them into those used to:
* get 
* manipulate
* test   

You will see many of these functions used by some of the more complex templates that we will come across as we continue to work through the labs. 

------------------

## Exporting templates from the portal

We'll now look at different places to source templates and we'll start with exporting templates directly out of the Azure portal itself.  There are a couple of ways of doing this:
1. viewing the _automation options_ prior to resource deployment
1. creating a full export of a whole resource group

Both have their benefits and limitations and the labs will hopefully illustrate this.  This is also a good lab to talk about API versions and to start utilising the reference documentation.  

We'll see that the snippets we've been using can be a little outdated and missing certain new capabilities.  We will use the export to get a more up to date version, and in combination with the reference material we will then update the template to create the parameterisation options that we want for our standardised deployment.

We'll then show how you can use the full resource group export to compare before and after template definitions to capture manual changes to a resource and then represent that in your template.  The template reference documentation does not often provide examples of the expected property values, so this can be a useful tool.

### Comparing snippets against the reference documentation

Let's look at the snippets for web apps.  When you create a web app, it also needs an app service plan.  

* Create a new azuredeploy.json template in a lab2a folder.
* Add in two new snippets to your array of resources:
  * arm-plan
  * arm-webapp

You will have to have a comma between the resources to avoid the telltale red lines that signify a syntax error.

Look at the apiVersion property for the two resource and you will notice that the API versions for both are a little old:

**Resource.Provider/type** | **Snippet apiVersion** 
Microsoft.Web/serverfarms | 2014-06-01
Microsoft.Web/site | 2015-08-01

If you search on "arm template reference" then the top link will have the information on how to access reference materials on the resource types.  You will find yourself returning to this page quite often, so it is useful that someone has set up another short URL to take you straight to the page: **https://aka.ms/armref**.  That is another short URL that is worth memorising if you end up spending a lot of time working on templates.

The full pathing to take you direct to individual resource type pages is  https://docs.microsoft.com/en-gb/azure/templates/_resource.provider_/_type_, so for the two resources in our template it would be:

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
    * Location: **West Europe**
    * Pricing tier: **F1 Free**

**_DO NOT CLICK ON THE CREATE BUTTON!_** Click on the _Automation Options_ link instead.

This will open up the template that the portal has created on the fly.  If you tab through the Template, Parameters, CLI, PowerShell, .NET and Ruby tabs then you will see the two JSON templates, plus deployment code for the various CLIs and key SDKs.

Let's copy out the template and parameter file into lab2a folder of our project as azuredeploy.json and azuredeploy.parameters.json respectively.  

### Factoring parameters and variables

Examine the resources.  You'll notice that both are newer than the snippets, but whilst the App Service plan (serverfarm) is up to date, the Web App (sites) is a little out.  You will also notice that pretty much everything is parameterised.

Here are the example initial files: 

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

Configure VS Code to have both the azuredeploy.json and the azuredeploy.parameters.json side by side.

![vscode](/workshops/arm/images/lab2-1-vscode.png)

We have a few too many parameters for our service so let's refactor it down to a completely minimal set of parameters, i.e. just the Web App name.  The quickest way to hardcode or derive certain options is to move them down to the variables section.   

Quick guide:

1. Add in a variables section
1. Create variable names to match the names of parameters to be "moved"
  1. Hardcode the values where sensible
  1. Derive the values where possible
1. Remove parameters that are no longer required
1. Change the appropriate parameter calls in the resources section to variable calls
1. Add in default values and allowed values for remaining parameters
1. Strip down the parameters file to only the required parameter values
1. Test

Here is a video that shows example files being edited.  (Note the use of CTRL-F2 in VS Code to Change All Occurrences.)

<video video width="800" height="600" controls autoplay muted>
  <source type="video/mp4" src="/workshops/arm/images/lab2-2-refactoringExport.mp4"></source>
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

### Final lab2a files

###### Lab 2a Files:
<div class="success">
    <b>
        <li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab2a/azuredeploy.json" target="_blank">azuredeploy.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab2a/azuredeploy.parameters.json" target="_blank">azuredeploy.parameters.json</a>
        </li>
    </b>
</div>

Note the 'dependsOn' property in the main azuredeploy.json.  This is an explicit dependency.

You will also see implicit dependencies, where resource properties in one resource are derived from the properties of another resources.  Again, the Azure Resource Manager layer will intelligently understand the implicit relationship and will order the resource creation accordingly.    

### Exporting a whole resource group definition

It is possible to export a whole resource group definition as ARM JSON.  This is very verbose and it will hardcode many of the property values.  However, it is useful to compare the files before and after a manual change to see how that can be driven using ARM.

1. Open up the blade for the resource group once it has successfully deployed 
1. Click on Automation Script in the Settings section
1. Copy out the JSON into a new file within VS Code
1. Open up the Web App blade
1. Select CORS in the API section
1. Enter in a valid origin site and port, e.g. `http://azurecitadel.github.io:1976`
1. Click on Save
1. Go back up to the resource group and click on Automation Script again
1. Copy out the "after" version of the JSON and paste it into another new file in VS Code
1. Use the 'File: Compare Active File With...' to see the difference

![Compare](/workshops/arm/images/lab2-3-compareRgExports.png)

If you take a look at the [web app reference page](https://docs.microsoft.com/en-gb/azure/templates/microsoft.web/sites) then you'll find the CORS property and you will also see that it is comparatively well described.  This is not always the case for some of the other resource properties, so this before and after comparison is a handy way of checking the format of the string, array or object that is expected.  

-----------

## Template editor in the Azure portal

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

This is a very quick way of creating some of the most commonly used template resources, and it is nice in that it creates a mix of resources, variables and parameters. 

On the negative side, be aware that the OS disks in this template are the older storage account version, rather than Managed Disks, and that the API versions are all from the middle of 2015.

As soon as you click on the Save button then you will be taken to the dialog blade where, as a user, you can enter the parameters expected by the template.  This then gives you the opportunity to edit and copy out both the template and the parameters file.  

###### Lab 2b Files:
<div class="success">
    <b>
        <li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab2b/azuredeploy.json" target="_blank">azuredeploy.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab2b/azuredeploy.parameters.json" target="_blank">azuredeploy.parameters.json</a>
        </li>
    </b>
</div>

And once you have them in VS Code then you can refactor the parameters and variables to meet your requirements, or update a resources sections to a newer API version.  

Note the cleartext password in the parameter file.  This does not follow our best practices for secure strings when you are deploying using parameter files.  More in that in lab 3. 

-----------------------------------

## Azure Quickstart templates

In the previous section we were working in the portal, and you may have noticed the "Load a GitHub quickstart template" option.  There is a GitHub repo that has a wide selection of ARM templates that have been contributed by both Microsoft employees and by the wider community.  You can find it by searching for "Azure quickstart templates", which will find both the main [Azure Quickstart GitHub repo](https://github.com/Azure/azure-quickstart-templates) and the [Azure Quickstart Templates portal](https://azure.microsoft.com/en-gb/resources/templates/) site that helps to navigate some of the content.

There is yet another short URL to take you straight through to the GitHub repo, which is https://aka.ms/armtemplates.  

Go via either route and search for "deploy a simple linux VM".  You'll find a number of templates, but we'll take a look at the "101-vm-simple-linux" template that has been contributed by Brian Moore, one of the Microsoft employees based in Fargo.  If you have gone through the Microsoft Azure route, then select the  Browse on GitHub button.  You should now be [here](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-simple-linux).

You will find the azuredeploy.json and azuredeploy.parameters.json as expected.  There are also a couple of other files that are there for the repo to work as expected:

1. **metadata.json** contains the information that dictates how the entry is shown in the Microsoft Azure Quickstart Templates site.  The parameters information is pulled directly from the azuredeploy.json, pulling out the parameter name and metadata description.
1. **readme.md** is a readme file in markdown format.  Click on the raw format to see how the markdown is written and rendered into the static HTML that you see when browsing the GitHub repo itself.

Copy out the azuredeploy.json and azuredeploy.parameters.json out into new files in a lab2c folder. This is easier when looking at the raw versions.

###### Lab 2c Files:
<div class="success">
    <b>
        <li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab2c/azuredeploy.json" target="_blank">azuredeploy.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab2c/azuredeploy.parameters.json" target="_blank">azuredeploy.parameters.json</a>
        </li>
    </b>
</div>

The 101-vm-simple-linux template is one of the simpler templates, but it gives us an opportunity to see how a virtual machine is constructed, and some of the common practices when developing templates.

#### Parameters

The parameters are well defined in the template with sensible defaults and allowed values for the ubuntuOSVersion.  As mentioned above, the metadata.description is set for each as this is used in the Microsoft Azure overview page.

Looking at the corresponding azuredeploy.parameters.json file, it is usual to pass the first three parameters, admin user and password, and the DNS label for the public IP.  Note again that the password string is defined as a securestring, so once deployed you will not be able to see the value, but the password will be in clear text in the parameters file.  

We will address this soon enough, looking at two different ways of preventing unwanted access to secrets:
* using secrets held in Key Vault 
* controlling access to JSON files hosted centrally

These will both be covered in future labs.   

#### Variables

There are a large number of variables.  There is always the option to refactor some of these up into the parameters section, such as vmName, vmSize, subnet names etc.  

Using good variable names makes the main resource section much easier to read and understand, especially if it means that you avoid length concat functions for the resource IDs.

#### Resources

One thing that is not necessary, but is very good practice, is to put the resources in rough order of instantiation.  You can see that in this template.

The storage account, public IP (PIP) and vNet are created first as they have no dependencies.  They will be deployed in parallel by ARM.  Note also that a single subnet is created as a child resource in the vNet.

The NIC is then created.  Pay attention to the dependsOn array, which contains the resourceId function for both the vNet and the PIP.  These cannot be predefined as a variable as those resources are not available at the time of interpretation.  But ARM will see those and make the appropriate dependencies, taking the ID from those resources once they have been created.

And finally we have the virtual machine itself which has dependencies on both the NIC and the storage account.  You will see all of these resources when you look at the resource group after a successful deployment.  

It is worth taking a moment to look at the [virtual machines reference](https://docs.microsoft.com/en-gb/azure/templates/microsoft.compute/virtualmachines) area as a virtual machine is actually one of the most complicated resources within Azure.  This template is only using a small subset of the number of possible properties in this resource type.  We will be using one of those in the next lab, in order to use a password that has been stored as a secret in Key Vault and pass that through as securetext.

Also take a look at the sub-resource type that you can have within virtual machines, the [virtual machines extensions reference](https://docs.microsoft.com/en-gb/azure/templates/microsoft.compute/virtualmachines/extensions) area. This is how you can extend the virtual machines to automatically add in virtual machine agents such as antimalware, Operations Management Suite (OMS), diagnostics, Desired State Configuration (DSC) and third party extensions such as the plugin for Chef.

When defining your building block standards for key resource types such as virtual machines, use the documentation available in the Azure Docs area.  For example, there is some fantastic information on the site for both [Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/) and [Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/) virtual machines to enable you to customise your standard build and build up your own IP.

#### Outputs 

The last section is probably the most optional out of all of the ARM template sections, but you will start to make more and more use of it if you start to nest templates, or wrap them up in other scripting.  

If you have been deploying the templates using the bash CLI with the standard JSON output, then you will see that you have some standard JSON information outputted by each deployment.  You can customise that output using the output section.  In this template it is adding in both the server's hostname, and the ssh connection string to connect to a terminal session.

Check the truncated JSON output below from a test deployment and find the outputs object:

```json
{
  "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/lab2/providers/Microsoft.Resources/deployments/job.20171208.0830",
  "name": "job.20171208.0830",
  "properties": {
    "correlationId": "9306d86d-3910-41d1-a098-63aab6a2f243",
    "debugSetting": null,
    "dependencies": [
      {
        "dependsOn": [
          {
            "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/lab2/providers/Microsoft.Network/publicIPAddresses/myPublicIP",
            "resourceGroup": "lab2",
            "resourceName": "myPublicIP",
            "resourceType": "Microsoft.Network/publicIPAddresses"
          },
          {
            "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/lab2/providers/Microsoft.Network/virtualNetworks/MyVNET",
            "resourceGroup": "lab2",
            "resourceName": "MyVNET",
            "resourceType": "Microsoft.Network/virtualNetworks"
          }
        ],
        "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/lab2/providers/Microsoft.Network/networkInterfaces/myVMNic",
        "resourceGroup": "lab2",
        "resourceName": "myVMNic",
        "resourceType": "Microsoft.Network/networkInterfaces"
      },
      {
        "dependsOn": [
          {
            "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/lab2/providers/Microsoft.Storage/storageAccounts/bgsjx5attarpasalinuxvm",
            "resourceGroup": "lab2",
            "resourceName": "bgsjx5attarpasalinuxvm",
            "resourceType": "Microsoft.Storage/storageAccounts"
          },
          {
            "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/lab2/providers/Microsoft.Network/networkInterfaces/myVMNic",
            "resourceGroup": "lab2",
            "resourceName": "myVMNic",
            "resourceType": "Microsoft.Network/networkInterfaces"
          },
          {
            "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/lab2/providers/Microsoft.Storage/storageAccounts/bgsjx5attarpasalinuxvm",
            "resourceGroup": "lab2",
            "resourceName": "bgsjx5attarpasalinuxvm",
            "resourceType": "Microsoft.Storage/storageAccounts"
          }
        ],
        "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/lab2/providers/Microsoft.Compute/virtualMachines/MyUbuntuVM",
        "resourceGroup": "lab2",
        "resourceName": "MyUbuntuVM",
        "resourceType": "Microsoft.Compute/virtualMachines"
      }
    ],
    "mode": "Incremental",
    "outputs": {
      "hostname": {
        "type": "String",
        "value": "richeneyvm.westeurope.cloudapp.azure.com"
      },
      "sshCommand": {
        "type": "String",
        "value": "ssh richeney@richeneyvm.westeurope.cloudapp.azure.com"
      }
    },
    "parameters": {
      "adminPassword": {
        "type": "SecureString"
      },
      "adminUsername": {
        "type": "String",
        "value": "richeney"
      },
      "dnsLabelPrefix": {
        "type": "String",
        "value": "richeneyvm"
      },
      "ubuntuOSVersion": {
        "type": "String",
        "value": "16.04.0-LTS"
      }
    },
    :
    :
    :
    "provisioningState": "Succeeded",
    "template": null,
    "templateLink": null,
    "timestamp": "2017-12-08T08:33:20.465371+00:00"
  },
  "resourceGroup": "lab2"
}
```

#### Reading multiple outputs

As we saw in the first lab, you could pull out a single output variable, such as the sshCommand, using a simple JMESPATH query:
```bash
sshCommand=$(az group deployment create --name $job --parameters "@$parms" --template-file $template --resource-group $rg --query properties.outputs.sshCommand.value --output tsv)
echo $sshCommand
```  

But we have two variables that we want, which is more of a challenge.  We can change the JMESPATH to output an array with both variables in order, and use the output as an input string to the 'read' inbuilt command:
```bash
query='[properties.outputs.hostname.value, properties.outputs.sshCommand.value]'
read hostName sshCommand <<< $(az group deployment create --name $job --parameters "@$parms" --template-file $template --resource-group $rg --query $query --output tsv)
echo "hostName is $hostName"
echo "sshCommand is $sshCommand"
```  

This works, but is a little risky when values can include spaces, as indeed the sshCommand does.

Another approach is to output JSON and read that into a variable as multi-line text.  And then we can use jq to run JMESPATH queries against that.  You can install jq on  Ubuntu by typing `sudo get-apt update && sudo apt-get install jq`.  Once that is there then we can do this instead:

```bash
outputs=$(az group deployment create --name $job --parameters "@$parms" --template-file $template --resource-group $rg --query properties.outputs --output tsv)
hostName=$(jq -r .hostname.value <<< $outputs)
sshCommand=$(jq -r .sshCommand.value <<< $outputs)
```

The first line used a JMESPATH query to filter down to the output section of the JSON, which then shortens the jq commands that follow. 

However Python and PowerShell are frankly better for natively handling JSON. 

Let's look at setting a variable in PowerShell to the full output of the command and then pulling out the required variables in the following commands. 

```powershell
$outputs = (New-AzureRmResourceGroupDeployment -Name $job -TemplateParameterFile $parms -TemplateFile $template -ResourceGroupName $rg).Outputs
$hostName = $Outputs.hostname.Value
$sshCommand = $Outputs.sshCommand.Value
```

## Finishing up


If you have been testing out your templates by deploying them then feel free to delete those test resource group(s) as you did in the last lab.

## What's up next

In the next section we will start to use some of the more complex functions that you can make use of in ARM templates.