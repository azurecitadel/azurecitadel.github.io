---
layout: article
title: 'ARM Lab 3: More complex functions'
date: 2017-11-17
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab2-sourceOfResources
  title: Other places to find ARM resources
next:
  url: http://aka.ms/armtemplates
  title: Placeholder - links to GitHub templates  
---

{% include toc.html %}


## Introduction

You should now be fairly comfortable working with JSON templates and parameter files, leveraging the various sources of ARM template, and refactoring variables and parameters and resources to customise the files for your requirements.

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

We will be looking at the more complex areas and use cases for those, such as referencing information in the current deployment and of existing resources; handling secrets with securetext; using loops; using conditionals; and nesting templates.

## Getting information

We have already done some of this when working through the previous labs.  Your resource sections already have _parameter_ and _variable_ functions to pull out information from other parts of the template at runtime.  You can also use the _deployment_ function to get information about the current and parent template, which is useful when dealing with nested deployments.

We have also used the _resourceGroup()_ function.  When not specifying a specific group as the argument then it will default to the group we are deploying to, and we can pull out the name, location, tags, etc.  Setting or defaulting a resource's location to `"[resourceGroup().location]"` might just be the look up function you use most regularly.     

We also pulled out the _subscription().subscriptionID_, but you can also get the _subscription().tenantID_ as well.

Many of the resource operations require a resource's unique ID.  This is frequently used with nested resources (or sub-resources), or when deriving the resourceId for an existing resource.

Remember in the theory section that a resourceId is in the following format:
`/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceProviderNamespace}/{resourceType}/{resourceName}`

When you call resourceId(), you can specify just the resourceType and resourceName and it will default to the current subscription and resourceGroup.  Or you can find the resourceId for resources in different resource groups, or other subscriptions within the same tenancy.  Look at the following code block for some networking variables in a template:

```json
"variables": {
    "vnetID": "[resourceId(parameters('virtualNetworkResourceGroup'), 'Microsoft.Network/virtualNetworks', parameters('virtualNetworkName'))]",
    "subnet1Ref": "[concat(variables('vnetID'),'/subnets/', parameters('subnet1Name'))]"
},
```

