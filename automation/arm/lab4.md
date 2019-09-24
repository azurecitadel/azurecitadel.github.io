---
title: 'ARM Lab 4: Conditions and tests'
date: 2018-04-17
category: automation
author: Richard Cheney
sidebar:
  nav: "arm"
hidden: true
header:
  overlay_image: images/header/arm.png
excerpt: Make your templates richer by using conditional resources and resource properties
---

## Introduction

Conditions are a fairly recent addition, and have massively simplified some of the more complicated template work where we used to make use of nested templates.  This lab will work through a simple example.

Our VM template is working well and the naming is coming through nicely when we have multiple VMs in the resource group:

![Multiple VMs](/automation/arm/images/lab4-1-multipleVms.png)
**Figure 1:** Multiple virtual machine naming

We could rename the storage account used solely for the boot diagnostics, but that is not too important.  Note how the unique name for that is seeded by the resource group ID, so both VM deployments got the same "unique name" and are leveraging the same storage account. If you check the storage account then you can see that each VM's boot diagnostics log.

The change that we're going to make in this lab is to configure the template so that that the PIP (and associated DNS label) are not created if the dnsLabelPrefix parameter is empty.

1. Create a boolean that is set to true if the length of the dnsLabelPrefix is more than zero
1. Add a condition to the top of the public IP resource so that it is only created if that boolean is true
1. Configure the properties for the network interface so that the PIP's ID is only referenced if it has been created

This will make our Ubuntu virtual machine building block template far more useful in a wider number of scenarios.

The following video shows this being done, but it is recommended that you work through the lab yourself first, and only refer to the video if you get stuck, or want to learn a few more vscode keyboard shortcuts!

<iframe width="560" height="315" src="https://www.youtube.com/embed/Ryp5DOgcEtQ?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

**Figure 2:** Making resources conditional

## Set up the lab4 area

Copy the lab3 directory and paste it into a blank area of the Explorer.  Visual Studio Code should automatically create the folder as lab4.

Clear the outputs object.  We'll cover the reason why later.  It should be set to `"outputs": {}`

Default the dnsLabelPrefix parameter to an empty string (`""`) in the main template and save it.  Also remove the whole object from your parameters file so that you only have:

* the adminUsername string
* the adminPassword key vault reference
* the vNet

If you were to submit now, your deployment should fail as your template requires a valid dnsLabelPrefix. Let's make the changes to add in the conditions.

## Creating booleans

There are a number of [functions](https://aka.ms/armfunc) available that output either true or false, and you can embed those straight into a condition.

For example, `"condition": "[equals(variables('env'), 'prod')]",` would only create the resource if the env variable was set to prod.

I often prefer to use boolean variables as they make the expressions shorter later in the template.  The bool() function takes a string or value and returns it as either boolean true or false.  One nice thing is that you can use question marks within variable names and so I use that as a standard to denote booleans.

We can use the empty() function to test whether dnsLabelPrefix has been specified and then set our boolean to false or true:

```json
        "pip?": "[if(empty(parameters('dnsLabelPrefix')), bool('false'), bool('true'))]",
```

Or you could use other comparative functions such as greater(), and use 1 or 0 with bool() for true and false:

```json
        "pip?": "[if(greater(length(parameters('dnsLabelPrefix')), 0), bool(1), bool(0))]",
```

Or forget about the `if` function altogether and just pick functions that return boolean true or false as per the [aka.ms/armfunc](https://aka.ms/armfunc) page.

```json
        "pip?": "[not(empty(parameters('dnsLabelPrefix')))]",
```

Any of those functions expressions will set our new boolean correctly.

* Create a new boolean variable called "pip?" based on the whether dnsLabelPrefix is an empty string or not

## Conditions

Condition is an optional keyword that can be used in any of your resource objects.  It is usual to place a condition above the other required set of four keywords: name, type, apiVersion and location.  This is to make it more obvious when reading.

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

The difference in the dependsOn list is seemingly unimportant. The resourceId() function will always return the resource ID. It is essentially concatenating subscription().subscriptionId and resourceGroup().name plus a few strings to generate the ID. At deployment the Resource Manager evaluates the dependencies between the resources, but only for those defined in the template. At that point my understanding is that it knows it is not creating the public IP and therefore ignores it in the dependsOn. The upshot is that specifying both the subnet ID and the pip ID in the dependsOn list is not a problem.

The difference in the properties.ipConfigurations[0].properties area is a little more challenging. In the first example it contains the following name:object pair:

```json
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('pipName'))]"
              },
```

In the non-pip version it does not appear, but the good news is that it is valid to have the following:

```json
              "publicIPAddress": null,
```

So, all we need to do is create a new object in the variables section and then add an if() function against the publicIPAddress.  First of all the variable:

```json
        "pipObject": {
            "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('pipName'))]"
        },
```

In the NIC section we can then define it as follows:

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
                            "publicIPAddress": "[if(variables('pip?'), variables('pipObject'), json('null'))]",
                            "subnet": {
                                "id": "[variables('subnetRef')]"
                            }
                        }
                    }
                ]
            }
        },
```

The publicIPAddress section will insert the object we just defined, or will generate a null JSON object.  (The json() function is really useful and could be used to generate the pipObject inline, but that would look more unwieldy.)

## Test the template

Deploy a couple of VMs, one with a public IP and one without.  Make sure you are in your lab4 directory if using the following commands, and don't forget to pick your own dnsLabelPrefix.

```bash
dir=$(pwd)
template=$dir/azuredeploy.json
parms=$dir/azuredeploy.parameters.json
rg=$(basename $dir)

