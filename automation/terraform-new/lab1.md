---
title: "Terraform Basics"
categories: null
date: 2020-02-01
author: Richard Cheney
category: automation
comments: true
featured: false
hidden: true
tags: [terraform]
header:
  overlay_image: images/header/terraform.png
  teaser: images/teaser/terraformlogo.png
sidebar:
  nav: "terraform"
excerpt: Create .tf files and run through the basic Terraform workflow
---

## Introduction

> These labs have been updated  for 0.12 compliant HCL. If you were working through the original set of labs then go to [Terraform on Azure - Pre 0.12](/automation/terraform-pre012).

This is a short and simple lab to introduce you to the Terraform workflow and HCL file format.  Everything will be run within the bash version of the Azure Cloud Shell which already has Terraform installed and maintained for you, so all you need for this lab is an active Azure subscription.

There are three ways of authenticating the Terraform provider to Azure:

1. Azure CLI
2. Managed System Identity (MSI)
3. Service Principals

This lab will be run within Cloud Shell.  Cloud Shell runs on a small linux container (the image is held on DockerHub) and uses MSI to authenticate.  Essentially the whole container is authenticated using your credentials and Terraform leverages MSI. We will move through the other authentication types during the course of the labs and will discuss the use cases for each.

Once you have started your Cloud Shell session you will be automatically logged in to Azure.  Terraform makes use of that authentication and context, so you will be good to go.

## Getting started

Open up an Azure Cloud Shell.  You can do this from within the portal by clicking on the **`>_`** icon at the top, but for an (almost) full screen Cloud Shell session then open up a new tab and go to <https://shell.azure.com>.

1. Show the account details for the subscription

    ```bash
    az account show --output jsonc
    ```

    Example output:

    ```json
    {
      "environmentName": "AzureCloud",
      "id": "2d31be49-d959-4415-bb65-8aec2c90ba62",
      "isDefault": true,
      "name": "Visual Studio (richeney)",
      "state": "Enabled",
      "tenantId": "f246eeb7-b820-4971-a083-9e100e084ed0",
      "user": {
        "cloudShellID": true,
        "name": "richeney@azurecitadel.com",
        "type": "user"
      }
    }
    ```

    If you have multiple subscriptions then you can switch using `az account list --output table` and `az account set --subscription <subscriptionId>`.  If you are doing that regularly then you may want to add an alias to the bottom of your ~/.bashrc file, e.g. `alias vs='az account set --subscription <subscriptionId>; az account show'`.

1. Type `terraform` to see the main help page

    ```bash
    terraform
    ```

    Example output:

    ```yaml
    Usage: terraform [-version] [-help] <command> [args]

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
        refresh            Update local state file against real resources
        show               Inspect Terraform state or plan
        taint              Manually mark a resource for recreation
        untaint            Manually unmark a resource as tainted
        validate           Validates the Terraform files
        version            Prints the Terraform version
        workspace          Workspace management

    All other commands:
        0.12upgrade        Rewrites pre-0.12 module source code for v0.12
        debug              Debug output management (experimental)
        force-unlock       Manually unlock the terraform state
        push               Obsolete command for Terraform Enterprise legacy (v1)
        state              Advanced state management
    ```

## Create a simple main.tf file

Terraform uses its own file format, called HCL (Hashicorp Configuration Language).  This is very similar to YAML.  We'll create a main.tf file with a resource group and storage account:

1. Create a terraform-labs directory in your home directory

    ```bash
    mkdir terraform-labs
    ```

1. Change to the new directory

    ```bash
    cd terraform-labs
    ```

1. Create an empty main.tf file

    ```bash
    touch main.tf
    ```

1. Copy the text from the codeblock below

    ```hcl
    provider "azurerm" {
      version = "~> 1.42.0"
    }

    resource "azurerm_resource_group" "lab1" {
      name     = "terraform-lab1"
      location = "West Europe"
      tags = {
        environment = "training"
      }
    }

    resource "azurerm_storage_account" "lab1sa" {
      name                      = "richeneyterraformlab1"
      resource_group_name       =  azurerm_resource_group.lab1.name
      location                  =  azurerm_resource_group.lab1.location

      account_kind              = "StorageV2"
      account_tier              = "Standard"
      account_replication_type  = "LRS"
      access_tier               = "Cool"
    }
    ```

