---
title: "Terraform State"
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
excerpt: Configure remote state to use Azure Blob Storage, import existing resources under Terraform control and break remote state leases
---

## Introduction

> These labs have been updated soon for 0.12 compliant HCL. If you were working through the original set of labs then go to [Terraform on Azure - Pre 0.12](/automation/terraform-pre012).

In this lab we will go a little deeper in understanding the Terraform state file.

We will also look at how you can configure remote state to protect the local file and make it usable in an environment with multiple Terraform admins.

We will also cover locking (and how to remove leases on Azure blob storage), as well as refreshing the state and importing existing resources into the state.

## Overview

Terraform stores the state of your managed infrastructure from the last time Terraform was run.  The local file is called terraform.tfstate.

When you run `terraform plan` it will refresh an in memory copy of the state for the planning step.  Note that it won't save that updated state to disk.

```bash
terraform-labs$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

random_string.webapprnd: Refreshing state... (ID: brlvc8ak)
random_string.rndstr: Refreshing state... (ID: tu39fmjpgmcu)
```

When you run `terraform apply` then the state will be updated if changes have been made. The previous version will be saved as terraform.tfstate.backup.  (You can use compare tools such as sdiff or vscode's "Compare file with..." to see the changes in the JSON text files.)

You can initiate a refresh of the state by using `terraform state`.

Run `terraform state` to see the list of subcommands.

* `terraform state list` will list the resources in the state file
* `terraform state show <resourceTerraformId>` to display the status

```ruby
terraform-labs$ terraform state list | grep security
azurerm_network_security_group.AllowHTTP
azurerm_network_security_group.AllowHTTPS
azurerm_network_security_group.AllowRDP
azurerm_network_security_group.AllowSQLServer
azurerm_network_security_group.AllowSSH
azurerm_network_security_rule.AllowHTTP
azurerm_network_security_rule.AllowHTTPS
azurerm_network_security_rule.AllowRDP
azurerm_network_security_rule.AllowSQLServer
azurerm_network_security_rule.AllowSSH
terraform-labs$ terraform state show azurerm_network_security_rule.AllowHTTPS
id                             = /subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/NSGs/providers/Microsoft.Network/networkSecurityGroups/AllowHTTPS/securityRules/AllowHTTPS
access                         = Allow
description                    =
destination_address_prefix     = *
destination_address_prefixes.# = 0
destination_port_range         = 443
destination_port_ranges.#      = 0
direction                      = Inbound
name                           = AllowHTTPS
network_security_group_name    = AllowHTTPS
priority                       = 1001
protocol                       = Tcp
resource_group_name            = NSGs
source_address_prefix          = *
source_address_prefixes.#      = 0
source_port_range              = *
source_port_ranges.#           = 0
```

* `terraform state pull` will read the state file and send to stdout
    * pipe through to `jq` to filter the JSON output

```json
terraform-labs$ terraform state pull | jq '.modules[0].resources."azurerm_network_security_rule.AllowHTTPS"'
{
  "type": "azurerm_network_security_rule",
  "depends_on": [
    "azurerm_network_security_group.AllowHTTPS",
    "azurerm_resource_group.nsgs"
  ],
  "primary": {
    "id": "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/NSGs/providers/Microsoft.Network/networkSecurityGroups/AllowHTTPS/securityRules/AllowHTTPS",
    "attributes": {
      "access": "Allow",
      "description": "",
      "destination_address_prefix": "*",
      "destination_address_prefixes.#": "0",
      "destination_port_range": "443",
      "destination_port_ranges.#": "0",
      "direction": "Inbound",
      "id": "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/NSGs/providers/Microsoft.Network/networkSecurityGroups/AllowHTTPS/securityRules/AllowHTTPS",
      "name": "AllowHTTPS",
      "network_security_group_name": "AllowHTTPS",
      "priority": "1001",
      "protocol": "Tcp",
      "resource_group_name": "NSGs",
      "source_address_prefix": "*",
      "source_address_prefixes.#": "0",
      "source_port_range": "*",
      "source_port_ranges.#": "0"
    },
    "meta": {},
    "tainted": false
  },
  "deposed": [],
  "provider": "provider.azurerm"
}
```

There are a few more commands but we'll cover those later.

> Note that the state file can contain some sensitive data such as initial passwords, keys etc.  Limit access to the directory and read access to the file as appropriate.

## Remote state

Terraform enables you to configure a remote state location so that your local terraform.tfstate file is protected.  We will do this now for our local state file to back it off to Azure blob storage. Whenever state is updated then it will be saved both locally and remotely, and therefore adds a layer of protection.

In terms of terraform configuration we make use of the `terraform` high level keyword, and configure a backend stanza for the provider.  Below is an example:

```ruby
terraform {
  backend "azurerm" {
  storage_account_name = "terraformstatehco9vwseg1"
  container_name       = "tfstate"
  key                  = "2d31be49-d999-4415-bb65-8aec2c90ba62.terraform.tfstate"
  access_key           = "kFTe6d/em6w2o01CjpBLsVbaJTasjLBXf9J9m/Of7zEqHexeOwoSbmPBipvaBRQ48LJ1OUwYISz3GH+1IvE4sw=="
  }
}
```

The storage account name, container name and storage account access key are all values from the Azure storage account service.

The "key" is the **name** of the blob file that Terraform will create within the container for the remote state.

![Container Name and "Key"](/automation/terraform/images/tfstateContainer.png)

You get to choose this. I have used the subscriptionId as part of the naming convention, but essentially it needs to be unique and tied to the terraform directory you are using. If you have multiple Terraform directories for a particular subscription then you could use "terraform.tfstate" as the key (blob name) for each of them if your container name if you had a unique and different container_name for each.  (The file locking is per blob.)

The access key is in the Access Keys part of the storage account blade. (The sensitive values in the screenshot have been masked by the excellent Azure Mask extension for Chrome.)

![Access Key](/automation/terraform/images/tfstateAccessKey.png)

There are a number of key benefits to using remote state, and in using Azure Storage for the remote state storage:

1. The definitive state resides in the cloud, supporting a distributed set of Terraform admins
1. Azure Storage is encrypted by default and supports BYOK as well as rich RBAC support
1. Azure Storage supports leases against the blobs which are used by Terraform as a locking mechanism for activities that write to state

## Updating to remote backend

Once you have created the backend stanza then the terraform workflow will move you to the new configuration.

```bash
terraform-labs$ terraform init

Initializing the backend...
Do you want to copy existing state to the new backend?
:
Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
```

* Run the `terraform plan` step

```bash
terraform-labs$ terraform plan
Acquiring state lock. This may take a few moments...
:
```

Once it has completed then you can use the portal, CLI or Azure Storage Explorer tools to validate the container and blob.

## **Lab**: Create backend state

OK, follow the following steps to manually set up remote state for your terraform-labs area.

* **Log in as the service principal**
    * `az login --help` will remind you of the switches to login with service principals
    * Your provider.tf should include the values you need to log in
* **Create a storage account**
    * Needs a globally unique name of 3-24 lowercase alphanumerical characters
    * Use `az storage --help`
* **Copy the storage account key**
* **Create a container**
* **Create the terraform backend stanza**
* **Run the terraform init, plan and apply workflow**
* **Check the storage account in the portal**

If you get stuck then the key commands are listed at the bottom of the lab, or you can view the script in the next section if you are comfortable with Bash scripting.

## Scripted remote state configuration

If you want to automate the configuration of remote state to use Azure Storage accounts then feel free to make use of the following script:

The script assumes that you are running it within your Terraform directory. It will:

1. Create a _tfstate_ resource group in nWest Europe
1. Create a storage account with a name of tfstate-\<8 char random string>
1. Create a container called "tfstate-\<subscriptionId>-\<dirname>"
1. Create a backend.tf file with the backen stanza

The following commands will download it to your current directory.  You can then run it directly or customise it further.

```bash
uri=https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/automation/terraform/createTerraformBackend.sh
curl -sL $uri > createTerraformBackend.sh && chmod 750 createTerraformBackend.sh
```

These commands assume that you are in your terraform-labs directory and you are logged in to Azure using the Service Principal.

## **Lab**: Importing resources

Another new command for this lab is `terraform import`.  This is used to import existing resources into the Terraform state.

We'll do this with something nice and harmless like an empty resource group to demonstrate the process. We'll put it into its own file called import.tf so that we can delete it easily.

* Create a resource group: `az group create --name deleteme --location westeurope`
* Grab the ID for the azure resource: `id=$(az group show --name deleteme --query id --output tsv)`
* Create an empty stanza for the resource in a new import.tf file

```yaml
resource "azurerm_resource_group" "deleteme" {}
```

* Run the import command: `terraform import azurerm_resource_group.deleteme $id`

```bash
terraform-labs$ terraform import azurerm_resource_group.deleteme $id
Acquiring state lock. This may take a few moments...
azurerm_resource_group.deleteme: Importing from ID "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/deleteme"...
azurerm_resource_group.deleteme: Import complete!
  Imported azurerm_resource_group (ID: /subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/deleteme)
azurerm_resource_group.deleteme: Refreshing state... (ID: /subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/deleteme)

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

* Run `terraform plan` and you should see some errors as our block is not populated
* Run `terraform state show azurerm_resource_group.deleteme`

```bash
id       = /subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/deleteme
location = westeurope
name     = deleteme
tags.%   = 0
```

* Add in the name argument, and the location using the loc variable
* Rerun `terraform plan` and it should show no errors and no planned changes

The resource is now fully imported and safely under the control of Terraform.

* Add in the tags argument and variable
* Rerun `terraform plan` and then `terraform apply` to apply that change
* Now delete the import.tf file
* Rerun `terraform plan` and then `terraform apply` to remove the delete resource group

> Note that in the future it is planned that Terraform will be able to automatically generate resource stanzas.

## Breaking a blob lease that is locking the state

There is a possibility that you end up with an unwanted lease on your remote state blob file. Certain  terraform commands will therefore fail as they cannot lock the state.

Normally when you acquire a lease on blob storage you get a lease ID, and you can then use that lease ID to release the lock.  As Terraform initially acquired the lease then you don't have the lease ID and therefore you have to break it.

Below are the commands to confirm that there is a lease in effect and then to break the lease.

First, set the environment variables (used by the Azure CLI storage commands) and some standard Bash variables based on the values you have in your backend.tf.

```bash
export AZURE_STORAGE_ACCOUNT="<storage_account_name>"
export AZURE_STORAGE_KEY="<access_key>"
containerName=<container_name>
blobName=<key>
```

Check the current status of the blob lease using the following command:

```bash
az storage blob show --container-name $containerName --name $blobName --query properties.lease
```

Example output below. Note the status of locked.

```json
{
  "duration": "infinite",
  "state": "leased",
  "status": "locked"
}
```

The following command will break the lease:

```bash
az storage blob lease break --container-name $containerName --blob-name $blobName
```

Recall the blob show command to see the status of the lease.  It should be the same as the following JSON:

```json
{
  "duration": null,
  "state": "broken",
  "status": "unlocked"
}
```

It is important to first check that the lease is definitely a fault to be cleared, and not the result of another admin applying a change.

You may use the following commands to download an example script to break the lease based on your backend.tf:

```bash
uri=https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/automation/terraform/breakStateLock.sh
curl -sL $uri > breakStateLock.sh && chmod 750 breakStateLock.sh
```

## End of Lab 6

We have reached the end of the lab. You have configured remote state into an Azure storage account and imported an existing resource into the configuration.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-pre-012-lab6>. (I have retained the import.tf for reference.)

In the next lab we will look at some of the additional areas to consider with multi-tenanted environments, including the use of Service Principals and referencing read only states.  We will also look at some of the other ways of managing environments, such as the Terraform Marketplace offering in Azure, and Hashicorp's Terraform Enterprise.

[◄ Lab 5: Multi Tenancy](../lab5){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 7: Modules ►](../lab7){: .btn .btn--primary}