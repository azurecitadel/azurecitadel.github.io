---
layout: article
title: "Terraform Lab 6: State"
categories: null
date: 2018-08-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: false
---

{% include toc.html %}

## Introduction

In this lab we will go a little deeper in understanding the Terraform state file.

We will also look at how you can configure remote state to protect the local file and make it usable in an environment with multiple Terraform admins.

We will also cover locking (and how to remove leases on Azure blob storage), as well as refreshing the state and importing existing resources into the state.

## Overview

Terraform stores the state of your managed infrastructure from the last time Terraform was run.  The local file is called terraform.tfstate.  

When you run `terraform plan` it will refresh an in memory copy of the state for the planning step.  Note that it won't save that updated state to disk.

```bash
citadel-terraform$ terraform plan
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
citadel-terraform$ terraform state list | grep security
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
citadel-terraform$ terraform state show azurerm_network_security_rule.AllowHTTPS
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
citadel-terraform$ terraform state pull | jq '.modules[0].resources."azurerm_network_security_rule.AllowHTTPS"'
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

Azure storage accounts are encrypted by default.  You can use RBAC to control access to the storage account, to the container and the individual blobs as well.

In terms of terraform configuration we make use of the `terraform` high level keyword, and configure a backend stanza for the provider.  Below is an example:

```ruby
terraform {
  backend "azurerm" {
  storage_account_name = "terraformstatehco9vwseg1"
  container_name       = "tfstate"
  key                  = "2d31be49-d999-4415-bb65-8aec2c90ba62.terraform.tfstate"
  access_key           = "kFTe6d/em6w2o01CjpBLsVbaJTasjLBXf9J9m/OfpzEqHexeOwoSbmPBipvaBRQ48LJ1OUwYISz3GH+1IvE4sw=="
  }
}
```

The storage account name, container name and storage account access key are all values from the Azure storage account service.  The key is the name of the blob file that Terraform will create within the container for the remote state.

Using Azure Storage for the remote state also moves the "one version of the truth" into the cloud, supporting a distributed set of Terraform admins on the same environment.

Azure Storage is also one of the best targets for a remote state file as it supports leases which are used by Terraform as a locking mechanism.  Therefore it will prevent multiple admins from concurrently running Terraform commands that require write access to the state.

OK, we'll configure remote state in your citadel-terraform directory.  You can either follow the manual steps below or use the script a little further down.

## Manually creating remote state

* Log in as the service principal
* Create a storage account
    * Needs a globally unique name of 3-24 lowercase alphanumerical characters
* Copy the storage account key
* Create a container
* Create the terraform backend stanza
* Run the terraform init, plan and apply workflow
* Check the storage account in the portal

## Scripted remote state configuration

These commands assume that you are in your citadel-terraform directory and you are logged in to Azure using the Service Principal.

```bash
rg=terraform
subscriptionId=$(az account show --output tsv --query id)
az group create --name $rg --location "westeurope"
saName=terraformstate$(tr -dc "[:lower:][:digit:]" < /dev/urandom | head -c 10)

az storage account create --name $saName --kind BlobStorage --access-tier hot --sku Standard_LRS --resource-group $rg --location westeurope

saKey=$(az storage account keys list --account-name $saName --resource-group terraform --query "[1].value" --output tsv)

az storage container create --name tfstate --account-name $saName --account-key $saKey

echo "terraform {
  backend \"azurerm\" {
  storage_account_name = \"$saName\"
  container_name       = \"tfstate\"
  key                  = \"$subscriptionId.terraform.tfstate\"
  access_key           = \"$saKey\"
  }
}
" > backend.tf && chmod 640 backend.tf
```

In this example I have included the subscriptionId in the naming convention for the storage blob.

* Run the `terraform init` step

```bash
citadel-terraform$ terraform init

Initializing the backend...
Do you want to copy existing state to the new backend?
:
Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
```

* Run the `terraform plan` step

```bash
citadel-terraform$ terraform plan
Acquiring state lock. This may take a few moments...
:
```

* Check the storage account

You should now see the blob storage

## Add in detail for manually releasing the lease / lock

## Add in the import step for a resource group

## End of Lab 6

We have reached the end of the lab. You have configured remote state into an Azure storage account and imported an existing resource into the configuration.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab6>.

In the next lab we will look at some of the additional areas to consider with multi-tenanted environments, including the use of Service Principals and referencing read only states.  We will also look at some of the other ways of managing environments, such as the Terraform Marketplace offering in Azure, and Hashicorp's Terraform Enterprise.

[◄ Lab 5: Multi Tenancy](../lab5){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 7: Modules ►](../lab7){: .btn-success}