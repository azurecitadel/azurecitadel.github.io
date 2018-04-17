---
layout: article
title: "Terraform Lab 2: Variables"
categories: null
date: 2018-05-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

In this lab we'll still be using the Cloud Shell, but we'll switch to using Visual Studio Code for our editing and leverage some of the extensions to integrate.

If you haven't done so already, install [vscode](/guides/vscode) and make sure that you have the following extensions installed:

**Module Name** | **Author** | **Extension Identifier**
Azure Account | Microsoft | [ms-vscode.azure-account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
Azure Terraform | Microsoft | [ms-azuretools.vscode-azureterraform](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform)
Terraform | Mikael Olenfalk | [mauve.terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)
Advanced Terraform Snippets Generator | Richard Sentino | [mindginative.terraform-snippets](https://marketplace.visualstudio.com/items?itemName=mindginative.terraform-snippets)

Use `CTRL+SHIFT+X` to open the extensions sidebar.  You can search and install the extensions from within there.

As you move through the lab you will start to make use of variables and multiple .tf files.  We'll modify existing resources and add new resources and new providers.

## Visual Studio Code

Before we start using variables etc., let's get vscode working for us.  We'll create a folder for our workspace and set the workspace to default to linux friendly LF line endings.

* Open Visual Studio Code
* Click on the Explorer (or use CTRL+SHIFT+E)
* Open Folder
* Create and then open a new local folder for your lab files, e.g. C:\terraform\lab2
* Type `CTRL+,` to open Settings:

![eol](/workshops/terraform/images/eol.png)

All of the available and defaulted settings are shown on the left, and they can then be overriden at the user or workspace level.

1. Click on Workspace Settings
1. Search for `eol`
1. Hover over the "files.eol" setting, click on the pen to edit it and select "\n"
1. Type `CTRL+S` to save your new workspace settings

OK, the area is ready.  Let's quickly recreate the main.tf file from the last lab with a new resource group name.

* Create a new file in the folder called main.tf
    * Hover over the lab2 bar in the explorer sidebar for the New File icon
* Paste in the contents of the codebox below

```yaml
resource "azurerm_resource_group" "lab1" {
  name      = "terraformLab2"
  location  = "West Europe"

  tags {
    environment = "Training"
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = "richeneysa1976"
  resource_group_name      = "${azurerm_resource_group.lab1.name}"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

This is the same file as we used in the last lab.  Don't forget to change your storage account name again.

Now that we are using vscode with the various plugins, we have a multitude of productivity gains, such as linting, intellisense, snippets, auto-complete. The .tf extension is automatically associated with Terraform.

![vscode](/workshops/terraform/images/main.tf.png)

1. It should now show LF rather than CRLF in the toolbar (from the workspace settings)
1. The round blob in the tab shows it is not saved - use `CTRL-S` to save it locally

Let's push it up to the Cloud Shell:

* Type 'CTRL+SHIFT+P` to open the Command Palette
* Type 'push' and select 'Azure Terraform: push'
* You'll be asked if you want to open Cloud Shell.  Click on OK
* Select the directory if your ID is linked to multiple tenancies
* Bash in Cloud Shell will open in the Integrated Console
* You will be prompted to confirm the push of project files from the current workspace to the Cloud Shell
* The files will be pushed up into a new ~/clouddrive/lab2 directory in the Cloud Shell
    * Subsequent pushes will be much quicker
* In the Cloud Shell `cd clouddrive/lab2` and then `ls -l`

![Post push](/workshops/terraform/images/postpush.png)

You can now run through the terraform init, plan and apply workflow using either

* the normal commands within the Integrated Console (which is toggled with CTRL+'), or
* using the Command Palette (CTRL+SHIFT+P) and then searching on init, plan and apply to find the commands from the Azure Terraform extension

Confirm that the services are up by checking in the portal of using the CLI.

## Introducing variables

One thing that is very useful in Terraform is to make use of multiple .tf files.  The terraform commands will look at all *.tf files in the current working directory.  (Note that by design it does _not_ recursively move through sub-directories.)

So let's create a variables.tf file in the lab2 directory and define some of the key variables in there.

Create the variables.tf file in vscode and paste in the following:

```yaml
variable "rg" {
    default = "terraformLab2"
}

variable "loc" {
    default = "West Europe"
}

variable "tags" {
    type = "map"
    default = {
        environment = "training"
        source      = "citadel"
    }
}
```

Browse to the <https://aka.ms/terraform/docs> area, and navigateto the [variables](https://www.terraform.io/docs/configuration/variables.html) section.

You'll see that there are different ways to define the variables.  There are three types of valid variables, which are string, list or map.

    **💬 Note.** If you are familiar with ARM template then the Terraform variables are synonymous with the parameters in ARM templates, but can also be used to define variables that can be used globally by all *.tf files in the current working directory (cwd).

The most commonly used variable argument is `default`. Terraform will infer the variable type from the default value.  If you do not have a default then it will default to string so if you want a list or map then you have to specify the `type` argument. 

The `description` argument is optional but recommended, particularly when you are creating reusable modules in the later labs.

We could have added these lines to the top of our main.tf file, but it makes sense to have them in separate files.  It is the variables that commonly change between deployments, so moving them may allow the other *.tf files to be re-used without change.  Also we can use different file permissions for the variables file if required.

Let's edit our existing main.tf file and make use of the variables. The interpolation format is `"${var.<varname>}"`.

1. Change the resource group's name to use `"${var.rg}"`
1. Change the resource group's location to make use of the new `loc` variable
1. Change the location for the storage account and link it to the resource group's location
1. Save your files and then push them into the Cloud Shell
1. Run a `terraform plan`




## End of Lab 2

CHANGE ME

We have reached the end of the lab. You have learned some basics about Terraform HCL files, and gone through the standard Terraform workflow for creating and destroying Azure resources.

In the next lab we will introduce variables, use multiple .tf files, and we'll add and modify to our resources. Click on the right arrow to move to the next lab.

[◄ Lab 1: Basics](../lab1){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 3: Outputs ►](../lab3){: .btn-success}