---
layout: article
title: 'ARM Lab 6: Using objects and arrays'
date: 2018-01-08
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template, objects, arrays]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab5-usingCopy
  title: Using copy to create multiple resources 
next:
  url: ../arm-lab7-nestingTemplates
  title: Nesting templates  
---

{% include toc.html %}

## Introduction

In this lab we will introduce the use of complex parameter and variable objects.  It is common to use these when defining capable building blocks called by a master template to provide simplicity, flexibility and standardisation.  This lab will combine with the next to bring together some of these elements and then task you with creating your own master template and linked templates for your building blocks.

## Example parameters section with complex structures

OK, let's start with using objects rather than strings in the parameter section.  You have already been using objects when using functions such as subscription() and resourceGroup().  They return standard JSON objects, and then you usually pull out one of the values, such as resourceGroup().location.  You can also use objects and arrays in the parameters section.

Below is an example parameters section for a networking template:

```json
  "parameters": {
    "peer": {
      "type": "bool",
      "allowedValues": [ true, false ],
      "defaultValue": false
    },
    "hub": {
      "type": "object",
      "defaultValue": {
        "resourceGroup": "core",
        "vnet": {
          "name": "core"
        }
      },
      "metadata": {
            "description": "Info for an existing hub or core vNet.  Required if peer==true.  Assumed to be within the same subscription."
      }
    },
    "spoke": {
      "type": "object",
      "defaultValue": {
        "vnet": {
          "name": "Spoke",
          "addressPrefixes": [ "10.99.0.0/16" ]
        },
        "subnets": [
          { "name": "subnet1", "addressPrefix": "10.99.0.0/24" },
          { "name": "subnet2", "addressPrefix": "10.99.1.0/24" }
        ]
      },
      "metadata": {
        "description": "Complex object containing information for the spoke vNet.  See defaultValue for example."
      }
    }
  },
```

The first parameter is a simple true or false boolean, which is very useful for conditions and if functions.  Here is an example condition statement lower down in that same template:

```json
   {
      "condition": "[parameters('peer')]",
      "name": "[concat(parameters('spoke').vnet.name, '/to-', parameters('hub').vnet.name)]",
```

As the boolean itself returns either true or false then it shortens the condition test as much as possible.  The same is true when using it within `"[if(test, true, false)]"` functions.  In fact booleans are so useful for this that you will often derive booleans in your variable sections.  Remember the nicType string variable from lab3?  That could easily have been something like this instead:

```json
"deployPip": "[if(greater(length(parameters('dnsLabelPrefix')), 0), bool('true'), bool('false')]"
``` 

Look again at the parameters section and the JSON objects for both "hub" and "spoke".  You can see the nesting of strings, objects and arrays.  And just as resourceGroup().location pulls out a single value within the object returned by resourceGroup(), you can see the same happening with the second line in that example condition statement section:

```json
   {
      "condition": "[parameters('peer')]",
      "name": "[concat(parameters('spoke').vnet.name, '/to-', parameters('hub').vnet.name)]",
```

The concat command is pulling out the name of the spoke vnet and the name of the hub vnet.  This is very readable.  

One of the other benefits is the ability to use copy elements with arrays.  The subnets array within the spoke object is a good example.  Here is a reminder on how that looks:
```json
    "spoke": {
      "type": "object",
      "defaultValue": {
        "vnet": {
          "name": "Spoke",
          "addressPrefixes": [ "10.99.0.0/16" ]
        },
        "subnets": [
          { "name": "subnet1", "addressPrefix": "10.99.0.0/24" },
          { "name": "subnet2", "addressPrefix": "10.99.1.0/24" }
        ]
      },
      "metadata": {
        "description": "Complex object containing information for the spoke vNet.  See defaultValue for example."
      }
    }
```
This structure allows us to pass in an object that has only one subnet or flexibly allowed multiple subnets within that spoke's vNet.  And this works well with the copy section in the main virtual network resource:
```json
  "resources": [
    {
      "name": "[parameters('spoke').vnet.name]",
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2017-10-01",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": "[parameters('spoke').vnet.addressPrefixes]"
        },
        "copy": [{
          "name": "subnets",
          "count": "[length(parameters('spoke').subnets)]",
          "input": {
            "name": "[parameters('spoke').subnets[copyIndex('subnets')].name]",
            "properties": {
              "addressPrefix": "[parameters('spoke').subnets[copyIndex('subnets')].addressPrefix]"
            }
          }
        }]
      }
    },
```
The copy section loops through the array, using the length of the array as the count, and then input section pulls in the name and the addressPrefix.  