Note that the subnet is a child resource for the virtual network, which is why the concenation makes sense.  You can use [Resource Explorer](https://resources.azure.com/) to browse the resources within your subscription you can see the resourceIds for your existing resources.  

You will often see the resourceId used in the variables section to simplfy the resources section as much as possible.

You can also listKeys or list{Value} from those same resourceIds.  This is very useful in the outputs sections.  Check the Azure documentation for [listKeys and list{Value}](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-resource#listkeys-and-listvalue) as there are a couple of Bash and PowerShell commands to find out what list actions are supported by each resource type.  Try out the example for the storage account resource type.  You will see listkeys, listAccountSas and listServiceSas.  Taking the listkeys as an example, this then ties in with the [REST API reference](https://docs.microsoft.com/en-gb/rest/api/storagerp/storageaccounts/listkeys) material.

We have no specific lab section for this, but you will see the resource functions littered throughout the templates.

## Handling securetext passwords with Key Vault

OK, time to get a little self-reliant! You should now be comfortable with accessing the various resources and documentation area and capable of being more self sufficient, so I will stop detailing all of the steps.  This one wil lbe for you to find your own way rather than be guided.  

I'll help you create a key vault with a new secret called ubuntuDefaultPassword.  After that you will create your own template and parameter files in a **lab3a** sub-directory, configuring an Ubuntu VM template that will use the secret in place of a cleartext one in the parameters file.

It is probably worth stating the problem we are solving before you get started.  

All of the templates that include a password field, or any other property that contains sensitive data, should have a type of securetext rather than string.  The key thing that this does is to make sure that someone going through the deployment logs in the portal is not able to view the password.  So that part is not a concern as long as we use securetext as the type.

If we are using a script to prompt a user to enter a password as part of the deployment then again, that would be transient and there should be nothing to see if it is prompted for interactively in the right way, such as with `read -s -p "Enter password: " password` to ensure that the `-s` switch prevents characters being echoed to the terminal.

So the real issue is avoiding scripts and parameter files from containing cleartext password if the location and access permissions would allow them to be viewed.  This is where specifying key vault secrets makes perfect sense.

### Creating a Key Vault

OK, let's begin by creating a lab3a folder and an empty azuredeploy.json and azuredeploy.parameters.json file.  

We'll also need a key vault if you haven't got one.  I have shown below how to make one manually to save time. Or you can use a couple of CLI or PowerShell commands.  Try searching for the Azure documentation page that can help with that.  Or if you wish you can take a look at the [201-key-vault-secret-create](https://github.com/Azure/azure-quickstart-templates/tree/master/201-key-vault-secret-create) quickstart template and use that to automate the creation if you know that this is something you wil lbe doing repeatedly. 

Here are the manual instructions:

In the Azure [portal](https://portal.azure.com):
* Add a new resource, Key Vault
* Give it a unique name
* Create a new resource group: **keyVaults**
* Create it in your preferred location 
* Stick with the _Standard_ pricing tier and the default access policy and principal
* Create

It should only take a few seconds to create. Once deployed:
* Go into the _Access policies_ area in the Setting area
  * Open up the advanced access policies
  * Enable access to Azure Resource Manager for template deployment
* Select _Secrets_ in the Settings blade area
  * Add a secret
  * Manual upload
  * Name: **windowsDefaultPassword**
  * Value: Enter in a suitable password for the Windows VM we'll create 
  * You don't need to set an activation or expiry date
  * Create

As you have access (as the principal under the access policy), you will be able to go back into the portal to view or change the secret in the future.  Or you can check the various CLI and PowerShell commands on the Azure Docs.  For instance, I could retrieve the password using: 
`az keyvault secret show --name ubuntuDefaultPassword --vault-name richeneyKeyVault --query value --output tsv`

### Create the template

Time to roll up the sleeves.  I'll give you a few pointers and then a few requirement and leave you to your own devices for a while.  Use the Ubuntu VM template and parameters file from the previous lab2c that we downloaded from Azure quickstart templates as the base, copying the files into a new lab3a area.  

Pointers:
* With the current (Dec 2017) functionality and schema format you cannot use dynamic key vault names unless you use nested templates
* Search for the information online on how to configure static keyVault names when passing in secrets
* Use commands or the resource explorer to find the id for your key vault
* Your configuration in this labe for keyvaults and secrets should only affect the parameters file, not the main   

Requirements:
1.  Make sure the adminPassword is set with a reference to the secret from the keyVault rather than a cleartext value 
1.  Move the vmName variable up into the parameters section and default it to the current value
1.  Update the list of allowed Ubuntu versions in your main template to the current 14.x and 16.x LTS versions available on the platform and the default to the 16.x version.  (And feel free to add a few newer ones.)

Once you have completed your files and have successfully submitted then please see how yours compare to the ones below.

If you have time then work out the commands in either PowerShell or Bash to see the available Ubuntu virtual machine images from Canonical. (Hint: the publisher is Canonical.)

We will return to key vaults and secrets when we look at the nesting.

### Deploy into lab3a

OK, if you haven't done so already then create a lab3a resource group and deploy the new template into that in order to test it. 

### Final lab3a template and parameter files

OK, here are the two files:

#### azuredeploy.json

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminUsername": {
      "type": "string",
      "metadata": {
        "description": "User name for the Virtual Machine."
      }
    },
    "adminPassword": {
      "type": "securestring",
      "metadata": {
        "description": "Password for the Virtual Machine."
      }
    },
    "vmName": {
       "type": "string",
       "metadata": {
            "description": "Name for the virtual machine"
        }, 
        "defaultValue": "myUbuntuVm"
    },
    "dnsLabelPrefix": {
      "type": "string",
      "metadata": {
        "description": "Unique DNS Name for the Public IP used to access the Virtual Machine."
      }
    },
    "ubuntuOSVersion": {
      "type": "string",
      "defaultValue": "16.04-LTS",
      "allowedValues": [
        "14.04-LTS",
        "16.04-LTS",
        "17.04",
        "17.10"
      ],
      "metadata": {
        "description": "The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version."
      }
    }
  },
  "variables": {
    "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'salinuxvm')]",
    "imagePublisher": "Canonical",
    "imageOffer": "UbuntuServer",
    "nicName": "myVMNic",
    "addressPrefix": "10.0.0.0/16",
    "subnetName": "Subnet",
    "subnetPrefix": "10.0.0.0/24",
    "storageAccountType": "Standard_LRS",
    "publicIPAddressName": "myPublicIP",
    "publicIPAddressType": "Dynamic",
    "vmSize": "Standard_A1",
    "virtualNetworkName": "MyVNET",
    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks/', variables('virtualNetworkName'))]",
    "subnetRef": "[concat(variables('vnetID'),'/subnets/',variables('subnetName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('storageAccountName')]",
      "apiVersion": "2017-06-01",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "[variables('storageAccountType')]"
      },
      "kind": "Storage",
      "properties": {}
    },
    {
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/publicIPAddresses",
      "name": "[variables('publicIPAddressName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[parameters('dnsLabelPrefix')]"
        }
      }
    },
    {
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/virtualNetworks",
      "name": "[variables('virtualNetworkName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[variables('addressPrefix')]"
          ]
        },
        "subnets": [
          {
            "name": "[variables('subnetName')]",
            "properties": {
              "addressPrefix": "[variables('subnetPrefix')]"
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('nicName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/publicIPAddresses/', variables('publicIPAddressName'))]",
        "[variables('vnetID')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))]"
              },
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2017-03-30",
      "type": "Microsoft.Compute/virtualMachines",
      "name": "[parameters('vmName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Storage/storageAccounts/', variables('storageAccountName'))]",
        "[resourceId('Microsoft.Network/networkInterfaces/', variables('nicName'))]"
      ],
      "properties": {
        "hardwareProfile": {
          "vmSize": "[variables('vmSize')]"
        },
        "osProfile": {
          "computerName": "[parameters('vmName')]",
          "adminUsername": "[parameters('adminUsername')]",
          "adminPassword": "[parameters('adminPassword')]"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[variables('imagePublisher')]",
            "offer": "[variables('imageOffer')]",
            "sku": "[parameters('ubuntuOSVersion')]",
            "version": "latest"
          },
          "osDisk": {
            "createOption": "FromImage"
          },
          "dataDisks": [
            {
              "diskSizeGB": 1023,
              "lun": 0,
              "createOption": "Empty"
            }
          ]
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces',variables('nicName'))]"
            }
          ]
        },
        "diagnosticsProfile": {
          "bootDiagnostics": {
            "enabled": true,
            "storageUri": "[concat(reference(concat('Microsoft.Storage/storageAccounts/', variables('storageAccountName')), '2016-01-01').primaryEndpoints.blob)]"
          }
        }
      }
    }
  ],
  "outputs": {
    "hostname": {
      "type": "string",
      "value": "[reference(variables('publicIPAddressName')).dnsSettings.fqdn]"
    },
    "sshCommand": {
      "type": "string",
      "value": "[concat('ssh ', parameters('adminUsername'), '@', reference(variables('publicIPAddressName')).dnsSettings.fqdn)]"
    }
  }
}
```

#### azuredeploy.templates.json

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
        "value": "lab3aUbuntuVm"
    },
    "adminUsername": {
      "value": "richeney"
    },
    "adminPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/keyVaults/providers/Microsoft.KeyVault/vaults/richeneyKeyVault"
        },
        "secretName": "ubuntuDefaultPassword"
      }
    },
    "dnsLabelPrefix": {
      "value": "richeneylab3a"
    }
  }
}

```

