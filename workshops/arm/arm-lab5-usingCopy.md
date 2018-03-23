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

The count in the copy object is based on the length of that array, and the copyIndex is used purely to pull out the correct array element which is then used to define both the name and region for the web app deployment.

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

Before we deploy the template, let's remove that default value for the vmName. We'll continue to do that as an inline parameter in this lab so:
* In the azuredeploy.json, change the parameter definition for vmName
    * remove the default value
    * find out any length restrictions for virtual machine names
    * set a minimum length and maximum length (to make sure that vmName does get specified at some point)
* Remove the vmName parameter from azuredeploy.parameters.json

If you fail to specify the vmName parameter inline then you should now fail validation with a meaningful error message. 

OK, now submit the VM, specifying the name and number of disks:

```bash
rg=lab5

dir=$(pwd)
template=$dir/azuredeploy.json
parms=$dir/azuredeploy.parameters.json

az group create --name $rg --location westeurope

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab5UbuntuVm1 numberOfDataDisks=2 --template-file $template --resource-group $rg --name $job
```

### Final lab5 template and parameters files

Here are the final set of files:

#### azuredeploy.json

###### Lab 5 Files:
<div class="success">
    <b>
        <li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab5/azuredeploy.json" target="_blank">azuredeploy.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab5/azuredeploy.parameters.json" target="_blank">azuredeploy.parameters.json</a>
        </li>
    </b>
</div>
```

### What's next

OK, our virtual machine building block is looking a lot more flexible and capable now.  And this is the key, to get to the appropriate level of complexity, flexibility and capability to make the building block as useful as possible.  

The scenario you are looking to avoid is having lots of similar but slightly different templates that you use for different purposes. What you will find over time is that you will need to tweak, change and update your templates as the Azure platform moves forward and the business requirements change.  Having flexible templates simplifies that ongoing work.

In the next section we will look at the benefits of using more complex objects and arrays in the parameters, variables and outputs sections. 