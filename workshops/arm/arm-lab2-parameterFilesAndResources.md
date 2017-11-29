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

In this section we will create a parameter file.  The most common deployment type uses both ARM templates and corresponding parameter files, and one of the major benefits of this approach is that it allows you to have more standardised scripts.

We will also look at how to add in more than just one resource, and some of the major sources of resource type information to speed up the templating process and enable infrastructure as code deployments for some of the newer or more exotic services available on the Azure platform.

But let's start with the parameter file.

## Parameter Files

The parameter file format uses a different JSON schema to the main templates, and as it does less then it is a simpler design.  Here is the example we used in the theory section:

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "value": "myResourceName"
    },
    "sku": {
      "value": "Standard"
    }
  }
}
```

The JSON schema does support a few more options, but these are rarely seen.  Essentially you need the schema and contentVersion, and for each object in the parameters section there is a simple sub-object that only includes the "value" name:value pair.

The template and parameters file may be called anything, but the common naming convention for both are:

**File Type** | **Naming Convention**
template file | azuredeploy.json
parameters file | azuredeploy.parameters.json

## Creating a parameter file

Whilst we may be on lab2, let's create a parameter files for our lab1 template.

<video video width="800" height="600" autoplay loop>
  <source type="video/mp4" src="/workshops/arm/images/creatingParameterFile.mp4"></source>
  <p>Your browser does not support the video element.</p>
</video>

1. Open vscode
1. Create a new file, 'azuredeploy.parameters.json', in the lab1 folder
1. Type in `armp!` to bring up the snippet for the parameter file
1. Break open the parameters object
1. Use the `arm-paramvalue` snippet to add in parameter values for the two parameters in the section of your azuredeploy.json template
1. Set your values to something that will be accepted during deployment

The arm-paramvalue snippet is designed to highlight the parameter name, so you can type straight away, and then you can tab to the second placeholder to start typing the value.

You can use the split editor mode in vscode to see both files at the same time (CTRL-\, or View \| Split Editor).  You can also save some screen estate by toggling the side bar (CTRL-B, or View \| Toggle Side Bar).

Don't forget that the two parameters will need to seperated by a comma.  You will see a syntax error flagged up by vscode until you do.

Once you have created your parameter file it should look similar to this:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccountPrefix": {
            "value": "richeneysa"
        },
        "accountType": {
            "value": "Standard_LRS"
        }
    }
}
```

## Deploying with a parameter file

We will continue to use variables for the deployment name and the resource group.  

##### Bash
```bash
rg=lab1
job=job.$(date --utc +"%Y%m%d.%H%M")
template=/mnt/c/myTemplates/lab1/azuredeploy.json
parms=/mnt/c/myTemplates/lab1/azuredeploy.parameters.json
az group deployment create --name $job --parameters "@$parms" --template-file $template --resource-group $rg  
```
Note the **@** sign just before the parms variable in the --parameters switch. 

##### PowerShell
```powershell
$rg="lab1"
$job="job3"
$template="C:\myTemplates\lab1\azuredeploy.json"
$parms="c:\myTemplates\lab1\azuredeploy.parameters.json"
New-AzureRmResourceGroupDeployment -Name $job -storageAccount $storageAccount -TemplateFile $template -ResourceGroupName $rg 
``` 
> **NEED TO TEST THE POWERSHELL OUT

