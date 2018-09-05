---
layout: article
title: "Terraform Lab 1: Basics"
categories: null
date: 2018-09-05
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

This is a short and simple lab to introduce you to the Terraform workflow and HCL file format.  Everything wil be run within the bash version of the Azure Cloud Shell which already has Terraform installed and maintained for you, so all you need for this lab is an active Azure subscription.

There are three ways of authenticating the Terraform provider to Azure:

1. Azure CLI
2. Managed System Identity (MSI)
3. Service Principals

This lab will be run within Cloud Shell.  Cloud Shell runs on a small linux container (the image is held on DockerHub) and uses MSI to authenticate.  Essentially the whole container is authenticated using your credentials and Terraform leverages MSI. We will move through the other authentication types during the course of the labs and will discuss the use cases for each.

Once you have started your Cloud Shell session you will be automatically logged in to Azure.  Terraform makes use of that authentication and context, so you will be good to go.

## Getting started

Open up an Azure Cloud Shell.  You can do this from within the portal by clicking on the **`>_`** icon at the top, but for an (almost) full screen Cloud Shell session then open up a new tab and go to <https://shell.azure.com>.

You can show the account details for the subscription using `az account show`:

```bash
richard@Azure:~$ az account show --output jsonc
{
  "environmentName": "AzureCloud",
  "id": "2d31be49-d999-4415-bb65-8aec2c90ba62",
  "isDefault": true,
  "name": "Visual Studio Enterprise",
  "state": "Enabled",
  "tenantId": "76f988bf-86f1-41af-91ab-2d7cd011db47",
  "user": {
    "cloudShellID": true,
    "name": "richeney@microsoft.com",
    "type": "user"
  }
}
```

If you have multiple subscriptions then you can switch using `az account list --output table` and `az account set --subscription <subscriptionId>`.  If you are doing that regularly then you may want to add an alias to the bottom of your ~/.bashrc file, e.g. `alias vs='az account set --subscription <subscriptionId>; az account show'`.

Type `terraform` to see the main help page:

```yaml
richard@Azure:~$ terraform
Usage: terraform [--version] [--help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.

Common commands:
    apply              Builds or changes infrastructure
    console            Interactive console for Terraform interpolations
    destroy            Destroy Terraform-managed infrastructure
    env                Workspace management
    fmt                Rewrites config files to canonical format
    get                Download and install modules for the configuration
    graph              Create a visual graph of Terraform resources
    import             Import existing infrastructure into Terraform
    init               Initialize a Terraform working directory
    output             Read an output from a state file
    plan               Generate and show an execution plan
    providers          Prints a tree of the providers used in the configuration
    push               Upload this Terraform module to Atlas to run
    refresh            Update local state file against real resources
    show               Inspect Terraform state or plan
    taint              Manually mark a resource for recreation
    untaint            Manually unmark a resource as tainted
    validate           Validates the Terraform files
    version            Prints the Terraform version
    workspace          Workspace management

All other commands:
    debug              Debug output management (experimental)
    force-unlock       Manually unlock the terraform state
    state              Advanced state management
```

## Create a simple main.tf file

Terraform uses its own file format, called HCL (Hashicorp Configuration Language).  This is very similar to YAML.  We'll create a main.tf file with a resource group and storage account:

* Copy the text from the codeblock below