If yours aren't quite right then use the compare tool from the Command Palette.  


----------

## Using conditions

Conditions are a fairly recent addition, and have massively simplified some of the more complicated template work where we used to make use of nested templates.  However, there are also some limitation, so this warts and all section will goi through a good example and it will show you the good and the bad.

Before we configure the condition we will first spend a little time cleaning up a few more things in our template to make it more useful.  Once that is done and tested then we'll add in a condition to make the public IP (PIP) and associated DNS name optional.

This will be a little painful, but once it is done then the template will be far more useful as a building block.

If you look at the resources that have been spun up in resource group lab3 from our lab3a template then you'll notice a few things:

![lab3A resources](/workshops/arm/images/lab3aResources.png)

* The vNet (and subnet) are fixed variables for both the name and the address space, so additional VMs deoployed to this resource group using this template would share the same networking.  This is fine, but let's make them parameters with defauilts so that they can be overriden if need be
* This template creates first level Managed Disks for the OS (30GB) and the data disk (1023GB), with unique names prefixed with the vmName.  
* The PIP and NIC are fixed names and would conflict if a second was added 

### Reconfiguring the networking parameters and variables

Let's start turning this template into a more useful building block.  Copy your lab3a files into a lab3b folder.  Then make the following changes to the template file:

1. Create parameters for the following:
  * virtualNetworkName with no default
  * virtualNetworkPrefix, defaulting to "10.0.0.0/16"
  * subnetName, defaulting to "Subnet"
  * subnetPrefix, defaulting to "10.0.0.0/24"
    * if you want to try out a few new functions then set  
1. Remove the corresponding variables
1. Remove the default for the vmName
1. Change the value for the publicIPAddressName variable to be the vmName with '-pip' at the end
1. Change the value for the nicName variable to be the vmName with '-nic' at the end
1. Change the value for the vmSize variable to "Standard_B1s"

In the parameters file, add in new virtualNetworkName and subnetName and set the vmName and dnsLabelPrefix to be unique. Here is an example:

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
        "value": "lab3bUbuntuVm1"
    },
    "adminUsername": {
      "value": "richeney"
    },
    "adminPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/keyVaults/providers/Microsoft.KeyVault/vaults/richeneyKeyVault"
        },
        "secretName": "ubuntuDefaultPassword"
      }
    },
    "virtualNetworkName": {
        "value": "ubuntuVnet"
    },
    "subnetName": {
        "value": "ubuntuSubnet"
    },
    "dnsLabelPrefix": {
      "value": "richeneylab3b1"
    }
  }
}
```


### Submitting using both parameter files and inline parameters

Once you have done that then redeploy the template **twice** into a new lab3b.  Look carefully at the commands below.  

The first deployment is using purely the parameter file, whereas the second one is using the `--parameters` switch twice, first to pull in the parameters file, and then with some inline name=value pairs to override those in the parameters file.  This will come in very handy later.

```bash
rg=lab3b

