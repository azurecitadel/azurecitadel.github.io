---
layout: article
title: 'ARM Lab 3: Using references and handling secrets'
date: 2018-01-08
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template, references, secrets]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab2-sourcesOfResources
  title: Other sources of resources
next:
  url: ../arm-lab4-conditionalResources
  title: Using conditions and tests 
---

{% include toc.html %}


## Introduction

You should now be fairly comfortable working with JSON templates and parameter files, leveraging the various sources of ARM template, and refactoring variables and parameters and resources to customise the files for your requirements.

In this lab we will look at:
* referencing information 
    * for the current deployment
    * for resources that already exist
* handling secrets with securetext

These are all fairly common as you get more ambitious with your own templates or start using some of the more complex templates that are on the GitHub repository.

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

Note that the subnet is a child resource for the virtual network, which is why the concatenation makes sense.  You can use [Resource Explorer](https://resources.azure.com/) to browse the resources within your subscription, where you can see the resourceIds for your existing resources.  

You will often see the resourceId used in the variables section to simplfy the resources section as much as possible.

You can also listKeys or list{Value} from those same resourceIds.  This is very useful in the outputs sections.  Check the Azure documentation for [listKeys and list{Value}](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-resource#listkeys-and-listvalue) as there are a couple of Bash and PowerShell commands to find out what list actions are supported by each resource type.  Try out the example for the storage account resource type.  You will see listkeys, listAccountSas and listServiceSas.  Taking the listkeys as an example, this then ties in with the [REST API reference](https://docs.microsoft.com/en-gb/rest/api/storagerp/storageaccounts/listkeys) material.

We have no specific lab section for this, but you will see the resource functions littered throughout the templates.

## Handling securetext passwords with Key Vault

OK, time to get a little self-reliant! You should now be comfortable accessing the various resources and documentation area and capable of being more self sufficient, so I will stop detailing all of the steps.  This one will be for you to find your own way rather than be guided.  

I'll help you create a key vault with a new secret called ubuntuDefaultPassword.  After that you will create your own template and parameter files in a **lab3** sub-directory, configuring an Ubuntu VM template that will use the secret in place of a cleartext one in the parameters file.

It is probably worth stating the problem we are solving before you get started.  

All of the templates that include a password field, or any other property that contains sensitive data, should have a type of securetext rather than string.  The key thing that this does is to make sure that someone going through the deployment logs in the portal is not able to view the password.  So that part is not a concern as long as we use securetext as the type.

If we are using a script to prompt a user to enter a password as part of the deployment then again, that would be transient and there should be nothing to see if it is prompted for interactively in the right way, such as with `read -s -p "Enter password: " password` to ensure that the `-s` switch prevents characters being echoed to the terminal.

So the real issue is avoiding scripts and parameter files from containing cleartext password if the location and access permissions would allow them to be viewed.  This is where the use of key vault secrets makes perfect sense.

### Creating a Key Vault

OK, let's begin by creating a lab3a folder and an empty azuredeploy.json and azuredeploy.parameters.json file.  

We'll also need a key vault if you haven't got one.  I have shown below how to make one manually to save time. Or you can use a couple of CLI or PowerShell commands.  Try searching for the Azure documentation page that can help with that.  Or if you wish you can take a look at the [201-key-vault-secret-create](https://github.com/Azure/azure-quickstart-templates/tree/master/201-key-vault-secret-create) quickstart template and use that to automate the creation if you know that this is something you will be doing repeatedly. 

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
  * Save
* Select _Secrets_ in the Settings blade area
  * Add a secret
  * Manual upload
  * Name: **ubuntuDefaultPassword**
  * Value: Enter in a suitable password for the VM we'll create 
  * You don't need to set an activation or expiry date
  * Create

As you have access (as the principal under the access policy), you will be able to go back into the portal to view or change the secret in the future.  Or you can check the various CLI and PowerShell commands on the Azure Docs.  For instance, I could retrieve the password using: 
`az keyvault secret show --name ubuntuDefaultPassword --vault-name richeneyKeyVault --query value --output tsv`

### Create the template

OK, time to roll up your sleeves.  I'll give you a few pointers and then a few requirements and leave you to your own devices for a while.  Use the Ubuntu VM template and parameters file from the previous lab2c that we downloaded from Azure quickstart templates as the base, copying the files into a new lab3a area.  

Pointers:
* With the current (Dec 2017) functionality and schema format you cannot use dynamic key vault names unless you use nested templates
* Search for the information online on how to configure static keyVault names when passing in secrets
* Use commands or the resource explorer to find the id for your key vault
* Your configuration in this lab for keyvaults and secrets should only affect the parameters file, not the main template  

Requirements:
1.  Make sure the adminPassword is set with a reference to the secret from the keyVault rather than a cleartext value 
1.  Move the vmName variable up into the parameters section and default it to the current value
1.  Update the list of allowed Ubuntu versions in your main template to the current 14.x and 16.x LTS versions available on the platform and the default to the 16.x version.  (And feel free to add a few newer ones.)

Once you have completed your files and have successfully submitted then please see how yours compare to the ones below.

If you have time then work out the commands in either PowerShell or Bash to see the available Ubuntu virtual machine images from Canonical. (Hint: the publisher is Canonical.)

We will return to key vaults and secrets when we look at the nesting.

### Deploy into lab3

OK, if you haven't done so already then create a lab3 resource group and deploy the new template into that in order to test it. 

### Final lab3 template and parameter files

###### Lab 3 Files:
<div class="success">
    <b>
        <li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab3/azuredeploy.json" target="_blank">azuredeploy.json</a>
        </li><li>
          <a href="https://raw.githubusercontent.com/richeney/arm/master/lab3/azuredeploy.parameters.json" target="_blank">azuredeploy.parameters.json</a>
        </li>
    </b>
</div>

If yours aren't quite right then use the compare tool from the Command Palette.  

### What's next

In the next section we will look at using the copy property to create multiple of a resource, or of a property (such as managed disks) within a resource.