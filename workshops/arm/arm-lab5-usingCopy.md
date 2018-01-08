---
layout: article
title: 'ARM Lab 5: Create multiple resources using copy'
date: 2018-01-08
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template, copy]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab4-conditionalResources
  title: Using conditions
next:
  url: ../arm-lab6-objectsAndArrays
  title: Using objects and arrays
---

{% include toc.html %}


## Introduction

There are times when you will want to create multiple copies of a resource such as multiple virtual machines within an availability set.  

You may also need to create multiple copies of an object or property within a resource, such as subnets within a virtual network, or data disks within a virtual machine.  

The way that this is done with ARM templates is through the use of copy elements.


## Copy

You can only use the copy property within the resources section of an ARM template.  

You can use the copy property at either 
* the resource level to create multiples of that resource, or 
* within a resource to create multiple copies of a property

When you define a copy property the ARM deployment will create a small loop and then iterate through it to make an array at deployment.  

Let's look at how it looks at the resource level first.

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

This will create four copies.  Note that the name of the deployment then uses copyIndex, which iterates through the copy array.  By default the index starts at 0, but using copyIndex(1) offsets that so our resources will be names myResourcePrefix-1 up to myResourcePrefix-4.  These are fairly simple.

Note that there are two other possible properties within the copy object, **mode** and **batchSize**.  By default the mode is _Parallel_.  If, for instance, you are creating four virtual machines, then they would all be created concurrently.  

You can set the **mode** to _Serial_ and also set the **batchSize**.  If you do this then ARM will create a dependsOn on the fly, so that a resource later in the loop array will be dependant on an earlier one.  Usually batchSize is set to 1, but you can increase that if it makes sense for the resource deployment.  

### Resource copy using an array

Hard coding the number of copies is valid for many scenarios, but you will often using functions to calculate the value for copy.   Take a look at this example which would create web apps in multiple regions, making use of a parameter like this:

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

It is then up to the user to define an array with as many valid Azure regions as they deem necessary.  

The count in the copy object is based on the length of that array, and the copyIndex is used purely to pull out the correct array element which is then used to define both the name and region for theweb app deployment.

### Creating multiple disks

Let's do it at the property level against the managed disks used for data.  These use a slightly different structure, creating small arrays of objects on the fly.  They can only be used in places where property arrays are already used, e.g. data disks, NICs, etc.  (Look for the square brackets!)

Create a lab5 and copy in the files from lab4. Create a new parameter in the azuredeploy.json file for numberOfDataDisks, defaulting to 1.  We'll set inline at submission.  (Hint: should it be a string type?)

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
rg=lab5

dir=/mnt/c/myTemplates/$rg
template=$dir/azuredeploy.json
parameters=$dir/azuredeploy.parameters.json

az group create --name $rg --location westeurope

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab5UbuntuVm1 numberOfDataDisks=2 --template-file $template --resource-group $rg --name $job
```

### Final lab5 template and parameters files

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

### What's next

OK, our virtual machine building block is looking a lot more flexible and capable now.  And this is the key, to get to the appropriate level of complexity, flexibility and capability to make the building block as useful as possible.  

The scenario you are looking to avoid is having lots of similar but slightly different templates that you use for different purposes. What you will find over time is that you will need to tweak, change and update your templates as the Azure platform moves forward and the business requirements change.  Having flexible templates simplifies that ongoing work.

In the next section we will look at the benefits of using more complex objects and arrays in the parameters, variables and outputs sections. 