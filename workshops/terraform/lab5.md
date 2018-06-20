---
layout: article
title: "Terraform Lab 5: Multi Tenancy"
categories: null
date: 2018-08-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: false
---

{% include toc.html %}

## Introduction

So far we have been working in Cloud Shell, which works really well for one person doing demos and a little development work.  If you see you current context (as shown by `az account show`) then that is the tenancy and subscription you will be deploying into and the Terraform Azure provider will authenticate via the Azure CLI.

However it is not a workable approach when you have multiple admins working on an environment and it is not suitable if you are dealing with multiple tenants.  (Also, you cannot use modules in the ~/clouddrive area in the Cloud Shell as it sits on an SMB 3.0 area which does not support symbolic links.)

So in this lab we will look at how we could make our Terraform platform work effectively in a multi-tenanted environment by using Service Principals.  The approach here applies to any more complex environment where there are multiple subscriptions in play, as well as those supporting multiple tenancies or directories.  Service Principals are also the recommended route if you are integrating the Terraform Provider into automation or within a DevOps CI/CD pipeline.

Finally, at the end of the lab we will also take a look at a couple of alternatives for managing systems and discuss where they make the most sense.

1. The Terraform Marketplace offering in Azure and Managed Service Identity (MSI) authentication
2. Terraform Enterprise from Hashicorp

## Pre-requisites

* terraform
* CLI 2.0
* jq (linux only)
* vscode integrated console configured

From this point onwards you will need to have the executables locally.  For macOS and linux you will download them and your integrated console will be preconfigured to use your standard terminal shell.  