```ruby
resource "azurerm_resource_group" "lab1" {
  name     = "terraform-lab1"
  location = "West Europe"

  tags {
    environment = "training"
  }
}

resource "azurerm_storage_account" "lab1sa" {
  name                     = "richeneyterraformlab1"
  resource_group_name      = "${azurerm_resource_group.lab1.name}"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

* Create a terraform-labs directory in your home directory (`mkdir terraform-labs`)
* Change to the new directory (`cd terraform-labs`)
* Create an empty main.tf file (`touch main.tf`)
* Start vscode in the Cloud Shell (`code .`)
* Click on the main.tf file in the explorer pane
* Paste in the contents of the clipboard
* Change the storage account name ('richeneyterraformlab1') to something unique
    * Storage is a PaaS service with a public endpoint
    * The storage account name forms part of the FQDN, and needs to be globally unique
* Save the file (`CTRL`+`S`)
    * The round dot on the file name tab denotes unsaved changes

Let's look more closely at the resource block (or stanza) for the storage account.

The Terraform top level **keyword** is `resource`. We'll cover the various top level keywords as we go through the labs.

The next value, `azurerm_storage_account`, is the **resource type**.  Resource types are always prefixed with the provider, which is azurerm in this case. You can have multiple resources of the same type in a Terraform configuration, and they can make use of different providers.

The next value, `lab1sa`, is the Terraform **resource id**. These are used within Terraform's graph database of dependencies, and so the combination of resource type and id (`azurerm_storage_account.lab1sa`) must be unique.  Therefore if you had multiple Azure storage accounts then they would require different ids.  If you had different resource types then they could have the same id shortnames as the resource type and id combination would still be unique. The ids can be comprised of alphanumerics, underscores or dashes.

The key-value pairs within the curly braces are the arguments. Note that the indentation is very important in HCL.  A list of key-value pairs is called a map.  (You may be used to calling them dictionaries, hashes or objects, depending on your point of reference.) Note the lack of commas in the list - again this is not required in standard HCL.

Most of the values are standard strings, except for the storage account resource group name.  This uses interpolation, and will evaluate everything in between the dollar and curly braces: `${ ... }`.

Using `"${azurerm_resource_group.lab1.name}"` will set the value of the resource group name to match the resource group resource stanza above, i.e. 'terraform-lab1'.

Using the reference to the other resource also sets an implicit dependency, so that Terraform understands that the storage account should only be created once the resource group exists.

* Close the vscode pane (`CTRL`+`Q`)

----------

## The Terraform workflow

The main Terraform workflow is shown below:

![Terraform Workflow](/workshops/terraform/images/terraform.png)

Let's step through it.

## - terraform init

The `terraform init` command looks through all of the *.tf files in the current working directory and automatically downloads any of the providers required for them.  Run it now.

```yaml
richard@Azure:~/terraform-labs$ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "azurerm" (1.13.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.azurerm: version = "~> 1.13"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

As you can see it has downloaded the provider.azurerm which we specified in out main.tf file.  The azurerm_resource_group and azurerm_storage_account are both resource types within the azurerm Terraform provider.

* List out all of the files in the current directory (`find .`)

## - terraform plan

Run the `terraform plan`.

```yaml
richard@Azure:~/terraform-labs$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.lab1
      id:                               <computed>
      location:                         "westeurope"
      name:                             "terraform-lab1"
      tags.%:                           "1"
      tags.environment:                 "training"

  + azurerm_storage_account.lab1sa
      id:                               <computed>
      access_tier:                      <computed>
      account_encryption_source:        "Microsoft.Storage"
      account_kind:                     "Storage"
      account_replication_type:         "LRS"
      account_tier:                     "Standard"
      enable_blob_encryption:           "true"
      enable_file_encryption:           "true"
      identity.#:                       <computed>
      location:                         "westeurope"
      name:                             "richeneyterraformlab1"
      primary_access_key:               <computed>
      primary_blob_connection_string:   <computed>
      primary_blob_endpoint:            <computed>
      primary_connection_string:        <computed>
      primary_file_endpoint:            <computed>
      primary_location:                 <computed>
      primary_queue_endpoint:           <computed>
      primary_table_endpoint:           <computed>
      resource_group_name:              "terraform-lab1"
      secondary_access_key:             <computed>
      secondary_blob_connection_string: <computed>
      secondary_blob_endpoint:          <computed>
      secondary_connection_string:      <computed>
      secondary_location:               <computed>
      secondary_queue_endpoint:         <computed>
      secondary_table_endpoint:         <computed>
      tags.%:                           <computed>


Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

```

This is a dry run and shows which actions will be made.  This allows manual verification of the changes before going aheading and running the apply step.

## - terraform apply

Run the `terraform apply` command to deploy the resources.

You will see the same output as the `terraform plan` command, but will also be prompted for confirmation that you want to apply those changes.  Type `yes`.

```yaml
richard@Azure:~/terraform-labs$ terraform apply

:

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.lab1: Creating...
  location:         "" => "westeurope"
  name:             "" => "terraform-lab1"
  tags.%:           "" => "1"
  tags.environment: "" => "training"
azurerm_resource_group.lab1: Creation complete after 0s (ID: /subscriptions/2d31be49-d959-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1)
azurerm_storage_account.lab1sa: Creating...
  access_tier:                      "" => "<computed>"
  account_encryption_source:        "" => "Microsoft.Storage"
  account_kind:                     "" => "Storage"
  account_replication_type:         "" => "LRS"
  account_tier:                     "" => "Standard"
  enable_blob_encryption:           "" => "true"
  enable_file_encryption:           "" => "true"
  identity.#:                       "" => "<computed>"
  location:                         "" => "westeurope"
  name:                             "" => "richeneyterraformlab1"
  primary_access_key:               "<sensitive>" => "<sensitive>"
  primary_blob_connection_string:   "<sensitive>" => "<sensitive>"
  primary_blob_endpoint:            "" => "<computed>"
  primary_connection_string:        "<sensitive>" => "<sensitive>"
  primary_file_endpoint:            "" => "<computed>"
  primary_location:                 "" => "<computed>"
  primary_queue_endpoint:           "" => "<computed>"
  primary_table_endpoint:           "" => "<computed>"
  resource_group_name:              "" => "terraform-lab1"
  secondary_access_key:             "<sensitive>" => "<sensitive>"
  secondary_blob_connection_string: "<sensitive>" => "<sensitive>"
  secondary_blob_endpoint:          "" => "<computed>"
  secondary_connection_string:      "<sensitive>" => "<sensitive>"
  secondary_location:               "" => "<computed>"
  secondary_queue_endpoint:         "" => "<computed>"
  secondary_table_endpoint:         "" => "<computed>"
  tags.%:                           "" => "<computed>"
azurerm_storage_account.lab1sa: Still creating... (10s elapsed)
azurerm_storage_account.lab1sa: Creation complete after 19s (ID: /subscriptions/2d31be49-d959-4415-bb65-.../storageAccounts/richeneyterraformlab1)

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

The resource group and the storage account have been successfully deployed.

```bash
richard@Azure:~/terraform-labs$ az resource list --resource-group terraform-lab1 --output table
Name                   ResourceGroup    Location    Type                               Status
---------------------  ---------------  ----------  ---------------------------------  --------
richeneyterraformlab1  terraform-lab1   westeurope  Microsoft.Storage/storageAccounts
```

## - terraform destroy

Clean up the resources by using the `terraform destroy` command.  The command will let you know what you are about to remove and then prompt you for confirmation.

```yaml
richard@Azure:~/terraform-labs$ terraform destroy
azurerm_resource_group.lab1: Refreshing state... (ID: /subscriptions/2d31be49-d959-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1)
azurerm_storage_account.lab1sa: Refreshing state... (ID: /subscriptions/2d31be49-d959-4415-bb65-.../storageAccounts/richeneyterraformlab1)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - azurerm_resource_group.lab1

  - azurerm_storage_account.lab1sa


Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_storage_account.lab1sa: Destroying... (ID: /subscriptions/2d31be49-d959-4415-bb65-.../storageAccounts/richeneyterraformlab1)
azurerm_storage_account.lab1sa: Destruction complete after 0s
azurerm_resource_group.lab1: Destroying... (ID: /subscriptions/2d31be49-d959-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1)
azurerm_resource_group.lab1: Still destroying... (ID: /subscriptions/2d31be49-d959-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1, 10s elapsed)
azurerm_resource_group.lab1: Still destroying... (ID: /subscriptions/2d31be49-d959-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1, 20s elapsed)
azurerm_resource_group.lab1: Still destroying... (ID: /subscriptions/2d31be49-d959-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1, 30s elapsed)
azurerm_resource_group.lab1: Still destroying... (ID: /subscriptions/2d31be49-d959-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1, 40s elapsed)
azurerm_resource_group.lab1: Destruction complete after 46s

Destroy complete! Resources: 2 destroyed.
```

[**WARNING** If there are other resources in a Terraform managed resource group then the destroy will remove these as well.](){: .btn-warning}

Rerun the resouce list command to confirm that the resources have been removed:

```bash
richard@Azure:~/terraform-labs$ az resource list --resource-group terraform-lab1 --output table
Resource group 'terraform-lab1' could not be found.
```bash

## End of Lab 1

We have reached the end of the lab. You have learned some basics about Terraform HCL files, and gone through the standard Terraform workflow for creating and destroying Azure resources.

Your main.tf file should look similar to the main.tf file in <https://github.com/richeney/terraform-lab1>.

In the next lab we will introduce variables, use multiple .tf files, and we'll add and modify to our resources. Click on the right arrow to move to the next lab.

[▲ Index](../#labs){: .btn-subtle} [Lab 2: Variables ►](../lab2){: .btn-success}