dir=/mnt/c/myTemplates/$rg
template=$dir/azuredeploy.json
parameters=$dir/azuredeploy.parameters.json

az group create --name $rg --location westeurope

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --template-file $template --resource-group $rg --name $job 

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab3bUbuntuVm2 dnsLabelPrefix=richeneylab3b2 --template-file $template --resource-group $rg --name $job
```

Whilst they are deploying, take a look at the documentation for the burstable B-series VMs if you are not familiar with them. 

### Adding a condition

OK, so our deployment is working nicely and the naming is coming through nicely when we have multiple VMs in the resource group:

![Multiple VMs](/workshops/arm/images/lab3bMultipleVms.png)

We could rename the storage account used solely for the boot diagnostics, but that is OK.  Note how the unique name for that is seeded by the resource group ID, so both VM deployments got the same "unique name" and are leveraging the same storage account.

Instead, let's change the template so that that the PIP (and associated DNS label) are not created if the dnsLabelPrefix parameter is empty.  This will make our Ubuntu virtual machine building block template useful in a far wider number of scenarios.  

OK, make the dnsLabelPrefix parameter empty in the parameter file.  And remove the vmName as we'll specufy that as an inline from now on:

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminUsername": {
      "value": "richeney"
    },
    "adminPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/keyVaults/providers/Microsoft.KeyVault/vaults/richeneyKeyVault"
        },
        "secretName": "ubuntuDefaultPassword"
      }
    },
    "virtualNetworkName": {
        "value": "ubuntuVnet"
    },
    "subnetName": {
        "value": "ubuntuSubnet"
    },
    "dnsLabelPrefix": {
      "value": ""
    }
  }
}

```

Save that.  If you were to submit now, your deployment should fail.

OK, let's tweak the public IP resource so that it only gets created if the dnsLabelPrefix parameter is defined.   

Let's introduce the condition statement now.  It is good practice to put it  right at the top of the resource block for readability.  When you include it then  the resource will only be created of the condition test returns true.  If you remember the various [functions](https://aka.ms/armfunctions) we looked at right at the start of this labe then  a lot more of these become useful to us now. 