Also notice the addressPrefixes value.  This is returning an array rather than a string, which is exactly what is required for the addressSpace.addressPrefixes property.  It is very rare to have more than one address prefix in the address space, but it is possible if a customer has a requirement for a discontiguous address space, and this template is ready for that.

## Using empty resource arrays to test 

As we start using complex objects and arrays in both the parameter section and the variables section, you may need to troubleshoot syntactical errors which are less obvious than before.  One useful way of doing this is to use an ARM template with no resources.  Let's build one:

1. Create a new template called 'noresources.json' in a new lab6 directory
1. Add in the empty ARM template structure
1. Copy in the example parameters section from the top of the lab
1. Leave the variables object and the resources array empty
1. Add in some outputs into the output section:
    * Output a boolean, i.e. the peer value
    * Output a string, e.g. the name of the hub's resource group
    * Output an array, e.g. the spoke vnet's address space, or the list of subnets for the spoke vnet
    * Output an object, e.g. the whole of the 'spoke' object
1. Run a "deployment" against the noresources.json file.  You shouldn't need to specify any parameters.  You will have to specify an existing  resource group even through no resources will be deployed.

We will use this technique a little more as we work through the variables section and start delving into the reference function a little more.

## Object and array variables 

Adding more complexity into the variables section can paradoxically simplify the templates.  We will look at three areas:
1. Using 't-shirt' variable objects to standardise on grouped values
1. Using 'pointer' variables to shorten expressions in the resources section
1. Creating arrays using copy

## Using variables to define t-shirt sizes