1. Start vscode in the Cloud Shell

    ```bash
    code .
    ```

    > Strictly speaking this is the Monaco Editor, which is the open source web-based editor that powers Visual Studio Code

1. Click on the main.tf file in the explorer pane
1. Click in the right hand pane to get focus
1. Paste in the contents of the clipboard (`CTRL`+`V`)
1. Change the storage account name ('richeneyterraformlab1') to something unique
    * Storage is a PaaS service with a public endpoint
    * The storage account name forms part of the FQDN, and needs to be globally unique

    ![monaco](/automation/terraform/images/monaco.png)

1. Save the file (`CTRL`+`S`)
    * The round dot on the file name tab denotes unsaved changes

    ----------

    Let's first look more closely at the second resource block (or stanza) for the **storage account**.

    The Terraform top level **keyword** is `resource`. We'll cover the various top level keywords as we go through the labs.

    The next value, `azurerm_storage_account`, is the **resource type**.  Resource types are always prefixed with the provider, which is azurerm in this case. You can have multiple resources of the same type in a Terraform configuration, and they can make use of different providers.

    The next value, `lab1sa`, is the Terraform **resource id**. These are used within Terraform's graph database of dependencies, and so the combination of resource type and id (`azurerm_storage_account.lab1sa`) must be unique. Therefore if you had multiple Azure storage accounts then they would require different ids.  If you had different resource types then they could have the same id shortnames as the resource type and id combination would still be unique. The ids can be comprised of alphanumerics, underscores or dashes.

    The key-value pairs within the curly braces are the arguments. Note that the indentation is very important in HCL.  A list of key-value pairs is called a map.  (You may be used to calling them dictionaries, hashes or objects, depending on your point of reference.) Note the lack of commas in the list - again this is not required in standard HCL.

    Most of the values are standard strings, except for the storage account resource group name and location. The name is set to `azurerm_resource_group.lab1.name` with out strings.  This is a first class expression, referring back to the value of the resource group name from the stanza above using a direct expression. (This will always set the value of the resource group argument for the storage account to the value defined in the resource group resource stanza above, i.e. 'terraform-lab1'.) We are doing exactly the same with the location, ensuring that the storage account will always be deployed into the same region as the resource group metadata.

    > Note that prior to Terraform 0.12 that such expressions had to use the string interpolation syntax, e.g. `"$    {azurerm_resource_group.lab1.name}"`

    Using the reference to the other resource also sets an implicit dependency, so that Terraform understands that the storage account should only be created once the resource group exists.

    ----------

1. Close the vscode pane (`CTRL`+`Q`)

----------

## The Terraform workflow

The main Terraform workflow is shown below:

![Terraform Workflow](/automation/terraform/images/terraform.png)

Let's step through it.

## - terraform init

The `terraform init` command looks through all of the *.tf files in the current working directory and automatically downloads any of the providers required for them.  Run it now.