az group create --name $rg --location westeurope

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab4UbuntuVm1 --template-file $template --resource-group $rg --name $job --no-wait

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab4UbuntuVm2 dnsLabelPrefix=richeneylab4vm2 --template-file $template --resource-group $rg --name $job --no-wait
```

<video video width="800" height="600" controls>
    <source type="video/mp4" src="/automation/arm/images/lab4-3-submit.mp4"></source>
    <p>Your browser does not support the video element.</p>
</video>
**Figure 3:** Submitting using inline parameters

## Alternatives

Substituting in variables or null in this way is the simplest way to handle condtional pro> rties.

However, you may find that there are more substantial differences.  In that case you have a couple more options, either using alternate resources, or building up your properties.

> The following section is extremely optional and gets a little more technical.  If you think that the above information on conditions is more than sufficient then feel to skip to the [end of the lab](#final-lab4-template-and-parameter-files).

## - Duplicated resources

You can duplicate the resource, and make the required properties differences between the blocks. A few things to remember:

* You will need different condition at the top of each resource, e.g.
    * Boolean inverse
        * `"condition": "[variables('pip?')]",`
        * `"condition": "[not(variables('pip?'))]",`
    * Any valid condition expression
        * `"condition": "[equals(variables('env'), 'prod']",`
        * `"condition": "[or(equals(variables('vmSize'), 'dev'), equals(variables('vmSize'), 'test'))]",`
* Ensure that logically only one of each duplicated resource will ever get created per deployment
* Ensure that each has a unique resource name (and therefore resourceId), e.g.
    * `"name": "[concat(variables('nicName'), '-public')]"`
    * If not then the template will fail validation with the follwoing error message: "The resource '_\<resourcetype-name\>_' is defined multiple times in a template."

It is often easier to create additional variables, e.g.:

```json
      "privateNicName": "[concat(parameters('vmName'), '-nic')]",
      "publicNicName": "[concat(parameters('vmName'), '-nic-public')]",
      "privateNicID": "[resourceId('Microsoft.Network/networkInterfaces/', variables('privateNicName'))]",
      "publicNicID": "[resourceId('Microsoft.Network/networkInterfaces/', variables('publicNicName'))]",
      "nicId": "[if(equals(variables('nicType'), 'private'), variables('privateNicID'), variables('publicNicID'))]",
```

The last variable, nicId, is similar to a pointer. We reference nicId a couple of times in the main virtual machine resource block, and having a pointer variable simplifies the expressions in the main resources area so that you don't have lots of verbose if() functions littering the template.

Rather than having multiples of this:

```json
"id": "[if(equals(variables('nicType'), 'private'), variables('privateNicID'), variables('publicNicID'))]"
```

We can just use:

```json
"id": "[variables('nicID')]
```

If we didn't have all of those variables then we would end up with horrific and yet valid expressions like this:

```json
"id": "[if(greater(length(parameters('dnsLabelPrefix')), 0), resourceId('Microsoft.Network/networkInterfaces/', concat(parameters('vmName'), '-nic-public')), resourceId('Microsoft.Network/networkInterfaces/', concat(parameters('vmName'), '-nic')))]"
```

Having verbose expressions is one of the reasons that the JSON templates can quickly become unreadable, so make use of variables to prevent that from happening.

## - Building Properties Objects

The other method is more complex but can be useful where the template requires a lot of flexibility.  The idea is to create a number of small objects in the variables section, and then use the union() function to combine them as required dependent on the parameters that the user has chosen.

Using the NIC properties from earlier, here is an example that includes a load balancer backend pool and NAT rule. I'll only keep the pertinent lines:

```json
  "variables": {
        "lb?": "[bool(equals(parameters('env'), 'prod'))]",
        "pip?": "[bool(parameters('dnsLabelPrefix'))]",
        "lbName": "loadBalancer",
        "lbID": "[resourceId('Microsoft.Network/loadBalancers',variables('lbName'))]",
        "pipObject": {
            "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('pipName'))]"
            }
        },
        "bepoolObject": {
            "loadBalancerBackendAddressPools": [
                {
                    "id": "[concat(variables('lbID'), '/backendAddressPools/BackendPool1')]"
                },
            ],
            "loadBalancerInboundNatRules": [
                {
                    "id": "[concat(variables('lbID'),'/inboundNatRules/ssh')]"
                }
            ]
        },
        "ipObject0": {
            "privateIPAllocationMethod": "Dynamic",
            "subnet": {
                "id": "[variables('subnetRef')]"
            }
        },
        "ipObject1": "[if(variables('pip?'), union(variables('ipObject0'), variables('pipObject')),    variables('ipObject0'))]",
        "ipObject":  "[if(variables('lb?'),  union(variables('ipObject1'), variables('bepoolObject')), variables('ipObject1'))]",
  },
  "resources": [
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
                    "properties": "[variables('ipObject')]"
                }
            ]
        }
    },
  ]
```

Note how it rolls from ipObject0 through ipObject1 to ipObject, merging in additional properties as per the booleans.  Also note that each object is at the same nesting level.  For example the pipObject is a level up from the one in the simpler lab section earlier.

We will cover the use of `copy` in the next lab, and this can be worked into these dynamically constructed sections to add in flexibility for arrays as well as objects.

## Final lab4 template and parameter files

It is good to have choices!  Hopefully your files look something similar to these files:

###### Lab 4 Files

<div class="success">
    <b>
        <li>
          <a href="https://raw.githubusercontent.com/richeney/arm-labs/master/lab4/azuredeploy.json" target="_blank">azuredeploy.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm-labs/master/lab4/azuredeploy.parameters.json" target="_blank">azuredeploy.parameters.json</a>
        </li>
    </b>
</div>

## What's next

In the next section we will look at using the copy property to create multiple of a resource, or of a property (such as managed disks) within a resource.

[◄ Lab 3: Secrets](../lab3){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Lab 5: Copies ►](../lab5){: .btn .btn--primary}