This section is key to start defining the standards that you want to incorporate into your designs.  We are starting to create building block templates that provide a great deal of flexibility, but the danger there is that as a business or as a service provider, that flexibility leads to a lack of standardisation that can impact your ongoing support of provisioned systems.  Therefore creating sensible groupings can help here.  There are commonly called t-shirt sizes.  The Azure platform itself does this.  When you provision a [DSv3](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general#dsv3-series-sup1sup) virtual machine, you select from various sizes.  As you go up the sizes you have more vCPUs, more memory, larger temp storage, more storage IOPS and network bandwidth, and a higher number of possible data disks and NICs.  You do not have full flexibility on selecting a server with, for instance, a low number of vCPUs but a large amount of memory.  (You'll find other VM series that offer different ratios, but you get the point.) 

You can do the same sort of thing for your deployments.  Here is an example:

#### VM t-shirts

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vmSize": {
           "type": "string",
           "allowedValues": [
               "small",
               "medium",
               "large"
           ],
           "defaultValue": "small",
           "metadata": {
                "description": "T-shirt sizes for virtual machines"
            }
        }
    },
    "variables": {
        "vmSizeSmall": {
          "vm": "Standard_B1s",
          "diskSize": 200,
          "diskCount": 1,
          "nicCount": 1,
          "defaultSubnets": [ "production" ]
        },
        "vmSizeMedium": {
          "vm": "Standard_A1",
          "diskSize": 1023,
          "diskCount": 2,
          "nicCount": 1,
          "defaultSubnets": [ "production" ]
        },
        "vmSizeLarge": {
          "vm": "Standard_A4",
          "diskSize": 1023,
          "diskCount": 4,
          "nicCount": 2,
          "defaultSubnets": [ "production", "database" ]
        }
    },
    "resources": [],
    "outputs": {
        "size": {
            "type": "string",
            "value": "[parameters('vmSize')]"
          },
          "vm": {
              "type": "object",
              "value": "[variables(concat('vmSize', parameters('vmSize')))]"
          },
          "diskSize": {
              "type": "int",
              "value": "[variables(concat('vmSize', parameters('vmSize'))).diskSize]"
          },
          "vmImage": {
              "type": "string",
              "value": "[variables(concat('vmSize', parameters('vmSize'))).vm]"
          },
          "vmSubnets": {
              "type": "array",
              "value": "[variables(concat('vmSize', parameters('vmSize'))).defaultSubnets]"
          },
          "firstSubnet": {
              "type": "string",
              "value": "[variables(concat('vmSize', parameters('vmSize'))).defaultSubnets[0]]"
          }
    }
}
```

Let's walk through this one quickly.  

In terms of parameters, there is only one.  The vmSize parameters can be set to either small, medium or large.

In the variable section we define the three variable objects, and each contains the same collection of named integers, strings and arrays, but set to different values.   

The output section then shows a few example ways of using our variables.  The 'vm' output returns the whole object, and the 'vmSubnets' returns the array within it.  The other outputs return individual integers or strings. 

Copy the template above into a new template file, and then submit using `az group deployment create --template-file <template.json> --query properties.outputs --resource-group <resourceGroup> --output jsonc` to see the output json.

## Using 'pointer' variables

As you can see from the template above, it can get a little verbose when so many of the function calls evaluate the concat to get to the correct variable object.  The plus side is that it is obvious that those properties wil differ based on the vmSize parameter.

If you wish to make the template a little more succinct and readable then you can dynamically set a variable and reference that throughout the template instead.

Try creating a new variable called simply 'vmSize', and then set it to the right object.  Take a look at the 'vm' output in the example above if you are struggling with the syntax. 

You can then change the outputs, so that rather than having `variables(concat('vmSize', parameters('vmSize')))`, they are set as `variables('vmSize')`.  (Don't forget that you can use CTRL+F2 in VS Code to Change All Occurences of your selected text.) 

A couple of additional things to note:
* There is no issue with having parameters and variables with the same name.  We only ever reference them with the explicit _parameters_ and _variables_ functions so there are no problems there.
* The functions and values are case insensitive. Note that the vmSize parameter in the example is all lower case.  The concat in the variables section will therefore return 'vmSizesmall', whereas the variable object is actually named 'vmSizeSmall', with the additional medial capital.  Again, this is not a problem as we are not case sensitive.  (The same is true for the function names as well.)

Once you have made those changes then your template should look a little like this:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vmSize": {
           "type": "string",
           "allowedValues": [
               "small",
               "medium",
               "large"
           ],
           "defaultValue": "small",
           "metadata": {
                "description": "T-shirt sizes for virtual machines"
            }
        }
    },
    "variables": {
        "vmSizeSmall": {
          "vm": "Standard_B1s",
          "diskSize": 200,
          "diskCount": 1,
          "nicCount": 1,
          "defaultSubnets": [ "production" ]
        },
        "vmSizeMedium": {
          "vm": "Standard_A1",
          "diskSize": 1023,
          "diskCount": 2,
          "nicCount": 1,
          "defaultSubnets": [ "production" ]
        },
        "vmSizeLarge": {
          "vm": "Standard_A4",
          "diskSize": 1023,
          "diskCount": 4,
          "nicCount": 2,
          "defaultSubnets": [ "production", "database" ]
        },
        "vmSize": "[variables(concat('vmSize', parameters('vmSize')))]"
    },
    "resources": [],
    "outputs": {
        "size": {
            "type": "string",
            "value": "[parameters('vmSize')]"
          },
          "vm": {
              "type": "object",
              "value": "[variables('vmSize')]"
          },
          "diskSize": {
              "type": "int",
              "value": "[variables('vmSize').diskSize]"
          },
          "vmImage": {
              "type": "string",
              "value": "[variables('vmSize').vm]"
          },
          "vmSubnets": {
              "type": "array",
              "value": "[variables('vmSize').defaultSubnets]"
          },
          "firstSubnet": {
              "type": "string",
              "value": "[variables('vmSize').defaultSubnets[0]"
          }
    }
}
```

One other point to make is that pulling out sub-objects with a dynamic name does not work.  If, for instance, we had a vmSize variable as a  multi-level object with small, medium and large as named objects at the first level, then you could think that a function call like `"[variables('vmSize).parameters('vmSize').diskSize]"` might evaluate to `"[variables(.vmSize.).small.disksize]"`, but unfortunately it will cause an error.  This is why we only dynamically manipulate using the top level variable name.     

## Copy objects

The copy property can be used in two sections of an ARM template, and those are the variables and resources section.  You cannot use it in the parameters and outputs sections.

An example for this would be the data disks, where the diskCount integer property could be used in a copy as the count, and then the name and LUN number could then be derived from the copyIndex. This would be similar to copy sections you have already seen.

Again, for readability you might also wish to dynamically create an array to be used later in the template, and you can create arrays in the variables section.  Let's take a look ahead at one of the building block templates that we will be using in the lab 7, [vnet-spoke.json](https://github.com/richeney/arm/blob/master/lab7/vnet-spoke.json).  This template creates a 'spoke' vNet, and it creates the two way vNet peering to an existing 'hub' vNet. It is designed to be called in a nested deployment, hence the liberal use of objects for the parameters.