1. Initialise Terraform

    ```bash
    terraform init
    ```

    Example output:

    ```yaml

    Initializing the backend...

    Initializing provider plugins...
    - Checking for available provider plugins...
    - Downloading plugin for provider "azurerm" (hashicorp/azurerm) 1.42.0...

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

1. List out all of the files in the current directory

    ```bash
    find .
    ```

    Example output:

    ```text
    .
    ./.terraform
    ./.terraform/plugins
    ./.terraform/plugins/linux_amd64
    ./.terraform/plugins/linux_amd64/lock.json
    ./.terraform/plugins/linux_amd64/terraform-provider-azurerm_v1.42.0_x4
    ./main.tf
    ```

    As you can see it has downloaded the provider.azurerm into the `.terraform/plugins` area which we specified in out main.tf file.  The azurerm_resource_group and azurerm_storage_account are both resource types within the azurerm Terraform provider.

## - terraform plan

1. Run `terraform plan`

    ```bash
    terraform plan
    ```

    Example output:

    ```json
    Refreshing Terraform state in-memory prior to plan...
    The refreshed state will be used to calculate this plan, but will not be
    persisted to local or remote state storage.


    ------------------------------------------------------------------------

    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create

    Terraform will perform the following actions:

      # azurerm_resource_group.lab1 will be created
      + resource "azurerm_resource_group" "lab1" {
          + id       = (known after apply)
          + location = "westeurope"
          + name     = "terraform-lab1"
          + tags     = {
              + "environment" = "training"
            }
        }

      # azurerm_storage_account.lab1sa will be created
      + resource "azurerm_storage_account" "lab1sa" {
          + access_tier                       = (known after apply)
          + account_encryption_source         = "Microsoft.Storage"
          + account_kind                      = "Storage"
          + account_replication_type          = "LRS"
          + account_tier                      = "Standard"
          + account_type                      = (known after apply)
          + enable_advanced_threat_protection = (known after apply)
          + enable_blob_encryption            = true
          + enable_file_encryption            = true
          + id                                = (known after apply)
          + is_hns_enabled                    = false
          + location                          = "westeurope"
          + name                              = "richeneytfstoracct"
          + primary_access_key                = (sensitive value)
          + primary_blob_connection_string    = (sensitive value)
          + primary_blob_endpoint             = (known after apply)
          + primary_blob_host                 = (known after apply)
          + primary_connection_string         = (sensitive value)
          + primary_dfs_endpoint              = (known after apply)
          + primary_dfs_host                  = (known after apply)
          + primary_file_endpoint             = (known after apply)
          + primary_file_host                 = (known after apply)
          + primary_location                  = (known after apply)
          + primary_queue_endpoint            = (known after apply)
          + primary_queue_host                = (known after apply)
          + primary_table_endpoint            = (known after apply)
          + primary_table_host                = (known after apply)
          + primary_web_endpoint              = (known after apply)
          + primary_web_host                  = (known after apply)
          + resource_group_name               = "terraform-lab1"
          + secondary_access_key              = (sensitive value)
          + secondary_blob_connection_string  = (sensitive value)
          + secondary_blob_endpoint           = (known after apply)
          + secondary_blob_host               = (known after apply)
          + secondary_connection_string       = (sensitive value)
          + secondary_dfs_endpoint            = (known after apply)
          + secondary_dfs_host                = (known after apply)
          + secondary_file_endpoint           = (known after apply)
          + secondary_file_host               = (known after apply)
          + secondary_location                = (known after apply)
          + secondary_queue_endpoint          = (known after apply)
          + secondary_queue_host              = (known after apply)
          + secondary_table_endpoint          = (known after apply)
          + secondary_table_host              = (known after apply)
          + secondary_web_endpoint            = (known after apply)
          + secondary_web_host                = (known after apply)
          + tags                              = (known after apply)

          + blob_properties {
              + delete_retention_policy {
                  + days = (known after apply)
                }
            }

          + identity {
              + principal_id = (known after apply)
              + tenant_id    = (known after apply)
              + type         = (known after apply)
            }

          + network_rules {
              + bypass                     = (known after apply)
              + default_action             = (known after apply)
              + ip_rules                   = (known after apply)
              + virtual_network_subnet_ids = (known after apply)
            }

          + queue_properties {
              + cors_rule {
                  + allowed_headers    = (known after apply)
                  + allowed_methods    = (known after apply)
                  + allowed_origins    = (known after apply)
                  + exposed_headers    = (known after apply)
                  + max_age_in_seconds = (known after apply)
                }

              + hour_metrics {
                  + enabled               = (known after apply)
                  + include_apis          = (known after apply)
                  + retention_policy_days = (known after apply)
                  + version               = (known after apply)
                }

              + logging {
                  + delete                = (known after apply)
                  + read                  = (known after apply)
                  + retention_policy_days = (known after apply)
                  + version               = (known after apply)
                  + write                 = (known after apply)
                }

              + minute_metrics {
                  + enabled               = (known after apply)
                  + include_apis          = (known after apply)
                  + retention_policy_days = (known after apply)
                  + version               = (known after apply)
                }
            }
        }

    Plan: 2 to add, 0 to change, 0 to destroy.

    ------------------------------------------------------------------------

    Note: You didn't specify an "-out" parameter to save this plan, so Terraform
    can't guarantee that exactly these actions will be performed if
    "terraform apply" is subsequently run.
    ```

    This is a dry run and shows which actions will be made.  This allows manual verification of the changes before running the apply step.

## - terraform apply

Run the `terraform apply` command to deploy the resources.

1. Run `terraform apply`

    ```bash
    terraform apply
    ```

    You will see the same output as the `terraform plan` command, but will also be prompted for confirmation that you want to apply those changes.

1. Answer `yes` to the prompt to start the actual provisioning.

    > If you do not want to be prompted then you can use `terraform apply -auto-approve`, although this is definitely not recommended fo production environments!

    Example output:

    ```yml
    Plan: 2 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.

      Enter a value: yes

    azurerm_resource_group.lab1: Creating...
    azurerm_resource_group.lab1: Creation complete after 1s [id=/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/terraform-lab1]
    azurerm_storage_account.lab1sa: Creating...
    azurerm_storage_account.lab1sa: Still creating... [10s elapsed]
    azurerm_storage_account.lab1sa: Still creating... [20s elapsed]
    azurerm_storage_account.lab1sa: Creation complete after 26s [id=/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/terraform-lab1/providers/Microsoft.Storage/storageAccounts/richeneytfstoracct]
    ```

    The resource group and the storage account have been successfully deployed.

1. List the resources

    ```bash
    az resource list --resource-group terraform-lab1 --output table
    ```

    Example output:

    ```yml
    Name                ResourceGroup    Location    Type                               Status
    ------------------  ---------------  ----------  ---------------------------------  --------
    richeneytfstoracct  terraform-lab1   westeurope  Microsoft.Storage/storageAccounts
    ```

## - terraform destroy

Clean up the resources by using the `terraform destroy` command.  The command will let you know what you are about to remove and then prompt you for confirmation.

1. Run `terraform destroy`

    ```bash
    terraform destroy
    ```

    Example output:

    ```go
    azurerm_resource_group.lab1: Refreshing state... [id=/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroup            s/terraform-lab1]
    azurerm_storage_account.lab1sa: Refreshing state... [id=/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGr            oups/terraform-lab1/providers/Microsoft.Storage/storageAccounts/richeneytfstoracct]

    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      - destroy

    Terraform will perform the following actions:

      # azurerm_resource_group.lab1 will be destroyed
      - resource "azurerm_resource_group" "lab1" {
          - id       = "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/terraform-lab1" -> null                          - location = "westeurope" -> null
          - name     = "terraform-lab1" -> null
          - tags     = {
              - "environment" = "training"
            } -> null
        }

      # azurerm_storage_account.lab1sa will be destroyed
      - resource "azurerm_storage_account" "lab1sa" {
          - account_encryption_source         = "Microsoft.Storage" -> null
          - account_kind                      = "Storage" -> null
          - account_replication_type          = "LRS" -> null
          - account_tier                      = "Standard" -> null
          - account_type                      = "Standard_LRS" -> null
          - enable_advanced_threat_protection = false -> null
          - enable_blob_encryption            = true -> null
          - enable_file_encryption            = true -> null
          - enable_https_traffic_only         = false -> null
          - id                                = "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/terraf            orm-lab1/providers/Microsoft.Storage/storageAccounts/richeneytfstoracct" -> null
          - is_hns_enabled                    = false -> null
          - location                          = "westeurope" -> null
          - name                              = "richeneytfstoracct" -> null
          - primary_access_key                = (sensitive value)
          - primary_blob_connection_string    = (sensitive value)
          - primary_blob_endpoint             = "https://richeneytfstoracct.blob.core.windows.net/" -> null
          - primary_blob_host                 = "richeneytfstoracct.blob.core.windows.net" -> null
          - primary_connection_string         = (sensitive value)
          - primary_file_endpoint             = "https://richeneytfstoracct.file.core.windows.net/" -> null
          - primary_file_host                 = "richeneytfstoracct.file.core.windows.net" -> null
          - primary_location                  = "westeurope" -> null
          - primary_queue_endpoint            = "https://richeneytfstoracct.queue.core.windows.net/" -> null
          - primary_queue_host                = "richeneytfstoracct.queue.core.windows.net" -> null
          - primary_table_endpoint            = "https://richeneytfstoracct.table.core.windows.net/" -> null
          - primary_table_host                = "richeneytfstoracct.table.core.windows.net" -> null
          - resource_group_name               = "terraform-lab1" -> null
          - secondary_access_key              = (sensitive value)
          - secondary_connection_string       = (sensitive value)
          - tags                              = {
              - "Application" = ""
              - "Costcode"    = ""
              - "Department"  = ""
              - "Downtime"    = "Tuesday, 04:00-04:30"
              - "Environment" = "Test"
              - "Owner"       = ""
            } -> null

          - blob_properties {
            }

          - network_rules {
              - bypass                     = [
                  - "AzureServices",
                ] -> null
              - default_action             = "Allow" -> null
              - ip_rules                   = [] -> null
              - virtual_network_subnet_ids = [] -> null
            }

          - queue_properties {

              - hour_metrics {
                  - enabled               = true -> null
                  - include_apis          = true -> null
                  - retention_policy_days = 7 -> null
                  - version               = "1.0" -> null
                }

              - logging {
                  - delete                = false -> null
                  - read                  = false -> null
                  - retention_policy_days = 0 -> null
                  - version               = "1.0" -> null
                  - write                 = false -> null
                }

              - minute_metrics {
                  - enabled               = false -> null
                  - include_apis          = false -> null
                  - retention_policy_days = 0 -> null
                  - version               = "1.0" -> null
                }
            }
        }

    Plan: 0 to add, 0 to change, 2 to destroy.

    Do you really want to destroy all resources?
      Terraform will destroy all your managed infrastructure, as shown above.
      There is no undo. Only 'yes' will be accepted to confirm.

      Enter a value:
    ```

1. Enter `yes`

    ```go
      Enter a value: yes

    azurerm_storage_account.lab1sa: Destroying... [id=/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/terraform-lab1/providers/Microsoft.Storage/storageAccounts/richeneytfstoracct]
    azurerm_storage_account.lab1sa: Destruction complete after 1s
    azurerm_resource_group.lab1: Destroying... [id=/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/terraform-lab1] azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/2d31be49-d999-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1, 10s elapsed]
    azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/2d31be49-d999-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1, 20s elapsed]
    azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/2d31be49-d999-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1, 30s elapsed]
    azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/2d31be49-d999-4415-bb65-...2c90ba62/resourceGroups/terraform-lab1, 40s elapsed]
    azurerm_resource_group.lab1: Destruction complete after 46s

    Destroy complete! Resources: 2 destroyed.
    ```

    > **WARNING** If there are other resources in a Terraform managed resource group then the destroy will remove these as well.

1. Rerun the resource list command to confirm that the resources have been removed

    ```bash
    az resource list --resource-group terraform-lab1 --output table
    ```

    Expected output:

    ```bash
    Resource group 'terraform-lab1' could not be found.
    ```

## End of Lab 1

We have reached the end of the lab. You have learned some basics about Terraform HCL files, and gone through the standard Terraform workflow for creating and destroying Azure resources.

Your main.tf file should look similar to the main.tf file in <https://github.com/richeney/terraform-lab1>.

In the next lab we will introduce variables, use multiple .tf files, and we'll add and modify to our resources. Click on the right arrow to move to the next lab.

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: Variables ►](../lab2){: .btn .btn--primary}