In terms of additional reading there is a great [Azure blog post](https://azure.microsoft.com/en-gb/blog/create-flexible-arm-templates-using-conditions-and-logical-functions/) that is worth looking at as it gives some real examples on how these can be used.  Also Sam Cogan (who wrote our snippets) has a nice [blog post](https://samcogan.com/conditions-in-arm-templates-the-right-way/) on this subject as well, linking to the presentation from [//Build](https://channel9.msdn.com/Events/Build/2017/B8107) back in May 2017.

OK, let's do this in sections and take it step by step.  There is a lot to get right with conditions and plenty that can go wrong, so move slowly and make sure you take in any implications as you go through.  

First oif all, let's make a new variable based on whether the dnsLabelPrefix is set:

```json
  "variables": {
    "nicType": "[if(greater(length(parameters('dnsLabelPrefix')), 0), 'public', 'private')]",

```

We'll be making plenty of use of that nicType variable.

We'll do the simplest resource first - add a condition to the public IP resource so that it only gets created if the nicType is public:

```json
    {
      "condition": "[equals(variables('nicType'), 'public')]",
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/publicIPAddresses",
      "name": "[variables('publicIPAddressName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[parameters('dnsLabelPrefix')]"
        }
      }
    },
```

So far so good.

OK, here is a slightly tricker bit.  The NIC resource needs to be created one way if we have the public IP, and another if we are internal only.  So we duplicate the block, set a condition for both.

```json
    {
      "condition": "[equals(variables('nicType'), 'public')]",      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('nicName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/publicIPAddresses/', variables('publicIPAddressName'))]",
        "[variables('vnetID')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))]"
              },
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
    {
      "condition": "[equals(variables('nicType'), 'private')]",      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('nicName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[variables('vnetID')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
```

OK, that part isn't too bad - if the parameter is defined then we do the first resource, whilst if it is empty then we do the second resource block. 

At this point I want you to save the templates and then deploy with an inline override of `--parameters vmName-lab3UbuntuVm3` to highlight something about how the templates get verified as part of the deployment.  

If you do this then you should see this error message: 

```bash
myTemplates$ az group deployment create --name $job --parameters "@$parms" --parameters vmName=lab3bUbuntuVm3 --template-file $template --resource-group $rg
Deployment template validation failed: 'The resource 'Microsoft.Network/networkInterfaces/lab3bUbuntuVm3-nic' at line '1' and column '2996' is defined multiple times in a template. Please see https://aka.ms/arm-template/#resources for usage details.'.
```

Even though certain resources won't be created as part of the deployment, they are still included in the validation.  The NIC name property is mentioned twice with the same value.  There isn't enough intelligence in the validation to take the inputs and see that the sections that meed to conditions will be valid upon execution.  This is a real pain, but we can work around it, and hopefully the product team will change this in the future.

So we'll replace the nicName variable with two variables, privateNicName and publicNicName.  And we'll move up as many of the resourceID() commands up into those new variables sections.  Here is the full variables section after I've shuffled the variables around into sensible groupings:

```json
  "variables": {
    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks/', parameters('virtualNetworkName'))]",
    "subnetRef": "[concat(variables('vnetID'), '/subnets/', parameters('subnetName'))]",
    "publicIPAddressName": "[concat(parameters('vmName'), '-pip')]",
    "publicIPAddressType": "Dynamic",
    "nicType": "[if(greater(length(parameters('dnsLabelPrefix')), 0), 'public', 'private')]",
    "privateNicName": "[concat(parameters('vmName'), '-nic')]",
    "publicNicName": "[concat(parameters('vmName'), '-nic-public')]",
    "privateNicID": "[resourceId('Microsoft.Network/networkInterfaces/', variables('privateNicName'))]",
    "publicNicID": "[resourceId('Microsoft.Network/networkInterfaces/', variables('publicNicName'))]",
    "nicId": "[if(equals(variables('nicType'), 'private'), variables('privateNicID'), variables('publicNicID'))]",
    "vmSize": "Standard_B1s",
    "imagePublisher": "Canonical",
    "imageOffer": "UbuntuServer",
    "storageAccountType": "Standard_LRS",
    "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'salinuxvm')]",
    "storageAccountID": "[resourceId('Microsoft.Storage/storageAccounts/', variables('storageAccountName'))]"
  },
```

Notice the nicID variable.  I could have embedded the if statement multiple times in the resources section, but this makes it a little easier to read.

You resources section should now use those variables wherever possible. And don't forget to rework the two NIC resources to publicNicName and privateNicName.

You will have noticed that the publicNicName has an additional '-public' on the end.  The validation is clever enough to resolve the names that it can, so will throw up an error if they are both set to '_vmName_-nic'.

The virtual machine resource references the NIC ID twice - once in the dependsOn array, and again in the networkProfile.networkInterfaces area.  These can use the nicID variable, or could have the full if statement instead, e.g.:

```json
"id": "[if(equals(variables('nicType'), 'private'), variables('privateNicID'), variables('publicNicID'))]"
```
or

```json
"id": "[variables('nicID')]
```

Finally, remove the outputs section.  We will come back to that later but for the moment it is another complication as it is currently referencing a resource that we might not be deploying.

### Final lab3a template and parameter files

That was a bit of a marathon.  Hopefully your files look something similar to these files:

#### azuredeploy.json

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminUsername": {
      "type": "string",
      "metadata": {
        "description": "User name for the Virtual Machine."
      }
    },
    "adminPassword": {
      "type": "securestring",
      "metadata": {
        "description": "Password for the Virtual Machine."
      }
    },
    "vmName": {
       "type": "string",
       "metadata": {
            "description": "Name for the virtual machine"
        }, 
        "defaultValue": "myUbuntuVm"
    },
    "dnsLabelPrefix": {
      "type": "string",
      "metadata": {
        "description": "Unique DNS Name for the Public IP used to access the Virtual Machine."
      }
    },
    "ubuntuOSVersion": {
      "type": "string",
      "defaultValue": "16.04-LTS",
      "allowedValues": [
        "14.04-LTS",
        "16.04-LTS",
        "17.04",
        "17.10"
      ],
      "metadata": {
        "description": "The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version."
      }
    },
    "virtualNetworkName": {
       "type": "string",
       "metadata": {
            "description": "Name for the virtual network"
        }
    },
    "virtualNetworkPrefix": {
       "type": "string",
       "defaultValue": "10.0.0.0/16",
       "metadata": {
            "description": "CIDR address space for the virtual network"
        }
    },
    "subnetName": {
       "type": "string",
       "defaultValue": "Subnet",
       "metadata": {
            "description": "Name for the subnet - defaults to Subnet"
        }
    },
    "subnetPrefix": {
       "type": "string",
       "defaultValue": "10.0.0.0/24",
       "metadata": {
            "description": "CIDR address space for the subnet"
        }
    }
  },
  "variables": {
    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks/', parameters('virtualNetworkName'))]",
    "subnetRef": "[concat(variables('vnetID'), '/subnets/', parameters('subnetName'))]",
    "publicIPAddressName": "[concat(parameters('vmName'), '-pip')]",
    "publicIPAddressType": "Dynamic",
    "nicType": "[if(greater(length(parameters('dnsLabelPrefix')), 0), 'public', 'private')]",
    "privateNicName": "[concat(parameters('vmName'), '-nic')]",
    "publicNicName": "[concat(parameters('vmName'), '-nic-public')]",
    "privateNicID": "[resourceId('Microsoft.Network/networkInterfaces/', variables('privateNicName'))]",
    "publicNicID": "[resourceId('Microsoft.Network/networkInterfaces/', variables('publicNicName'))]",
    "nicId": "[if(equals(variables('nicType'), 'private'), variables('privateNicID'), variables('publicNicID'))]",
    "vmSize": "Standard_B1s",
    "imagePublisher": "Canonical",
    "imageOffer": "UbuntuServer",
    "storageAccountType": "Standard_LRS",
    "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'salinuxvm')]",
    "storageAccountID": "[resourceId('Microsoft.Storage/storageAccounts/', variables('storageAccountName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('storageAccountName')]",
      "apiVersion": "2017-06-01",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "[variables('storageAccountType')]"
      },
      "kind": "Storage",
      "properties": {}
    },
    {
      "condition": "[equals(variables('nicType'), 'public')]",
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/publicIPAddresses",
      "name": "[variables('publicIPAddressName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[parameters('dnsLabelPrefix')]"
        }
      }
    },
    {
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/virtualNetworks",
      "name": "[parameters('virtualNetworkName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[parameters('virtualNetworkPrefix')]"
          ]
        },
        "subnets": [
          {
            "name": "[parameters('subnetName')]",
            "properties": {
              "addressPrefix": "[parameters('subnetPrefix')]"
            }
          }
        ]
      }
    },
    {
      "condition": "[equals(variables('nicType'), 'public')]",
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('publicNicName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/publicIPAddresses/', variables('publicIPAddressName'))]",
        "[variables('vnetID')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "publicIPAddress": {
                "id": "[[resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))]"
              },
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
    {
      "condition": "[equals(variables('nicType'), 'private')]",
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('privateNicName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[variables('vnetID')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2017-03-30",
      "type": "Microsoft.Compute/virtualMachines",
      "name": "[parameters('vmName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[variables('storageAccountID')]",
        "[variables('nicId')]"
      ],
      "properties": {
        "hardwareProfile": {
          "vmSize": "[variables('vmSize')]"
        },
        "osProfile": {
          "computerName": "[parameters('vmName')]",
          "adminUsername": "[parameters('adminUsername')]",
          "adminPassword": "[parameters('adminPassword')]"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[variables('imagePublisher')]",
            "offer": "[variables('imageOffer')]",
            "sku": "[parameters('ubuntuOSVersion')]",
            "version": "latest"
          },
          "osDisk": {
            "createOption": "FromImage"
          },
          "dataDisks": [
            {
              "diskSizeGB": 1023,
              "lun": 0,
              "createOption": "Empty"
            }
          ]
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[variables('nicId')]"
            }
          ]
        },
        "diagnosticsProfile": {
          "bootDiagnostics": {
            "enabled": true,
            "storageUri": "[concat(reference(concat('Microsoft.Storage/storageAccounts/', variables('storageAccountName')), '2016-01-01').primaryEndpoints.blob)]"
          }
        }
      }
    }
  ],
  "outputs": {
  }
}
```

#### azuredeploy.parameters.json

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
        "value": ""
    },
    "adminUsername": {
      "value": "richeney"
    },
    "adminPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/keyVaults/providers/Microsoft.KeyVault/vaults/richeneyKeyVault"
        },
        "secretName": "ubuntuDefaultPassword"
      }
    },
    "virtualNetworkName": {
        "value": "ubuntuVnet"
    },
    "subnetName": {
        "value": "ubuntuSubnet"
    },
    "dnsLabelPrefix": {
      "value": ""
    }
  }
}
```

