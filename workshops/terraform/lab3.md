---
layout: article
title: "Terraform Lab 3: Core Environment"
categories: null
date: 2018-06-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

In this lab we will build out a core environment, with some of the core networking services you would expect to see in a hub and spoke topology.  We will start using multiple .tf files, and we'll make use of GitHub as our repository so that you get the benefits of version control.

This environment will be the basis of the remaining labs in the workshop, so no need to blow it away at the end of the lab!

## Creating a GitHub repository

Git is the dominant source code management (SCM) platform in use today.  It is an open source project created by Linus Torvalds, the creator of the Linux kernel. Many organisations host their own private Git repositories, including Microsoft.  (Microsoft contributed to the Git source code to extend the underlying filesystem in order to host the Windows source code.)

You will create a free public terraform repository on GitHub.  GitHub is the largest host of open source code in thed.a world.  (This documentation is also hosted on a GitHub repository.)

For this lab you will need to have

* [Git](https://git-scm.com/downloads) installed locally
* Ensure the git executable is in the path
    * type `git` in PowerShell or Command Prompt on Windows
    * type `git` in the terminal for Linux or MacOS
* Check Visual Studio Code (vscode)
    * Support for Git is integrated and in-the-box
    * Click on the Source Control icon on the left (CTRL+SHIFT+G)
    * The top of the main pane should display "SOURCE CONTROL: GIT"
* A [GitHub](https://github.com/join) account

OK, let's create our repository:

![New Repository](/workshops/terraform/images/newRepo.png)

* Click on the `+` at the top right and 'New repository'
    * Name: **citadel-terraform**
    * Description: leave blank
    * **Public** (default)
    * Tick the **Initialize this repository with a README** check box
    * Create repository
* Click on the green **Clone or download** button
* Copy the repository URL, which should be similar to `https://github.com/<githubUsername>/citadel-terraform.git`

![Repository URL](/workshops/terraform/images/repoUrl.png)

Clone the empty citadel-terraform repository into vscode:

* Open vscode
* Type CTRL-SHIFT-P to open the Command Palette
* Type `clone` and select **Git: Clone**
* Paste the repository URL and hit enter
* Select the repository location for the clone
* Once cloned you should see a toast notification
* Click Open Repository

![Toast Notification](/workshops/terraform/images/toast.png)

Now that you have cloned the repository locally, your local repository will have an 'origin' upstream configured, which is a link back to the original GitHub repository.  As you make changes you can commit those to your local repository and then push them upstream to GitHub.

Let's check that process by modifying the README.md, committing the change and then pushing it upstream:

<video video width="800" height="400" controls>
    <source type="video/mp4" src="/workshops/terraform/images/stageCommitPush.mp4"></source>
    <p>Your browser does not support the video element.</p>
</video>

* Edit the README.md file in vscode
* Add in the following text: `Lab files for https://aka.ms/citadel/terraform workshop.`
* Save the change
* Click on the Git icon to bring up the SCM area
* Hover over the README.md filename and click on the `+` to stage
* Type in a commit message, e.g. Updated description
* Click on the `✓` to commit
* Push up to the 'origin' GitHub by either
    * clicking on the arrows in the status bar to refresh (both push and pull), or
    * clicking on the ellipsis (`...`) in the SCM area and `Push` from the context menu
* Once the push has completed then go back into GitHub (`https://github.com/\<githubUsername>/citadel-terraform`) and refresh
* Confirm the README file now shows your committed change

![GitHub](/workshops/terraform/images/github.png)

OK, so we can save locally and push into Cloud Shell as we move through the lab.  Don't forget to periodically commit your changes locally and push them up into your GitHub repository.

## AzureRM Provider documentation

The main documentation area for the Terraform azurerm provider is on the Terraform site itself.  Use this short URL to access it quickly:

[**aka.ms/terraform**](https://aka.ms/terraform){:target="_blank" class="btn-info"}

In this lab we will be creating the following as part of our core environment:

* Virtual Network with three subnets
* VPN Gateway in the GatewaySubnet
* Network Security Groups
* Key Vault

Browse the documentation pages for the various provider types.  Note that the index on the left lists out the **Provider** and the **Data Sources** first.  The various **Resources** are then listed underneath.

## Organising your .tf files

As we found in the last lab, Terraform will merge together all of the *.tf files in the current working directory, ignoring any files which have a different file extension.  By design, Terraform does not recursively walk the directory structure, so any *.tf files in sub-directories will not be considered.

This provides an opportunity to think about how you would organise your files to suit your purposes.

Some admins prefer to have all of the Terraform stanzas in a single and often very large .tf file, often called `main.tf`.

Some prefer to split out certain top level keywords, e.g.:

```bash
$ ls
main.tf
outputs.tf
variables.tf
```

Others prefer to break out by service or groups of service, e.g.:

```bash
$ ls
instances.tf
load-balancers.tf
shared.tf
```

You may decide how you want to structure your files.  This lab will assume that the variables are in their own variables.tf file, and then we'll essentially have a file per resource group:

```bash
$ ls
core.tf
keyvaults.tf
nsgs.tf
variables.tf
```

The Core resource group will contain our core networking, i.e. the virtual network, three subnets (inside, outside and GatewaySubnet) and VPN gateway.

The NSGs resource group will contain a group of simple predefined NSGs:

NSG Name | Protocol | Port
AllowSSH | TCP | 22
AllowHTTP | TCP | 80
AllowHTTPS | TCP | 443
AllowSQLServer | TCP | 1443
AllowRDP | TCP | 3389

Finally the KeyVaults resource group will contain an Azure Key Vault to store our secrets and keys.

## Initial variables.tf

* Create a variables.tf file
* Add in the following variables

```ruby
variable "loc" {
    description = "Default Azure region"
    default     =   "West Europe"
}

variable "tags" {
    default     = {
        source  = "citadel"
        env     = "training"
    }
}
```

We'll add to that file as we move through the lab.

## NSGs

OK, let's start with the NSGs.  We will hardcode these from the name of the resource group to the names of the NSGs and the security rules within them.

* Create an nsgs.tf
* Add in the following text

```ruby
resource "azurerm_resource_group" "nsgs" {
   name         = "NSGs"
   location     = "${var.loc}"
   tags         = "${var.tags}"
}

resource "azurerm_network_security_group" "AllowSSH" {
   name = "AllowSSH"
   resource_group_name  = "${azurerm_resource_group.nsgs.name}"
   location             = "${azurerm_resource_group.nsgs.location}"
   tags                 = "${azurerm_resource_group.nsgs.tags}"
}

resource "azurerm_network_security_rule" "AllowSSH" {
    name = "AllowSSH"
    resource_group_name         = "${azurerm_resource_group.nsgs.name}"
    network_security_group_name = "${azurerm_network_security_group.AllowSSH.name}"

    priority                    = 1001
    access                      = "Allow"
    direction                   = "Inbound"
    protocol                    = "Tcp"
    destination_port_range      = 22
    destination_address_prefix  = "*"
    source_port_range           = "*"
    source_address_prefix       = "*"
}

resource "azurerm_network_security_group" "AllowHTTP" {
   name = "AllowHTTP"
   resource_group_name  = "${azurerm_resource_group.nsgs.name}"
   location             = "${azurerm_resource_group.nsgs.location}"
   tags                 = "${azurerm_resource_group.nsgs.tags}"
}

resource "azurerm_network_security_rule" "AllowHTTP" {
    name = "AllowHTTP"
    resource_group_name         = "${azurerm_resource_group.nsgs.name}"
    network_security_group_name = "${azurerm_network_security_group.AllowHTTP.name}"

    priority                    = 1001
    access                      = "Allow"
    direction                   = "Inbound"
    protocol                    = "Tcp"
    destination_port_range      = 80
    destination_address_prefix  = "*"
    source_port_range           = "*"
    source_address_prefix       = "*"
}

resource "azurerm_network_security_group" "AllowHTTPS" {
   name = "AllowHTTPS"
   resource_group_name  = "${azurerm_resource_group.nsgs.name}"
   location             = "${azurerm_resource_group.nsgs.location}"
   tags                 = "${azurerm_resource_group.nsgs.tags}"
}

resource "azurerm_network_security_rule" "AllowHTTPS" {
    name = "AllowHTTPS"
    resource_group_name         = "${azurerm_resource_group.nsgs.name}"
    network_security_group_name = "${azurerm_network_security_group.AllowHTTPS.name}"

    priority                    = 1001
    access                      = "Allow"
    direction                   = "Inbound"
    protocol                    = "Tcp"
    destination_port_range      = 443
    destination_address_prefix  = "*"
    source_port_range           = "*"
    source_address_prefix       = "*"
}
```

Note that 

* Save the file
* Push to Cloud Shell
* Run through the init -> plan -> apply workflow
* Check your new NSGs resource group in the [portal](https://portal.azure.com)
* Update the nsgs.tf with the remaining NSGs

NSG Name | Protocol | Port
AllowSQLServer | TCP | 1443
AllowRDP | TCP | 3389

* Rerun the plan -> apply workflow

## Azure Key Vault

We will also hard code the default key vault.  There are a few core services that we want to be able to assume when we are creating the more flexible Terraform files in the later labs.

* Create a keyvaults.tf
* Add in the resource group stanza 
    * Name: **KeyVaults**
    * Use the variables for location and tags

It is up to you how you do that.  You may either:

* Copy out an example resource group stanza from the <https://aka.ms/terraform> documentation
* Copy and modify the resource group stanza from your nsgs.tf file
* Use the snippets from the extension - type "tf-azurerm_res..." and then use cursor keys and tab to use the right snippet

YOU ARE HERE - ADD IN THE KEY VAULT AS THAT IS MORE COMPLICATED THAN I THOUGHT

## End of Lab 3

We have reached the end of the lab. You have started to use GitHub and work with multiple resource groups, resources and .tf files.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab3>, although you may have spread your Terraform stanzas across your .tf files differently dependent on how you have it organised.

In the next lab we will look at some of the meta parameters that you can use in Terraform to gain richer functionality.

[◄ Lab 2: Variables](../lab2){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 4: Metas ►](../lab4){: .btn-success}