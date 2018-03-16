---
layout: article
title: Lab Terraforming Azure Kubernetes Service (AKS)
date: 2018-03-15
categories: 
author: Richard_Cheney
image:
  feature: 
  teaser: cloud-builder.jpg
  thumb: 
comments: true
excerpt: Use Terraform's AzureRM provider to drive Infrastructure as Code.
published: true
---

{% include toc.html %}

## Introduction

This three hour lab will get you set up to run Terraform to orchestrate Azure resources using infrastructure (and more) as code, and then set you a number of challenges to increase your familiarity with the product and how it works.  The end result of the session will be a working AKS cluster.

This cluster may then be used to host containers deployed from the container image created within the App Dev track which will also include concepts covered in the morning session on app modernisation using disaggregation technologies such as Event Grid.

Here is a quick overview of the lab:

* **Theory**
  * Terraform and the AzureRM provider
  * Terraform workflow (init -> plan -> apply)
  * Terraform state (build, change, destroy)
  * Implicit and explicit resource dependencies and terraform graph
  * Input and output variables, list and maps (defined, file, switch, 
  * Modules and the Terraform Registry
    * alicloud 4/4
    * aws 13/268
    * azurerm 15/26
    * google 9/22
    * opc 2/2
  * Custom ARM deployments triggered by Terraform
* **Connecting with the Terraform Azure Provider**
* **Spin up a Terraform VM from the Marketplace**
  * Shared remote state with locking, backed off to Azure Storage
  * Shared identity using MSI and RBAC
* Challenge 1: **Spin up a standard VM of your choice**
* Challenge 2: **Terraform Outputs and Variable**
* Challenge 3: **Spin up a Cosmos DB and ACI (temporarily)**
* Challenge 4: **Spin up an AKS cluster with a single B series for the afternoon**
* Optional Challenge: **Automate ACI Integration**

Proctors:

* Justin Davies (@justindavies)
* Richard Cheney (@RichCheneyAzure)
* Nic Jackson (@sheriffjackson) from Hashicorp

Useful links

* [Terraform docs for AzureRM provider](https://aka.ms/terraform)
* [Azure Docs hub for Terraform](https://docs.microsoft.com/en-gb/azure/terraform/)
* [Terraform page in Linux VM area](https://aka.ms/terraformdocs) (useful one pager)

## Prereqs

## Connecting with the Terraform Azure Provider

### Azure CLI

If you are logged in with the Azure CLI then it will use that authentication by default.

This is only really suitable for single user environments, so personal test and dev and for demonstration purposes.

#### Terraform in the Cloud Shell

If you are using the Cloud Shell then you will already be logged into Azure, although you may want to use `az account list` and `az account set --subscription <subscriptionId>` to change your default subscription.

Both az and terraform are maintained packages in the bash Cloud Shell container image.

Type `terraform` and you'll see the command help.

#### Terraform in the Windows Subsystem for Linux

The following have been tested on the Ubuntu version of WSL.

Install the Azure CLI from <https://aka.ms/GetTheAzureCli>.

Install Terraform.  Either:

1. Download the zip from <https://www.terraform.io/downloads.html> and extract the terraform executable to somewhere within your path such as /usr/local/bin
2. Or if you are feeling trusting then run the following code block:

```bash
curl --output terraform.zip https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
sudo bash <<"EOF"
apt-get --assume-yes install zip
unzip -o terraform.zip terraform -d /usr/local/bin && rm terraform.zip
chown root:root /usr/local/bin/terraform
chmod 755 /usr/local/bin/terraform
EOF
```

You may also want to install jq: `sudo apt-get --assume-yes install jq`

### Service Principal

Making use of a Service Principal for the authentication is the nmost appropriate route if embedded into another automation framework such as a CI/CD pipeline.

It make uses of a set of variables or environment variables. If the  variables are separated out into their own .tf file(s) then they may be customised for the customer or project and therefore the other .tf files are more portable. The same applies to using environment variables, which may then be exported in config files.

This lab will not make use of Service Principals, but you may still find the following useful. The commands assume that you have jq installed, are already logged in via the Azure CLI and have the correct subscription selected.

Create the Service Principal and login:

```bash
subscriptionId=$(az account show --output tsv --query id)
echo "az ad sp create-for-rbac --role=\"Contributor\" --scopes=\"/subscriptions/$subscriptionId\""
spout=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscriptionId" --output json)
jq . <<< $spout

clientId=$(jq -r .appId <<< $spout)
clientSecret=$(jq -r .password <<< $spout)
tenantId=$(jq -r .tenant <<< $spout)

az login --service-principal --username $clientId --password $clientSecret --tenant $tenantId --output json
```

Check that the login is successful using any CLI command such as `az account list-locations --output table` or `az account show --output jsonc`.

Create a provider.tf file with the information:

```bash
echo "provider \"azurerm\" {
  subscription_id = \"$subscriptionId\"
  client_id       = \"$clientId\"
  client_secret   = \"$clientSecret\"
  tenant_id       = \"$tenantId\"
}
" > provider.tf && chmod 750 provider.tf
```

Alternatively, export ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_TENANT_ID.

Your Azure Provider section then only needs to contain `provider "azurerm" { }`.

### Managed Service Identity

Managed Service Identity is perfect for allowing code run on a virtual machine to have an automatically managed identity for logging into Azure without passing in credentials in the code.   

Once configured you can set the `use_msi` provider option in Terraform to `true` and the virtual machine will retrieve a token to access the Azure API.  In this context MSI allows all users on that trusted machine to share the same authentication mechanism when running Terraform.

Terraform can also configure virtual machines with managed service identities.

## Spin up a Terraform VM from the Marketplace

Azure support for Terraform is already strong, but is now available as a free offering in the Marketplace, with only the underlying VM hardware resource costs passed through. This is ideal for customers who want to use a single Terraform instance across multiple team members, multiple automation scenarios and shared environments.

The offering is at <https://aka.ms/aztf>. The Ubuntu VM will have the following preconfigured:

* Terraform (latest)
* Azure CLI 2.0
* Managed Service Identity (MSI) VM Extension
* Unzip
* JQ
* apt-transport-https

There is also an Azure Docs page at <https://aka.ms/aztfdoc> which covers how to access and configure the Terraform VM.

--------------

### **SETUP: Spin up a Terraform VM**

Spin up a B1s Terraform VM in your subscription and configure it.

--------------

