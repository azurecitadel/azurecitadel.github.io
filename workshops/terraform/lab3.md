---
layout: article
title: "Terraform Lab 3: Core Environment"
categories: null
date: 2018-06-05
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

Steps:

* Save the file
* Push to Cloud Shell
* Run through the init -> plan -> apply workflow
* Check your new NSGs resource group in the [portal](https://portal.azure.com)
* Update the nsgs.tf with the remaining NSGs

NSG Name | Protocol | Port
AllowSQLServer | TCP | 1443
AllowRDP | TCP | 3389

* Rerun the plan -> apply workflow

## Core networking

OK, time for you to get a little self sufficient and create a coreNetwork.tf file for our core networking.  You will need to find the right resouirce types in the <https://aka.ms/terraform> documentation area. You may also make use of the snippets that came with one of the modules. Type `CTRL-SPACE` and then type tf-azurerm_resource_group to get an example snippet copied into your file.  The snippets do not cover all resource types - for instance the azurerm_virtual_network_gateway is not currently in the set - but can be useful in quickly creating .tf files.

* Create a coreNetwork.tf file containing:
    * Resource Group
        * Name: **core**
        * Location: use the **loc** variable
        * Tags: use the **tags** variable
    * _Match the Terraform id to the ARM resource name unless specified otherwise_
    * _Ensure all following resources are in this resource group and inherit the tags and location_
    * Public IP
        * Name: **vpnGatewayPublicIp**
        * Dynamically allocated
    * Virtual Network
        * Name: **core**
        * Address space: **10.0.0.0/16**
        * DNS servers: **1.1.1.1** & **1.0.0.1** (the Cloudflare public DNS servers)
    * Subnets
        * GatewaySubnet: **10.0.0.0/24**
        * training: **10.0.1.0/24**
        * dev: **10.0.2.0/24**
    * VPN Gateway
        * Name: **vpnGateway**
        * Route based VPN on the basic SKU
        * BGP should be enabled
        * IP Configuration:
            * Name: **vpnGwConfig1**
            * Use the Public IP
            * Use a dynamically allocated private IP
        * Use the GatewaySubnet

If you get stuck then the bottom of this lab has a link to a set of files that you can reference.  Visual Studio Code also has a very good compare tool.

* Run through the terraform init, plan and apply workflow
* Save and commit your files

Note that the VPN gateway will take several minutes to build, especially on free accounts that have a lower execution priority. A good opportunity for a coffee...

## Azure Key Vault

We will also hard code a default key vault.  There are a few core services that we want to be able to assume when we are creating the more flexible Terraform files in the later labs, amd Key Vault is one of them.  It also give us an opportunity to introduce service principals, role assigments and scopes.

> Note that if you are an organisation looking to centralise your key and secret management whilst using multiple Terraform cloud providers then  Hashicorp has an excellent product called [Vault](https://www.vaultproject.io/).  Use of Vault is outside the scope of these labs.

We're going to need a service principal (sp) that has permissions to read the Azure Key Vault.  If you look at the [azurerm_key_vault](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html) page then you'll see we need to specify a tenant_id and an object_id.

The creation of service principals from Terraform is a current [enhancement request](https://github.com/terraform-providers/terraform-provider-azurerm/issues/16), so in the meantime we'll create the service principal via the CLI and use the tenant ID and object ID values in a couple of new Terraform variables.  

Note that by default, service principals are created with Contributor role assigned to the root of the subscription, which is far more generous than we want.  We'll therefore initially set it to no role assignment.  We'll then use Terraform to assign a valid role against the keyVaults resource group once that has been created.

### Create a service principal

* Create a service principal with no role assignment

```bash
az ad sp create-for-rbac --name "terraformKeyVaultReader" --skip-assignment
```

Note that the service principal (or sp) name must be unique within the tenancy for this command to succeed.  You can also specify a password using `--password`, but if not then the command will generate one for you and show it in the output.  Note in the output that the sp name is prefixed with `http://`, so if you were to delete the sp then the command would be `az ad sp delete --id "http://terraformKeyVaultReader"`.

If you run the following command it will query the new sp and give us the values we need for our variables.

```bash
az ad sp show --id "http://terraformKeyVaultReader" --output jsonc --query "{tenant_id:appOwnerTenantId, object_id:objectId}"
{
  "object_id": "6aee7885-a16d-4448-aeca-3788aafda778",
  "tenant_id": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

* Create the two new variables in the variables.tf file
    * **object_id**
    * **tenant_id**

We'll now use these new variables when creating the Key Vault.

### Create the keyvaults.tf

* Create a new keyVaults.tf file

```bash
resource "azurerm_resource_group" "keyvaults" {
    name        = "keyVaults"
    location    = "${var.loc}"
    tags        = "${var.tags}"
}

resource "azurerm_role_assignment" "keyVaultReader" {
  role_definition_name = "Reader"
  scope                = "${azurerm_resource_group.keyvaults.id}"
  principal_id         = "${var.object_id}"
}

resource "azurerm_key_vault" "default" {
    name                = "keyVault"
    resource_group_name = "${azurerm_resource_group.keyvaults.name}"
    location            = "${azurerm_resource_group.keyvaults.location}"
    tags                = "${azurerm_resource_group.keyvaults.tags}"

    depends_on          = [ "azurerm_role_assignment.keyVaultReader" ]

    sku {
        name = "standard"
    }

    tenant_id = "${var.tenant_id}"

    access_policy {
      tenant_id             = "${var.tenant_id}"
      object_id             = "${var.object_id}"
      key_permissions       = [ "get" ]
      secret_permissions    = [ "get" ]
    }
    enabled_for_deployment          = false # Azure Virtual Machines permitted to retrieve certs?
    enabled_for_template_deployment = false # ARM deployments allowed to pull secrets?
    enabled_for_disk_encryption     = true  # Azure Disk Encryptions permitted to grab secrets and unwrap keys ?
}
```

* Run through the terraform init, plan and apply workflow

The apply should fail on the keyvault resource as the keyVault name is already in use.  The key vault service creates a public endpoint, such as <https://{vault-name}.vault.azure.net> for the public cloud, and therefore the shortname needs to be unique.

* Create a new **rndstr** resource using the random_string provider type
    * 12 characters
    * lowercase alphanumberics
* Append the result to the key vault name
* Rerun through the terraform init, plan and apply workflow to create the key vault

There are a few new things to note here:

1. There are implicit dependencies on the keyVaults resource group from both the role assigment and key vault resources
1. There is an explicit dependency on the role assignment from the key vault, using a **depends_on** array
1. There are comments against some of the key vault booleans

There are a couple of ways of commenting in HCL:

```tf
# This is a single line comment

/* And this is a multi line
comment */
```

Use the Azure [portal](http://portal.azure.com) to check the keyVaults resource group.  You should see the new key vault within it, but look at the Access Control (IAM) in the blade.  It should show the new service principal with the Reader role, similar to the filtered output below:

![Access Control](/workshops/terraform/images/accessControl.png)

Note that the Reader role is one of many inbuilt roles available.  You can also create custom roles via either the [CLI](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli#custom-roles) or [Terraform](https://www.terraform.io/docs/providers/azurerm/r/role_definition.html).

## End of Lab 3

We have reached the end of the lab. You have started to use GitHub and work with multiple resource groups, resources and .tf files. We also have a set of core resources that we will leverage in the following labs.

Your .tf files should look somewhat similar to those in <https://github.com/richeney/terraform-lab3>, although you may have spread your Terraform stanzas across your .tf files differently dependent on how you have it organised.

In the next lab we will look at some of the meta parameters that you can use in Terraform to gain richer functionality.

[◄ Lab 2: Variables](../lab2){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 4: Metas ►](../lab4){: .btn-success}