There are a number of outputs returned so that the master template can easily find the resource IDs. This is simple for the vNet IDs, but there may be more than one subnet, and this is where copy is useful.  I have removed the content of the resources section to shorten it:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "peer": {
      "type": "bool",
      "allowedValues": [ true, false ],
      "defaultValue": false
    },
    "hub": {
      "type": "object",
      "defaultValue": {
        "resourceGroup": "core",
        "vnet": {
          "name": "core"
        }
      },
      "metadata": {
            "description": "Info for an existing hub or core vNet.  Required if peer==true.  Assumed to be within the same subscription."
      }
    },
    "spoke": {
      "type": "object",
      "defaultValue": {
        "vnet": {
          "name": "Spoke",
          "addressPrefixes": [ "10.99.0.0/16" ]
        },
        "subnets": [
          { "name": "subnet1", "addressPrefix": "10.99.0.0/24" },
          { "name": "subnet2", "addressPrefix": "10.99.1.0/24" }
        ]
      },
      "metadata": {
        "description": "Complex object containing information for the spoke vNet.  See defaultValue for example."
      }
    }
  },
  "variables": {
    "hubID": "[if(parameters('peer'), resourceId(parameters('hub').resourceGroup, 'Microsoft.Network/virtualNetworks/', parameters('hub').vnet.name), '')]",
    "spokeID": "[resourceId('Microsoft.Network/virtualNetworks/', parameters('spoke').vnet.name)]",
    "copy": [
        {
            "name": "subnets",
            "count": "[length(parameters('spoke').subnets)]",
            "input": {
              "name": "[parameters('spoke').subnets[copyIndex('subnets')].name]",
              "addressPrefix": "[parameters('spoke').subnets[copyIndex('subnets')].addressPrefix]",
              "id": "[concat(resourceId('Microsoft.Network/virtualNetworks/', parameters('spoke').vnet.name), '/subnets/', parameters('spoke').subnets[copyIndex('subnets')].name)]"
            }
        }
    ]
  },
  "resources": [...],
  "outputs": {
  "peer": {
    "type": "bool",
    "value": "[parameters('peer')]"
  },
  "hubID": {
    "type": "string",
    "value": "[variables('hubID')]"
  },
  "spokeID": {
    "type": "string",
    "value": "[variables('spokeID')]"
  },
  "subnets": {
    "type": "array",
    "value": "[variables('subnets')]"
  }
}
```

The subnets array pulls out the name and IP address prefix directly from the parameters, but it also derives the resource ID at the same time. The outputs sections then returns the whole subnets array, which is rather useful.  Below is an example of the outputted array contents:

```json
[
  {
    "name": "subnet1", 
    "addressPrefix": "10.99.0.0/24",
    "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/testSpoke/providers/Microsoft.Network/virtualNetworks/Spoke/subnets/subnet1"
  },
  {
    "name": "subnet2",
    "addressPrefix": "10.99.1.0/24",
    "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/testSpoke/providers/Microsoft.Network/virtualNetworks/Spoke/subnets/subnet2"
  }
]
```

## Testing and troubleshooting

As you start working with more complex templates with parameter and variable arrays and objects, and multiple resources, then you will inevitably come across validation and deployment errors.  So here are a few tips for you:

1. Start simple with small and hardcoded templates, and then iterate to add in the flexibility and complexity that you need
1. Use the intellisense within VS Code to check for syntactical errors
1. Use the `Test-AzureRmResourceGroupDeployment` and `az group deployment validate` commands
1. Use the outputs section to check your parameters and variables function calls that you are using in your resources section.  If you are not getting the right output in the outputs section then it can help to explain why your resources are not working properly.
1. If you have multiple resources and you cannot determine which is causing your problem then select them all, and then cut and paste them into a temporary file. Check that the template deploys with no resources, and then slowly re-add the resources one by one and this will help to identify the problematic resource.
1. Read the error messages! There are times that they are not particularly informative, but often they will give a useful pointer to help you troubleshoot the offending statement. 

## What's next

This lab contains some really useful information for those of you creating more complex templates, and will help to coalesce some of the thinking that can make nested templates.  

In the next lab we will take a look at an example of nested deployments using both inline and linked templates.  And then you will take a look at key vaults again and use a nested deployments to work around the hardcoded key vault and secret names that we had to use in the earlier lab.