For Windows 10 then the minimum is to download both terraform and az at the Windows OS level so that you can use them within a Command Prompt or PowerShell session.  However the remaining labs are based on Windows 10 with the [Windows Subsystem for Linux](https://azurecitadel.github.io/guides/wsl/) (WSL) configured.  If you have WSL then you should also download the 64 bit linux version of terraform, and make sure that both CLI 2.0 and jq are installed.

Download terraform for your operating system from <https://www.terraform.io/downloads.html>.  The download will be a zip file containing the terraform executable.  Extract it to a directory within your path, such as /usr/local/bin, or C:\Windows\System32.  

Install the Azure CLI from <https://aka.ms/GetTheAzureCli> if you haven't done so already.

You may also want to install jq if `which jq` fails to find it.  You can install it on Ubuntu (or other Debian derived distros) using `sudo apt-get --assume-yes install jq`.

Configure the [integrated terminal](https://azurecitadel.github.io/guides/vscode/#integrated-console) within Visual Studio Code.  

You can use `where` and `which` on Windows and linux respectively to find the executable within your path. Below is my configuration using Windows 10 and the Ubuntu version of WSL.

```cmd
Microsoft Windows [Version 10.0.17134.112]
(c) 2018 Microsoft Corporation. All rights reserved.

C:\Users\richeney>where terraform.exe
C:\Windows\System32\terraform.exe

C:\Users\richeney>bash
richeney$ which terraform
/usr/local/bin/terraform
richeney$ terraform --version
Terraform v0.11.7

```

If those commands do not fine the terraform executable then check your path settings.

### Automated installation on linux

If you want to automate the installation of the terraform executable on linux then feel free to make use of the following code block:

```bash
#!/bin/bash

# Install zip if not there
[[ ! -x /usr/bin/zip ]] && sudo apt-get --assume-yes -qq install zip

# Determine latest file using the API
latest=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
dir=https://releases.hashicorp.com/terraform/$latest
zip=terraform_${latest}_linux_amd64.zip

# Download the zip file
echo "Downloading $dir/$zip ..." >&2
curl --silent --output /tmp/$zip $dir/$zip

if [[ "$(cd /tmp; sha256sum $zip)" != "$(curl -s $dir/terraform_${latest}_SHA256SUMS | grep $zip)" ]]
then
  echo "ERROR: Downloaded zip does not match SHA256 checksum value - removing" >&2
  rm /tmp/$zip
  exit 1
else
  echo "Extracting terraform executable ..." >&2
  unzip -oq /tmp/$zip terraform -d /tmp && rm /tmp/$zip
fi

echo "Moving terraform executable to /usr/local/bin with elevated privileges..." >&2

sudo bash <<"EOF"
mv /tmp/terraform /usr/local/bin/terraform
chown root:root /usr/local/bin/terraform
chmod 755 /usr/local/bin/terraform
EOF

ls -l /usr/local/bin/terraform
/usr/local/bin/terraform -version
```

### Final check

OK, you should now be able to open the integrated console in vscode (using `CRTL+'`) and type both `az` and `terraform`.  

As Terraform is from the OSS world then this lab will unapologetically be written from a linux and CLI 2.0 perspective, although there is little reason why you couldn't use the terraform and az executables in a PowerShell session, or use equivalent AzureRM modules PowerShell commands in place of the CLI 2.0 commands.  

From now on we will be working locally within this rather than using the Command Palette extension for Terraform to push into Cloud Shell.

## Service Principals

Service Principals are security identities within an Azure AD tenancy that may be used by apps, services and automation tools.  

When you create a Service Principal then from an RBAC perspective it will have the Contributor role assigned at the subscription scope level.  For most applications you would remove that and then assign a more limited RBAC role and scope assigment, but this default level is ideal for Terraform provisioning.

We will create a Service Principal and then create a provider.tf file in our containing the fields required.  Make sure that you aer in the right Azure context first (i.e. which tenancy and subscription).

* check your current context by using `az account show`
    * list out your subscriptions using `az account list --output table`
    * change subscription by using `az account set --subscription <subscriptionId>`

### Manual steps

Here is an overview of the steps if you want to do this manually:

* create the service principal
* capture the appId, password and tenant
* login as the service principal to test (optional)
* either
    * create a azurerm provider block with the service principal values (recommended)
    * export environment variables

In a production environment you would need to ensure that the file containing the provider block has appropriate permissions.

The Terraform documentation page for this is <https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html>.

### Semi-automated steps

Alternatively, below is a code block containing some bash commands to create a service principal, populate a provider.tf file and then log in with it.  Make sure you are in the right Azure context beforehand using `az account show`.  You will need to have both CLI 2.0 and jq for this code to work.

#### Create the service principal and login

```bash
subscriptionId=$(az account show --output tsv --query id)
echo "az ad sp create-for-rbac --role=\"Contributor\" --scopes=\"/subscriptions/$subscriptionId\" --name \"terraform-$subscriptionId\""
spout=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscriptionId" --name "terraform-$subscriptionId" --output json)
jq . <<< $spout

clientId=$(jq -r .appId <<< $spout)
clientSecret=$(jq -r .password <<< $spout)
tenantId=$(jq -r .tenant <<< $spout)

az login --service-principal --username $clientId --password $clientSecret --tenant $tenantId
```

Youl'l notice that we have set the service principal name to the subscription GUID prefixed with "terraform-".

Check that the login is successful using any CLI command such as `az account list-locations --output table` or `az account show --output jsonc`.

#### Create a provider.tf file

Create a provider.tf file with the information:

```bash
echo "provider \"azurerm\" {
  subscription_id = \"$subscriptionId\"
  client_id       = \"$clientId\"
  client_secret   = \"$clientSecret\"
  tenant_id       = \"$tenantId\"
}
" > provider.tf && chmod 640 provider.tf
```

#### Or use environment variables

If you prefer to use environment variables rather than having the values in a provider.tf file then export ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_TENANT_ID using the values from the Service Principal creation.  You will need a provider block in one of your files with an empty object, e.g.:

```ruby
provider "azurerm" { }
```

> Note that if you have lost the password values at any point then you may be able to use a command such as the following to generate a new password:
>
> ```bash
> az ad sp credential reset --name "http://terraform-<subscriptionId>"
> ```
>
> Note the full name for a Service Principal is the display name we specified in the initial creation, prefixed with 'http://'. You will need to have >a good level of role based access to display or reset credentials.

## Manually updating state

OK, now that you have the service principal and the provider.tf file created you should be good to go.  Well, almost...

Run the following in your integrated console, i.e. in your local citadel-terraform directory:

* `terraform init`
* `terraform plan`

OK, your local directory is now initialised, but as you have no current terraform.tfstate file then your plan will show that all of the resources will be created.  

We will be dealing with state in more detail in the next lab but if you open your local terraform.tfstate file in vscode then you will notice that it is a text file containing a small amount of JSON data.

If you have installed the Azure Storage extension for vscode then we can copy the contents of the terraform.tfstate file in out Cloud Shell file area.  Click on the Azure logo on the left, and then navigate to your cloud shell storage account, which will be prefixed with cs.  If you then drill into the File Share within it then you will find the share used by Cloud Shell for the ~/clouddrive area.  Navigate within that to the citadel-terraform folder.  This is where you have been syncing your .tf files to date.  Click on the terraform.tfstate file:

![clouddrive terraform.tfstate](/workshops/terraform/images/clouddrive-terraform.tfstate.png)

This contains the full state of our environment as this is where we have been running the terraform commands during labs 1-4.

* Copy out the contents of the clouddrive terraform.tfstate file (`CTRL-A, CTRL-C`) and close it (`CTRL-W`)
* Open the local terraform.tfstate file
* Replace the contents of the file with the clipboard (`CTRL-A, CTRL-V`)
* Save the local file

OK, you have manually copied the state in.  

* Reopen the integrated console (`CTRL-')
* Rerun the `terraform plan` step

You should see that everything is up to date and no changes are required.  

## Multi-tenancy

For a standard multi-tenancy environment then you will need to create a service principal per subscription and then create a provider block for each terraform folder. (The provider stanza can be in any of the .tf files, but provider.tf is common.) This is very flexible and limits user errors with admins running commands whilst in the wrong context.

There is another argument that you can specify in the provider block that could be of use in a customer environment where they want to configure a deployment across multiple subscriptions.  Let's take the example of customer with one subscription for the core services and another for the devops team.  If you do not have an alias specified in a provider block then that is your default provider, so adding aliases creates additional providers.  You can then specify that provider alias in your resource stanzas.  For example:

```ruby
provider "azurerm" {
  subscription_id = "2d31be49-d999-4415-bb65-8aec2c90ba62"
  client_id       = "cf34389a-839e-42a9-8201-9a5bed151767"
  client_secret   = "923ea4d9-829a-4477-9650-7a11c4a680f3"
  tenant_id       = "72f988bf-8691-41af-91ab-2d7cd011db47"
}

provider "azurerm" {
  alias           = "az.devops"
  subscription_id = "1234be49-d999-4415-bb65-8aec2c90ba62"
  client_id       = "1234389a-839e-42a9-8201-9a5bed151767"
  client_secret   = "1234a4d9-829a-4477-9650-7a11c4a680f3"
  tenant_id       = "123488bf-8691-41af-91ab-2d7cd011db47"
}

resource "azurerm_resource_group" "devopsrg" {
  provider = "az.devops"

  # ...
}
```

## ADD IN DETAILS OF TERRAFORM VM AND TERRAFORM ENTERPRISE

## End of Lab 5

We have reached the end of the lab. You have used Service Principals for authentication, and mimicked a split environment, enabling customers or business units to deploy their own infrastructure using Terraform whilst referencing the state of centralised systems.

We have also looked at the Azure Marketplace offering for Terraform and at Terraform Enterprise.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab7>.

In the next lab we will

[◄ Lab 4: Metas](../lab4){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 8: State ►](../lab6){: .btn-success}