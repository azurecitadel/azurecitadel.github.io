---
layout: article
title: 'ARM Lab 4: Conditions and tests'
date: 2018-04-17
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template, conditions]
comments: true
author: Richard_Cheney
---

{% include toc.html %}

## Introduction

Conditions are a fairly recent addition, and have massively simplified some of the more complicated template work where we used to make use of nested templates.  This lab will work through a simple example.

Our VM template is working well and the naming is coming through nicely when we have multiple VMs in the resource group:

![Multiple VMs](/workshops/arm/images/lab4MultipleVms.png)

We could rename the storage account used solely for the boot diagnostics, but that is not too important.  Note how the unique name for that is seeded by the resource group ID, so both VM deployments got the same "unique name" and are leveraging the same storage account. If you check the storage account then you can see that each VM's boot diagnostics log.

The change that we're going to make in this lab is to configure the template so that that the PIP (and associated DNS label) are not created if the dnsLabelPrefix parameter is empty.

1. Create a boolean that is set to true if the length of the dnsLabelPrefix is more than zero
1. Add a condition to the top of the public IP resource so that it is only created if that boolean is true
1. Configure the properties for the network interface so that the PIP's ID is only referenced if it has been created

This will make our Ubuntu virtual machine building block template far more useful in a wider number of scenarios.

## Set up the lab4 area

Copy the lab3 directory and paste it into a blank area of the Explorer.  Visual Studio Code should automatically create the folder as lab4.

Clear the outputs object.  We'll cover the reason why later.  It should be set to `"outputs": {}`

Default the dnsLabelPrefix parameter to an empty string (`""`) in the main template and save it.  If you were to submit now, your deployment should fail. (Feel free to test that.)

## Creating booleans

There are a number of [functions](https://aka.ms/armfunc) available that output either true or false, and you can embed those straight into a condition.

For example, `"condition": "[equals(variables('env'), 'prod')]",` would only create the resource if the env variable was set to prod.

I often prefer to use boolean variables as they make the expressions shorter later in the template.  One nice thing is that you can use question marks within variable names and so I use that as a standard to denote booleans.

As an empty string is considered false and one with one or more characters is considered true then we can use that when setting our variable.  Add the following variable in to your template:

```json
        "pip?": "[if(parameters('dnsLabelPrefix'), bool('true'), bool('false'))]",
```

The bool function takes a string or value and returns it as either boolean true or false.  If you think that expression doesn't read well then you could always use a longer form version such as:

```json
        "pip?": "[if(greater(length(parameters('dnsLabelPrefix')), 0), bool('true'), bool('false'))]",
```

Or of you are a fan of brevity then feel free to shorten the function as much as possible:

```json
        "pip?": "[bool(parameters('dnsLabelPrefix')))]",
```

Whichever path you take you'll end up with the same result for the new boolean value.

## Conditions

Conditions themselves are fairly simple.  It is another keyword that can be used in a resource object.  It is usual to place it above the required set of four keywords: name, type, apiVersion and location.  This is to make it more obvious when reading.

Add the condition to the top of your public IP resource object.

```json
        {
            "condition": "[variables('pip?')]",
            "name": "[variables('pipName')]",
            "type": "Microsoft.Network/publicIPAddresses",
            "apiVersion": "2017-04-01",
            "location": "[resourceGroup().location]",
            "properties": {
                "publicIPAllocationMethod": "[variables('pipType')]",
                "dnsSettings": {
                    "domainNameLabel": "[parameters('dnsLabelPrefix')]"
                }
            }
        },
```

(I have reordered the other keywords as well for consistency.)

The conditions are the easy part. Let's look at the NIC resource object.

## Conditional property objects

OK, here is the slightly tricker bit.  The NIC resource needs to be created one way if we have the public IP, and another if we are internal IP only. This is the how it should look if we have a public IP:

```json
    {
      "name": "[variables('nicName')]",
      "type": "Microsoft.Network/networkInterfaces",
      "apiVersion": "2017-04-01",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/publicIPAddresses/', variables('pipName'))]",
        "[variables('vnetID')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('pipName'))]"
              },
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
```

And the same block if we have no public IP:

```json
    {
      "name": "[variables('nicName')]",
      "type": "Microsoft.Network/networkInterfaces",
      "apiVersion": "2017-04-01",
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

The difference in the dependsOn list is unimportant. The resourceId() function is great in that it successfully returns an empty string if the resource is not found.  So specifying the dependency on a potentially non-existent public IP address is not a problem.

The difference in the properties.ipConfigurations.publicIpAddress is a little more challenging. In the first example it is 



```bash
dir=$(pwd)
template=$dir/azuredeploy.json
parms=$dir/azuredeploy.parameters.json
rg=$(basename $dir)

az group create --name $rg --location westeurope

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab4UbuntuVm1 --template-file $template --resource-group $rg --name $job --no-wait
```

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

It is good to have choices!  Hopefully your files look something similar to these files:

###### Lab 4 Files

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

[◄ Lab 3: Secrets](../arm-lab3-secrets){: .btn-subtle} [▲ Index](../#index){: .btn-subtle} [Lab 5: Copies ►](../arm-lab5-copies){: .btn-success}