----------

## Copy

There are times when you will want to create multiple copies of an object.  The way that this is done with ARM templates is through the use of copy elements.

These create a small loop and then iterate through then to make an array at deployment.  In this lab section we'll allow the user to specify more than one data disk if required.

You can only uses copies within the resources section, but they can be used at both the resource level and at the property level.  

### Resource copy

At the property level it looks a little like the following JSON block:

```json
"resources": [
  {
    "type": "Microsoft.Provider/type",
    "apiVersion": "2017-12-12",
    "name": "[concat('myResourcePrefix-', copyIndex(1)]",
    "location": "[resourceGroup().location]",
    "properties": {},
    "copy": {
      "name": "resourcecopy",
      "count": 4
    }
  }
]
```

Note that the copy element at this level is an object. 

This will create four copies.  Note that the name uses copyIndex, which loops through the copy array.  By default the index starts at 0, but using copyIndex(1) offsets that so our resources will be names myResourcePrefix-1 up to myResourcePrefix-4.  These are fairly simple.

### Resource copy using an array

There is another type that can use an array, usually passed in as a parameter or value array.  Let's use the example of creating web apps in multiple regions, making use of a parameter like this:

```json
"parameters": { 
  "location": { 
     "type": "array", 
     "defaultValue": [ 
         "westeurope", 
         "eastus2", 
         "westus2" 
      ] 
  }
}, 
"resources": [ 
  { 
      "name": "[concat('webapp-', parameters('location')[copyIndex()])]", 
      "location": "[parameters('location')[copyIndex()]]",
      "copy": { 
         "name": "locationcopy", 
         "count": "[length(parameters('location'))]" 
      }, 
      ...
  } 
]
```

