---
layout: article
title: 'ARM Lab 4: Conditions and tests'
date: 2018-01-08
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template, conditions]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab3-referencesAndSecrets
  title: Referencing information and handling secrets
next:
  url: ../arm-lab5-usingCopy
  title: Using copy to create multiple resources
---

{% include toc.html %}


## Introduction

Conditions are a fairly recent addition, and have massively simplified some of the more complicated template work where we used to make use of nested templates.  

However, there are also some limitations, so this warts and all section will go through a good example and it will show you the good and the bad.

## Using conditions

Before we configure the condition we will first spend a little time cleaning up a few more things in our template to make it more useful.  Once that is done and tested then we'll add in a condition to make the public IP (PIP) and associated DNS name optional.

This will be a little painful, but once it is done then the template will be far more useful as a building block.

If you look at the resources that have been spun up in resource group lab3 from our lab3 template then you'll notice a few things:

![lab3 resources](/workshops/arm/images/lab3Resources.png)

* The vNet (and subnet) are fixed variables for both the name and the address space, so additional VMs deployed to this resource group using this template would share the same networking.  This is fine, but let's make them parameters with defaults so that they can be overriden if need be.
* This template creates first level Managed Disks for the OS (30GB) and the data disk (1023GB), with unique names prefixed with the vmName.  
* The PIP and NIC are fixed names and would conflict if a second was added 

### Reconfiguring the networking parameters and variables

Let's start turning this template into a more useful building block.  Copy your lab3 files into a lab4 folder.  Then make the following changes to the template file:

1. Create parameters for the following:
  * virtualNetworkName with no default
  * virtualNetworkPrefix, defaulting to "10.0.0.0/16"
  * subnetName, defaulting to "Subnet"
  * subnetPrefix, defaulting to "10.0.0.0/24"
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
        "value": "lab4UbuntuVm1"
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
      "value": "richeneylab4a"
    }
  }
}
```


### Submitting using both parameter files and inline parameters

Once you have done that then redeploy the template **twice** into a new lab4 resource group.  Look carefully at the commands below.

The first deployment is using purely the parameter file, whereas the second one is using the `--parameters` switch twice, first to pull in the parameters file, and then with some inline name=value pairs to override those in the parameters file.  This will come in very handy later.

```bash
rg=lab4

dir=$(pwd)
template=$dir/azuredeploy.json
parms=$dir/azuredeploy.parameters.json

az group create --name $rg --location westeurope

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --template-file $template --resource-group $rg --name $job --no-wait

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab4UbuntuVm2 dnsLabelPrefix=richeneylab4b --template-file $template --resource-group $rg --name $job --no-wait
```

The deployment lines also have the `--no-wait` switch at the end so that the deployments go in faster.

Whilst they are deploying, take a look at the documentation for the burstable B-series VMs if you are not familiar with them. 

### Adding a condition

OK, so our deployment is working nicely and the naming is coming through nicely when we have multiple VMs in the resource group:

![Multiple VMs](/workshops/arm/images/lab4MultipleVms.png)

We could rename the storage account used solely for the boot diagnostics, but that is OK.  Note how the unique name for that is seeded by the resource group ID, so both VM deployments got the same "unique name" and are leveraging the same storage account.

Instead, let's change the template so that that the PIP (and associated DNS label) are not created if the dnsLabelPrefix parameter is empty.  This will make our Ubuntu virtual machine building block template useful in a far wider number of scenarios.  

OK, make the dnsLabelPrefix parameter empty in the parameter file.  And remove the vmName as we'll specify that as an inline parameter from now on:

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

Let's introduce the condition statement now.  It is good practice to put it right at the top of the resource block for readability.  When you include it, the resource will only be created if the condition test returns true.  If you remember the various [functions](https://aka.ms/armfunctions) we looked at in the earlier lab then a lot more of these become useful to us now. 

In terms of additional reading there is a great [Azure blog post](https://azure.microsoft.com/en-gb/blog/create-flexible-arm-templates-using-conditions-and-logical-functions/) that is worth looking at as it gives some real examples on how these can be used.  Also Sam Cogan (who wrote our snippets) has a nice [blog post](https://samcogan.com/conditions-in-arm-templates-the-right-way/) on this subject as well, linking to the presentation from [//Build](https://channel9.msdn.com/Events/Build/2017/B8107) back in May 2017.

OK, let's do this in sections and take it step by step.  There is a lot to get right with conditions and plenty that can go wrong, so move slowly and make sure you take in any implications as you go through.  

First of all, let's make a new variable based on whether the dnsLabelPrefix is set:

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
      "condition": "[equals(variables('nicType'), 'public')]",
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
      "condition": "[equals(variables('nicType'), 'private')]",
      "apiVersion": "2017-04-01",
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

At this point I want you to save the templates and then deploy with an inline override of `--parameters vmName-lab4UbuntuVm3` to highlight something about how the templates get verified as part of the deployment.  

If you do this then you should see this error message: 

```bash
myTemplates$ az group deployment create --name $job --parameters "@$parms" --parameters vmName=lab3bUbuntuVm3 --template-file $template --resource-group $rg
Deployment template validation failed: 'The resource 'Microsoft.Network/networkInterfaces/lab3bUbuntuVm3-nic' at line '1' and column '2996' is defined multiple times in a template. Please see https://aka.ms/arm-template/#resources for usage details.'.
```

Even though certain resources won't be created as part of the deployment, they are still included in the validation.  The NIC name property is mentioned twice with the same value. There isn't enough intelligence in the validation to take the inputs and see that the sections that meet the conditions will be valid upon execution. This is a real pain, but we can work around it, and hopefully the product team will change this in the future.

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

### Final lab4 template and parameter files

That was a bit of a marathon.  Hopefully your files look something similar to these files:

###### Lab 4 Files:
<div class="success">
    <b>
        <li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab4/azuredeploy.json" target="_blank">azuredeploy.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab4/azuredeploy.parameters.json" target="_blank">azuredeploy.parameters.json</a>
        </li>
    </b>
</div>

### What's next

In the next section we will look at using the copy property to create multiple of a resource, or of a property (such as managed disks) within a resource.