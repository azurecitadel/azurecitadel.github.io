---
title: 'ARM Lab 3: Functions and secrets'
date: 2018-04-17
category: automation
author: Richard Cheney
sidebar:
  nav: "arm"
hidden: true
header:
  overlay_image: images/header/arm.png
excerpt: Explore the various functions and introduce Azure Key Vault for secrets
---

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

Finally, you can use the [reference()](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-resource#reference) function to show current runtime information about a resource.  THis is very useful in the outputs section to return the current values for resource properties such as DHCP allocated IP addresses.  We'll use reference() at the end of this lab for practice.

## Copying the 101-vm-simple-linux

If you ran through the previous lab then you should already have created a lab3 area containing the contents of the [101-vm-simple-linux](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-simple-linux) from the Quickstart templates.

If not then copy out the [azuredeploy.json](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-linux/azuredeploy.json) and [azuredeploy.parameters.json](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-linux/azuredeploy.parameters.json) out into new files in a new lab3 folder.

Change the values in the parameters file to define your own admin username and password.  Also pick a different dnsLabelPrefix as this needs to be globally unique as it forms part of an externall accessible FQDN.

## Handling securetext passwords with Key Vault

OK, time to get a little self-reliant! You should now be comfortable accessing the various resources and documentation area and capable of being more self sufficient, so I will stop detailing all of the steps.  This one will be for you to find your own way rather than be guided.

First we'll create a key vault with a new secret called ubuntuDefaultPassword.  After that you will configure your template and parameter files to use that secret in place of the cleartext password in the parameters file.

It is probably worth stating the problem we are solving before you get started.

All of the templates that include a password field, or any other property that contains sensitive data, should have a type of securetext rather than string.  The key thing that this does is to make sure that someone going through the deployment logs in the portal is not able to view the password.  So that part is not a concern as long as we use securetext as the type.

If we are using a script to prompt a user to enter a password as part of the deployment then again, that would be transient and there should be nothing to see if it is prompted for interactively in the right way, such as with `read -s -p "Enter password: " password` to ensure that the `-s` switch prevents characters being echoed to the terminal.

So the real issue is avoiding scripts and parameter files from containing cleartext password if the location and access permissions would allow them to be viewed.  This is where the use of key vault secrets makes perfect sense.

## Creating a Key Vault

OK, let's begin by creating a lab3 folder and an empty azuredeploy.json and azuredeploy.parameters.json file.

We'll also need a key vault if you haven't got one.  We'll create that in a **keyVaults** resource group as we'll be using that for several of the labs.

There are manual steps shown below for the key vault creation. (If you wish you can use a couple of CLI or PowerShell commands.  Try searching for the Azure documentation page that can help with that.  Or if you like you can take a look at the [201-key-vault-secret-create](https://github.com/Azure/azure-quickstart-templates/tree/master/201-key-vault-secret-create) quickstart template and use that to automate the creation if you know that this is something you will be doing repeatedly.)

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

## Reconfigure your parameters file

OK, time to roll up your sleeves.  I'll give you a few pointers and then a few requirements and leave you to your own devices for a while.

Pointers:

* With the current (Dec 2017) functionality and schema format you cannot use dynamic key vault names unless you use nested templates
* Search for the information online on how to configure static keyVault names when passing in secrets
* Use commands or the resource explorer to find the id for your key vault
* Your configuration in this lab for keyvaults and secrets should only affect the parameters file, not the main template

Requirements:

1. Make sure the adminPassword is set with a reference to the secret from the keyVault rather than a cleartext value
1. Move the vmName variable up into the parameters section and default it to the current value
1. Update the list of allowed Ubuntu versions in your main template to the current 14.x and 16.x LTS versions available on the platform and the default to the 16.x version.  (And feel free to add a few newer ones.)
1. Update the parameters file as well:
    * Set the adminUsername to your username
    * Set the dnsLabelPrefix to something that will be unique for the FQDN
1. Fix any problems (`CTRL-SHIFT-M`)
    * update any API versions for resources triggering problems

If you have time then work out the commands in either PowerShell or Bash to see the available Ubuntu virtual machine images from Canonical. (Hint: the publisher is Canonical.)

## Use reference() in the outputs section

There will be times when you want to output the runtime value of a resource property.  For this example, we want the resource ID of the OS managed disk that is created by our template.

One way to find out the dot notation for the property value is to output the whole reference() block and then drill into that informtion.

1. Create a new variable called vmId
    * use the resourceId() function
    * pass in the virtual machine resource type and name
1. You can then use the following code block in the outputs section:

```json
      "vmRef": {
          "type": "object",
          "value": "[reference(variables('vmId'))]"
      }
```

3. Create a lab3 resource group
1. Deploy the template and parameter file into lab3

Once the job has deployed then you can see look at the output in the portal, or by using the following command:

```bash
az group deployment show --name jobname --query properties.outputs.vmRef.value --output json --resource-group lab3
```

This will show the entire JSON object for the resource's properties.

You can then work out the dot notation to drill down into the JSON object and pull out the specific value you need. Once you have worked with JSON for a while then this will become second nature. See the following video for one example of how this can be done.

<iframe width="560" height="315" src="https://www.youtube.com/embed/2NDzYQW7RFg?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

**Figure 1:** Using references and [jqplay](https://jqplay.org/)

You can then rename the output from _vmRef_ to _osDiskId_, change it from object to string and use the dot notation it to output the correct sub value:

```json
      "osDiskId": {
          "type": "string",
          "value": "[reference(variables('vmId')).storageProfile.osDisk.managedDisk.id]"
      }
```

## View the resources

OK, connect to the VM and confirm that the password is the one you stored in the Key Vault.

We will first spend a little time cleaning up the template to make it more useful and sort out some of the resource names.  Once that is done and tested then we'll add in a condition in the next lab to make the public IP (PIP) and associated DNS name optional.

This will be a little painful, but once it is done then the template will be far more useful as a building block.

If you look at the resources that have been spun up in resource group lab3 from our lab3 template then you'll notice a few things:

![lab3 resources](/automation/arm/images/lab3-2-resources.png)
**Figure 2:** Initial resource names

* The vNet (and subnet) are fixed variables for both the name and the address space, so additional VMs deployed to this resource group using this template would share the same networking.  This is fine, but let's make them parameters with defaults instead.
* This template creates first level Managed Disks for the OS (30GB) and the data disk (1023GB), with unique names prefixed with the vmName
* The PIP and NIC are fixed names and would conflict if a second was added

----------

## Refactoring the networking parameters and variables

OK, we've addressed the password.  Let's start turning the template itself into a more useful building block by refactoring a few things.

1. Create parameters for the following:
    * vnetName with no default
    * vnetPrefix, defaulting to "10.0.0.0/16"
    * subnetName, defaulting to "Subnet"
    * subnetPrefix, defaulting to "10.0.0.0/24"
1. Remove the corresponding variables
    * vnetName is replacing virtualNetworkName
    * vnetPrefix is replacing addressPrefix
1. Remove the default for the vmName
1. Change the value for the nicName variable to be the vmName with '-nic' at the end
1. Change the publicIPAddressName variable to pipName
    * Change the value for the pipName variable to be the vmName with '-pip' at the end
1. Change the publicIPAddressType variable to pipType
1. Change the value for the vmSize variable to "Standard_B1s"

In the parameters file, add in new vnetName and subnetName parameters and **remove** both vmName and dnsLabelPrefix. Here is an example:

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
    "vnetName": {
        "value": "ubuntuVnet"
    },
    "subnetName": {
        "value": "ubuntuSubnet"
    }
  }
}
```

### Submitting using both parameter files and inline parameters

Once you have done that then we'll deploy the template **twice** into the lab3 resource group.

Note that both deployments below use the `--parameters` switch twice, first to pull in the parameters file, and then with some inline name=value pairs to to specify the VM name and DNS label prefix.

```bash
rg=lab3

dir=$(pwd)
template=$dir/azuredeploy.json
parms=$dir/azuredeploy.parameters.json

az group create --name $rg --location westeurope

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab3UbuntuVm2 dnsLabelPrefix=richeneylab3vm2 --template-file $template --resource-group $rg --name $job --no-wait

job=job.$(date --utc +"%Y%m%d.%H%M%S")
az group deployment create --parameters "@$parms" --parameters vmName=lab3UbuntuVm3 dnsLabelPrefix=richeneylab3vm3 --template-file $template --resource-group $rg --name $job --no-wait
```

The deployment lines also have the `--no-wait` switch at the end so that the deployments go in faster.

Combining parameter files and inline parameters in this way can be very useful, particularly in multi-tenancy environments.

## Final lab3 template and parameter files

###### Lab 3 Files

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

## What's next

In the next section we will look at using the copy property to create multiple of a resource, or of a property (such as managed disks) within a resource.

[◄ Lab 2: Sources](../lab2){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Lab 4: Conditions ►](../lab4){: .btn .btn--primary}