This is really nice as the count in the copy object is based on the length of the array.  And the copyIndex is used purely to pull out the correct array element.

### Creating multiple disks

Let's do it at the property level against the maneged disks used for data.  These use a slightly different structure, creating small arrays of objects on the fly.  They can only be used in places where property arrays are already used, e.g. data disks, NICs, etc.  (Look for the square brackets!)

Create a lab3c and copy in the files from the lab3b. Create a new parameter in the azuredeploy.json file for numberOfDataDisks, defaulting to 1.  We'll set inline at submission.  (Hint: should it be a string type?)

Find the managed data disk area, which should be in the virtual machine as properties.storageProfile.dataDisks, and is, of course, an array:

```json
          "dataDisks": [
            {
              "diskSizeGB": 1023,
              "lun": 0,
              "createOption": "Empty"
            }
          ]
```

We'll replace this whole section with a copy property.  The copy element at the property level is an array, not an object, and it contains a single property containing:
* **name**: which has to match the name of the property it is replacing, in this case 'dataDisks'
* **count**: the number of values to create in the array
* **input**: which defines the object that will be injected

Change the dataDisks section to look like the following:

```json
          "copy": [{
            "name": "dataDisks",
            "count": "[parameters('numberofDataDisks')]",
            "input": {
              "diskSizeGB": 1023,
              "lun": "[copyIndex('dataDisks')]",
              "createOption": "Empty"
            }
          }]
```

Note that the input section is a dead ringer for the previous object, just replacing the lun number with the one that is generated.

At deployment this will be expanded by resource manager so, if we were to submit with numberOfDataDisks=4, that it wil actually be submitted looking like this:

```json
        "storageProfile": {
          "dataDisks": [
            {
              "diskSizeGB": 1023,
              "lun": 0,
              "createOption": "Empty"
            },
            {
              "diskSizeGB": 1023,
              "lun": 1,
              "createOption": "Empty"
            }.
            {
              "diskSizeGB": 1023,
              "lun": 2,
              "createOption": "Empty"
            },
            {
              "diskSizeGB": 1023,
              "lun": 3,
              "createOption": "Empty"
            }
          ],
          ...
        }
```

Note that we won't be able to do four data disks against our tiddly Standard_ B1s as the maximum number of data disks that will take is 2. Don't forget to save.

### Deploy the new VM

Submit the VM, specifying the name and number of disks:

```bash
rg=lab3c

dir=/mnt/c/myTemplates/$rg
template=$dir/azuredeploy.json
parameters=$dir/azuredeploy.parameters.json

az group create --name $rg --location westeurope

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab3cUbuntuVm1 numberOfDataDisks=2 --template-file $template --resource-group $rg --name $job
```

### Final lab3c template and parameters files

Here are the final set of files:

