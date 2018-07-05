---
layout: article
title: "Terraform Lab 5: Multi Tenancy"
categories: null
date: 2018-06-25
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
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

For Windows 10 then the minimum is to download both terraform and az at the Windows OS level so that you can use them within a Command Prompt or PowerShell session.  However the remaining labs are based on Windows 10 with the [Windows Subsystem for Linux](https://azurecitadel.github.io/guides/wsl/) (WSL) configured and do make use of Bash scripting at points so WSL is very much recommended.  If you have WSL then you should also download the 64 bit linux version of terraform, and make sure that both CLI 2.0 and jq are installed. (An alternative is to make use of the [Terraform VM](#terraform-vm-on-the-azure-marketplace) discussed towards the bottom of the lab. )

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

If you want to automate the installation of the terraform executable on linux then feel free to copy out the following code block and create your own shell script:

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

sudo true

sudo bash <<"EOF"
mv /tmp/terraform /usr/local/bin/terraform
chown root:root /usr/local/bin/terraform
chmod 755 /usr/local/bin/terraform
EOF

ls -l /usr/local/bin/terraform
/usr/local/bin/terraform -version
```

### Final check

OK, you should now be able to open the integrated console in vscode (using `CRTL`+`'`) and type both `az` and `terraform`.  

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

You'll notice that we have set the service principal name to the subscription GUID prefixed with "terraform-".  The command will generate a service principal name or password if they are not specified.  However specifying the name as 'terraform-\<subscriptionId\>' as a standard should ensure that the endpoint is unique enough yet easily derived in scripting.  

Check that the login is successful using any CLI command such as `az account list-locations --output table` or `az account show --output jsonc`.

> Note that you will be logged on at the CLI level using the service principal for a period of time, so if you want to revert back to your normal context then you should use `az logout` and then login in normally.  

#### Create a provider.tf file

Create your provider.tf file with the collected information:

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
> Note the full name for a Service Principal is the display name we specified in the initial creation, prefixed with `http://` You will need to have a good level of role based access to display or reset credentials.

## Optionally reconfigure the Azure Terraform extension

If you like using the Command Palette's Terraform commands then you can reconfigure the extension to start using your integrated console rather than the Cloud Shell.  

* Open up settings using `CTRL-,`
* Search for `terraform.terminal`
* Click on the pen to the left of the setting in the Default User Settings pane
* Select `integrated` from the drop down list

## Manually updating state

OK, now that you have the service principal and the provider.tf file created you should be good to go.  Well, almost...

Run the following in your integrated console, i.e. in your local citadel-terraform directory:

* `terraform init`
* `terraform plan`

OK, your local directory is now initialised, but as you have no current terraform.tfstate file then your plan will show that all of the resources will be created.  

We will be dealing with state in more detail in the next lab but if you open your local terraform.tfstate file in vscode then you will notice that it is a text file containing a small amount of JSON data. It has no knowledge of the resources that have already been created in the prior labs.

If you have installed the Azure Storage extension for vscode then we can copy the contents of the terraform.tfstate file in out Cloud Shell file area.  

* Click on the Azure logo on the left to open the Storage extension
* Navigate to your Cloud Shell storage account, which will be prefixed with cs
* Drill into the File Share within it
* Find the share used by Cloud Shell for the ~/clouddrive area
* Navigate within that to the citadel-terraform folder
    * This is where you have been syncing your .tf files to date
* Click on the terraform.tfstate file:

![clouddrive terraform.tfstate](/workshops/terraform/images/clouddrive-terraform.tfstate.png)

This contains the full state of our environment as this is where we have been running the terraform commands during labs 1-4.

* Copy out the contents of the clouddrive terraform.tfstate file (`CTRL-A, CTRL-C`)
* Close the tab with the clouddrive terraform.tfstate (`CTRL-W`)
* Open your the local terraform.tfstate file
* Replace the contents of the file with the clipboard (`CTRL-A, CTRL-V`)
* Save the local file (`CTRL-S`)

OK, you have manually copied the state in.  

* Reopen the integrated console (`CTRL-`)
* Rerun the `terraform plan` step

You should see that everything is up to date and known and that no changes are planned.  

> This is a really sensible checkpoint to reach.  Avoid making changes to the configuration until you reach this kind of steady state.

## Set the Key Vault access policy

At the moment we only have the terraformKeyVaultReader with Get access on keys and secrets.  Let's add our new Terraform Service Principal with an access policy to list secrets and keys as well.

* Add another access policy sub stanza into the key vault resource in the modules/scaffold/main.tf file
* Use the tenant_id and object_id for your service principal from the provider.tf

```ruby
    access_policy {
      tenant_id             = "72f988bf-89f1-41af-91ab-2d7cd011db47"
      object_id             = "cf34389a-893e-42a9-8201-9a5bed151767"
      key_permissions       = [ "get", "list", "import", "update" ]
      secret_permissions    = [ "get", "list", "set" ]
    }
```

**DO I NEED THIS??????**

* Run the terraform init, plan and apply steps

It should come through as a straight update in place to the key vault.

## Multi-tenancy

For a standard multi-tenancy environment then you will need to create a service principal per subscription and then create a provider block for each terraform folder. (The provider stanza can be in any of the .tf files, but provider.tf is common.)  

Having a separate terraform folder per customer or environment with its own provider.tf files is very flexible.  It also mitigates common admin errors such as terraform commands being run whilst in the wrong context.

There is another less frequently used argument that you can specify in the provider block called **alias**.  

Using aliases can be of use in a customer environment where they want to configure a deployment across multiple subscriptions or clouds.  Let's take the example of customer with one subscription for the core services and another for the devops team.  If you do not have an alias specified in a provider block then that is your default provider, so adding aliases creates additional providers.  You can then specify that provider alias in your resource stanzas.  For example:

```ruby
provider "azurerm" {
  subscription_id = "2d31be49-d999-4415-bb65-8aec2c90ba62"
  client_id       = "cf34389a-839e-42a9-8201-9a5bed151767"
  client_secret   = "923ea4d9-829a-4477-9650-7a11c4a680f3"
  tenant_id       = "72f988bf-8691-41af-91ab-2d7cd011db47"
}

provider "azurerm" {
  alias           = "azurerm.devops"
  subscription_id = "1234be49-d999-4415-bb65-8aec2c90ba62"
  client_id       = "1234389a-839e-42a9-8201-9a5bed151767"
  client_secret   = "1234a4d9-829a-4477-9650-7a11c4a680f3"
  tenant_id       = "123488bf-8691-41af-91ab-2d7cd011db47"
}

resource "azurerm_resource_group" "devopsrg" {
  provider = "azurerm.devops"

  # ...
}
```

And don't forget that different service principals can have different scopes and roles within a subscription so that may also come in useful depending on the requirement.

Using service principals is an easy and powerful way of managing multi-tenanted environments when the admins are working in a centralised Terraform environment.

## Terraform VM on the Azure Marketplace

> It is assumed that you are now working with Terraform locally on your machine rather than in Cloud Shell and that you are using the service principal to authenticate.  This section on Terraform VM and MSI is for information only - there is no need to instantiate the offering.

If you are only working within one subscription then an easy production alternative to using service principals is to use the new Terraform VM offering on the marketplace.

This is ideal for customers who want to use a single Terraform instance across multiple team members, multiple automation scenarios and shared environments.  It also provides a linux VM in the subscription that can be used for other admin purposes.

Rather than using CLI 2.0 or Service Principals for the authentication, it uses the third possible authentication method, [Managed Service Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-service-identity/overview).  With MSI the whole Terraform service is effectively authorised for access to a subscription.

The Terraform offering in the Marketplace is detailed at <https://aka.ms/aztf>, and is free except for the underlying VM hardware resource costs. The Ubuntu VM will have the following preconfigured:

* Terraform (latest)
* Azure CLI 2.0
* Managed Service Identity (MSI) VM Extension
* unzip
* jq
* apt-transport-https

It features:

* Shared remote state with locking, backed off to Azure Storage
* Shared identity using MSI and RBAC

There is also an Azure Docs page at <https://aka.ms/aztfdoc> which covers how to access and configure the Terraform VM by running the `~/tfEnv.sh` script. Note that if you have multiple subscriptions then you should again make sure that you are in the correct one (using `az account list --output table` and `az account set --subscription <subscriptionId>`) and then run just the role assignment command within the `tfEnv.sh` file.

One of the nice features of the Terraform VM Marketplace offering is that it will automatically back off the local terraform.tfstate to blob storage, with locking based on blob storage leases. (We will be looking at how to do this manually in the next lab.)

It also creates a remoteState.tf file for you in your home directory. The remoteState.tf has the following format:

```json
terraform {
 backend "azurerm" {
  storage_account_name = "storestatelkbfjngsqkyiim"
  container_name       = "terraform-state"
  key                  = "prod.terraform.tfstate"
  access_key           = "6Wbo0IfW3YKRbsjeF9LFxyvlA2dJ8cJQF+ys6ZHIkW8GdBemXB20MGv66E+Nxx5Wi5KjeCXuVF7BcMo1OPAZYw=="
  }
}
```

Note that the "key" is the name of the blob that will be created in the terraform-state container.

### Optional group setting configuration

When you first connect using ssh to your Terraform VM then you'll be in your admin IDs home directory.  You can check the `/etc/passwd` and `/etc/group` files to show your default group.

You could use it like this if you were the only one working on the deployment. But if you were working as a team of Terraform admins for a deployment then you'd probably want to add a group of admins and a shared area for the Terraform files. (And optionally change the default group for your ID.) The code block below shows how thios can be done:

```bash
$ sudo addgroup terraform
Adding group 'terraform' (GID 1001) ...
$ sudo usermod --group terraform richeney
$ sudo mkdir --mode 2775 /terraform
$ sudo chgrp terraform /terraform
$ ll -d /terraform
drwxrwsr-x 2 root terraform 4096 Mar 19 11:19 /terraform/
```

Only members of the new terraform group will be able to create files in the /terraform folder.  The setgid permission ensures that all new files will automatically be assigned terraform as the group rather than the user's default group. You may need to log out of the Terraform VM and then log back in again to reflect the usermod change to the /etc/passwd file.

## Terraform Enterprise

[Terraform Enterprise](https://www.hashicorp.com/products/terraform) extends the standard Terraform capabilities and workflow to provider a richer set of functionality.  It is well suited to enterprise environments that require more collaboration and governance features.

Key features:

* Self service workflow
* Collaboration for teams
* Powerful ACLs and auditing
* Runs Terraform for you from the browser GUI
* Control the Terraform version in line with your versioned providers and Terraform files
* Prevent concurrent changes
* Integrate with SCM platforms (e.g. GitHub, BitBucket, GitLabs)
* View history of changes
* Enforce policies with [Sentinel](https://www.hashicorp.com/sentinel)

This video shows some of the key concepts, including the forking of environments from standard definitions, embedded customer environment variables, etc.

<iframe width="560" height="315" src="https://www.youtube.com/embed/atBRAG_3yNQ" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

Note that the standard Terraform executable itself is free to use.  [Terraform Enterprise](https://www.hashicorp.com/products/terraform) has a Pro and Premium tier, depending on the required level of features.

## End of Lab 5

We have reached the end of the lab. You have moved to running Terraform locally and we're now using Service Principals for authentication.

We have also looked at the Azure Marketplace offering for Terraform, and at Terraform Enterprise.  If you would like to see a labs on configuring Terraform Enterprise then add a comment below.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab5>.

In the next lab we will look at the terraform.tfstate file.

[◄ Lab 4: Metas](../lab4){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 6: State ►](../lab6){: .btn-success}