#### azuredeploy.json

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminUsername": {
      "type": "string",
      "metadata": {
        "description": "User name for the Virtual Machine."
      }
    },
    "adminPassword": {
      "type": "securestring",
      "metadata": {
        "description": "Password for the Virtual Machine."
      }
    },
    "vmName": {
       "type": "string",
       "metadata": {
            "description": "Name for the virtual machine"
        }, 
        "defaultValue": "myUbuntuVm"
    },
    "dnsLabelPrefix": {
      "type": "string",
      "metadata": {
        "description": "Unique DNS Name for the Public IP used to access the Virtual Machine."
      }
    },
    "ubuntuOSVersion": {
      "type": "string",
      "defaultValue": "16.04-LTS",
      "allowedValues": [
        "14.04-LTS",
        "16.04-LTS",
        "17.04",
        "17.10"
      ],
      "metadata": {
        "description": "The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version."
      }
    },
    "numberOfDataDisks": {
       "type": "int",
       "defaultValue": "1",
       "metadata": {
            "description": "Number of data disks (managed) to attach to the virtual machine."
        }
    },
    "virtualNetworkName": {
       "type": "string",
       "metadata": {
            "description": "Name for the virtual network"
        }
    },
    "virtualNetworkPrefix": {
       "type": "string",
       "defaultValue": "10.0.0.0/16",
       "metadata": {
            "description": "CIDR address space for the virtual network"
        }
    },
    "subnetName": {
       "type": "string",
       "defaultValue": "Subnet",
       "metadata": {
            "description": "Name for the subnet - defaults to Subnet"
        }
    },
    "subnetPrefix": {
       "type": "string",
       "defaultValue": "10.0.0.0/24",
       "metadata": {
            "description": "CIDR address space for the subnet"
        }
    }
  },
  "variables": {
    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks/', parameters('virtualNetworkName'))]",
    "subnetRef": "[concat(variables('vnetID'), '/subnets/', parameters('subnetName'))]",
    "publicIPAddressName": "[concat(parameters('vmName'), '-pip')]",
    "publicIPAddressType": "Dynamic",
    "nicType": "[if(greater(length(parameters('dnsLabelPrefix')), 0), 'public', 'private')]",
    "privateNicName": "[concat(parameters('vmName'), '-nic')]",
    "publicNicName": "[concat(parameters('vmName'), '-nic-public')]",
    "privateNicID": "[resourceId('Microsoft.Network/networkInterfaces/', variables('privateNicName'))]",
    "publicNicID": "[resourceId('Microsoft.Network/networkInterfaces/', variables('publicNicName'))]",
    "nicId": "[if(equals(variables('nicType'), 'private'), variables('privateNicID'), variables('publicNicID'))]",
    "vmSize": "Standard_B1s",
    "imagePublisher": "Canonical",
    "imageOffer": "UbuntuServer",
    "storageAccountType": "Standard_LRS",
    "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'salinuxvm')]",
    "storageAccountID": "[resourceId('Microsoft.Storage/storageAccounts/', variables('storageAccountName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('storageAccountName')]",
      "apiVersion": "2017-06-01",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "[variables('storageAccountType')]"
      },
      "kind": "Storage",
      "properties": {}
    },
    {
      "condition": "[equals(variables('nicType'), 'public')]",
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/publicIPAddresses",
      "name": "[variables('publicIPAddressName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[parameters('dnsLabelPrefix')]"
        }
      }
    },
    {
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/virtualNetworks",
      "name": "[parameters('virtualNetworkName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[parameters('virtualNetworkPrefix')]"
          ]
        },
        "subnets": [
          {
            "name": "[parameters('subnetName')]",
            "properties": {
              "addressPrefix": "[parameters('subnetPrefix')]"
            }
          }
        ]
      }
    },
    {
      "condition": "[equals(variables('nicType'), 'public')]",
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('publicNicName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/publicIPAddresses/', variables('publicIPAddressName'))]",
        "[variables('vnetID')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "publicIPAddress": {
                "id": "[[resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))]"
              },
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
    {
      "condition": "[equals(variables('nicType'), 'private')]",
      "apiVersion": "2017-04-01",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('privateNicName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[variables('vnetID')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2017-03-30",
      "type": "Microsoft.Compute/virtualMachines",
      "name": "[parameters('vmName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[variables('storageAccountID')]",
        "[variables('nicId')]"
      ],
      "properties": {
        "hardwareProfile": {
          "vmSize": "[variables('vmSize')]"
        },
        "osProfile": {
          "computerName": "[parameters('vmName')]",
          "adminUsername": "[parameters('adminUsername')]",
          "adminPassword": "[parameters('adminPassword')]"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[variables('imagePublisher')]",
            "offer": "[variables('imageOffer')]",
            "sku": "[parameters('ubuntuOSVersion')]",
            "version": "latest"
          },
          "osDisk": {
            "createOption": "FromImage"
          },
          "copy": [{
            "name": "dataDisks",
            "count": "[parameters('numberofDataDisks')]",
            "input": {
              "diskSizeGB": 1023,
              "lun": "[copyIndex('dataDisks')]",
              "createOption": "Empty"
            }
          }]
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[variables('nicId')]"
            }
          ]
        },
        "diagnosticsProfile": {
          "bootDiagnostics": {
            "enabled": true,
            "storageUri": "[concat(reference(concat('Microsoft.Storage/storageAccounts/', variables('storageAccountName')), '2016-01-01').primaryEndpoints.blob)]"
          }
        }
      }
    }
  ],
  "outputs": {
  }
}
```

#### azuredeploy.parameters.json

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
        "value": ""
    },
    "adminUsername": {
      "value": "richeney"
    },
    "adminPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/keyVaults/providers/Microsoft.KeyVault/vaults/richeneyKeyVault"
        },
        "secretName": "ubuntuDefaultPassword"
      }
    },
    "virtualNetworkName": {
        "value": "ubuntuVnet"
    },
    "subnetName": {
        "value": "ubuntuSubnet"
    },
    "dnsLabelPrefix": {
      "value": ""
    }
  }
}
```

### Finishing up

OK, our virtual machine building block is looking a lot more flexible and capable now.  And this is the key, to get to the appropriate level of complexity, flexibility and capability to make the building block as useful as possible.  

The scenario you are looking to avoid is having lots of similar but slightly different templates that you use for different purposes. What you will find over time is that you will need to tweak, change and update your templates as the Azure platform moves forward and the business requirements change.  Having flexible templates simplifies that ongoing work.

Clear up your resource groups and start to define your own building block templates for the resource you most commonly deploy.

### What's next

In the next section we will concentrate on how to orchestrate and store the building blocks templates.  We'll look at nested templates and using blob storage with SAS tokens, before finishing off with a discussion of CI/CD pipelines and alternative higher level orchestration options such as Terraform, Chef, Puppet, Ansible, Salt and also the Azure Building Blocks (azbb).