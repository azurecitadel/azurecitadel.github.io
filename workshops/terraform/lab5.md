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

So far we have been authenticating using either Cloud Shell (labs 1 and 2) or Azure CLI (labs 3 and 4), which both work really well for one person when doing demos and a little development work.  If you see your current context (as shown by `az account show`) then that will show the authentication type (if not explicitly) and also shows the tenancy and subscription you will be deploying into.

However it is not a workable approach when you have multiple admins working on an environment and it is not suitable if you are dealing with multiple tenants.

In this lab we will look at how we could make our Terraform platform work effectively in a multi-tenanted environment by using Service Principals.  The approach here applies to any more complex environment where there are multiple subscriptions in play, as well as those supporting multiple tenancies or directories.  Service Principals are also the recommended route if you are integrating the Terraform Provider into automation or within a DevOps CI/CD pipeline.

Finally, at the end of the lab we will also take a look at a couple of alternatives for managing systems and discuss where they make the most sense.

1. The Terraform Marketplace offering in Azure and Managed Service Identity (MSI) authentication
2. Terraform Enterprise from Hashicorp

## Pre-requisites

You will have already been using the az and terraform executables locally.  As Terraform is from the OSS world then these labs are unapologetically written from a linux and CLI 2.0 perspective. Linux and MacOS users 

For Windows 10 then the minimum is to use both terraform and az at the Windows OS level so that you can use them within a Command Prompt or PowerShell session. (You are also free to use the equivalent AzureRM module PowerShell cmdlets in place of the CLI 2.0 commands.)

However the remaining labs really are based on Windows 10 users having enabled the [Windows Subsystem for Linux](https://azurecitadel.github.io/guides/wsl/) (WSL) and do make use of Bash scripting at points.  If you have Windows 10 and can enable WSL then it is very much recommended.  Don't forget to follow the [guide](https://azurecitadel.github.io/guides/wsl/) to also install az, jq, git and terraform at that level.

> An alternative is to make use of the [Terraform VM](#terraform-vm-on-the-azure-marketplace) discussed towards the bottom of the lab.  This has az, jq and terraform preinstalled and defaults to using MSI so the whole VM is authenticated to a subscription.  You can ssh on to the VM and work straight away.  And you are still free to use service principals in preference to MSI. This is an option, especually if your vi, nano or emacs skills are good.

## Service Principals

Service Principals are security identities within an Azure AD tenancy that may be used by apps, services and automation tools.  

When you create a Service Principal then from an RBAC perspective it will have the Contributor role assigned at the subscription scope level.  For most applications you would remove that and then assign a more limited RBAC role and scope assigment, but this default level is ideal for Terraform provisioning.

We will create a Service Principal and then create a provider.tf file in our containing the fields required.  Make sure that you are in the right Azure context first (i.e. which tenancy and subscription).

* check your current context by using `az account show`
* list out your subscriptions using `az account list --output table`
* change subscription by using `az account set --subscription <subscriptionId>`

Service principals work really well in a multi-tenanted environment as the service principal authentication details can sit directly in the relevent terraform directory so that it is easy to define the target subscription and tenancy and tightly connect it with the other infrastructure definitions.

For a standard multi-tenancy environment then you would create a service principal per subscription and then create a provider block for each terraform folder. (The provider stanza can be in any of the .tf files, but provider.tf is common.)  

Having a separate terraform folder per customer or environment with its own provider.tf files is very flexible.  It also mitigates common admin errors such as terraform commands being run whilst in the wrong context.

## Steps

This is an overview of the steps if you want to do this manually:

* Create the service principal
* Capture the appId, password and tenant
* Login as the service principal to test (optional)
* Either
    * Create a azurerm provider block populated with the service principal values
    * Export environment variables, with an empty azurerm provider block

----------

Here is an example provider.tf file containing a **populated** azurerm provider block:

```ruby
provider "azurerm" {
  subscription_id = "2d31be49-d959-4415-bb65-8aec2c90ba62"
  client_id       = "b8928160-69bf-4483-a2cc-b726e1e65d87"
  client_secret   = "93b1423d-26a9-4ee7-a4f6-29e32d4c05e8"
  tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd012db47"
}
```

Note that in a production environment you would need to ensure that this file has appropriate permissions so that the client_id and client_secret does not leak and create a security risk. (See below for resetting credentials.)

----------

The alternative is to use **environment variables**.  For example, by adding the following lines to a .bashrc file:

```bash
export ARM_SUBSCRIPTION_ID="2d31be49-d959-4415-bb65-8aec2c90ba62"
export ARM_CLIENT_ID="b8928160-69bf-4483-a2cc-b726e1e65d87"
export ARM_CLIENT_SECRET="93b1423d-26a9-4ee7-a4f6-29e32d4c05e8"
export ARM_TENANT_ID="72f988bf-86f1-41af-91ab-2d7cd012db47"
```

If you are using environment variables then the provider block should be **empty**:

```ruby
provider "azurerm" {}
```

Note that this approach is not as effective if you are moving between terraform directories for different customer tenancies and subscriptions, as you need to export the correct variables for the required context, but it does have the benefit of not having the credentials visible in one of the *.tf files.

## Challenge

Rather than a straight lab, we'll make this one more of a challenge. The challenge will get you in the habit of searching for documentation available from both Hashicorp and Microsoft. In this challenge you will create a service principal called `terraform-labs-<subscriptionId>`.

**Run through the following**:

1. **Find your subscription ID and copy the GUID to the clipboard**
1. **Search for the documentation to create an Azure service principal for use with Terraform**
1. **Follow the guide and create a populated provider.tf file**
1. **Log on to azure as the service principal using the CLI**
1. **Log back in with your normal Azure ID and show the context**
1. **Search for the Azure Docs for changing the role (and scope) for the service principal**

If you get stuck then there are answers at the bottom of the lab.

## Automated

If you want to automate that process then feel free to make use of this script to create a service principal and provider.tf: <https://github.com/azurecitadel/azurecitadel.github.io/blob/master/workshops/terraform/createTerraformServicePrincipal.sh>

The script will interactively

1. create the service principal (or resets the credentials if it already exists)
1. prompts to choose either a populated or empty provider.tf azurerm provider block
1. exports the environment variables if you selected an empty block (and display the commands)
1. display the az login command to log in as the service principal

The following commands will download it and run it:

```bash
uri=https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/workshops/terraform/createTerraformServicePrincipal.sh
curl -sL $uri > createTerraformServicePrincipal.sh && chmod 750 createTerraformServicePrincipal.sh
./createTerraformServicePrincipal.sh
```

## Resetting service principal credentials

Note that if you have lost the password values at any point then you can always use the following command to generate a new password:

```bash
az ad sp credential reset --name "http://terraform-<subscriptionId>"
```

Note the full name for a Service Principal is the display name we specified in the initial creation, prefixed with `http://` You will need to have the correct level of role based access to display or reset credentials.

## Aliases

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
  tenant_id       = "72f988bf-8691-41af-91ab-2d7cd011db47"
}

resource "azurerm_resource_group" "devopsrg" {
  provider = "azurerm.devops"

  # ...
}
```

And don't forget that different service principals can have different scopes and roles within a subscription so that may also come in useful depending on the requirement.

Using service principals is an easy and powerful way of managing multi-tenanted environments when the admins are working in a centralised Terraform environment.

## Terraform VM on the Azure Marketplace

> It is assumed that you are now working with Terraform locally on your machine rather than in Cloud Shell and that you are using the service principal to authenticate.  This section on Terraform VM and MSI is for information only - there is no need to run the offering.

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

There is also an Azure Docs page at <https://aka.ms/aztfdoc> which covers how to access and configure the Terraform VM by running the `~/tfEnv.sh` script. Note that if you have multiple subscriptions then you should again make sure that you are in the correct one and then run just the role assignment command within the `tfEnv.sh` file.

One of the nice features of the Terraform VM Marketplace offering is that it will automatically back off the local terraform.tfstate to blob storage, with locking based on blob storage leases. (We will be looking at how to do this manually in the next lab.)

It also creates a remoteState.tf file for you in your home directory. The remoteState.tf has the following format:

```ruby
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

## Challenge Answers

* Find your subscription ID and copy the GUID to the clipboard

<div class="answer" style="font-size:50%">
    <small>
        <p>There are many ways of finding the subscription GUID. Here are a few:
            <ol>
                <li>You can search on subscriptions at the top of the portal, or look at the properties in the portal blade of any resource group or    resource.</li>
                <li>From the az CLI you can run `az account show --output json`.</li>
                <li>In scripting you could set a variable using `subId=$(az account show --output tsv --query id)`.</li>
            </ol>
        </p>
    </small>
</div>

* Search for the documentation to create an Azure service principal for use with Terraform

<div class="answer" style="font-size:50%">
        <p>Searching on "terraform azure service principal" takes you to  https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html.</p>
</div>

* Log back in with your normal Azure ID and show the context

<div class="answer" style="font-size:50%">
    <p>az logout<br>az login<br>az account show</p>
</div>

* Search for the Azure Docs for changing the role (and scope) for the service principal

<div class="answer" style="font-size:50%">
    <p>Searching on "azure cli service principal" takes you to https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli.<br>This includes sections on deleting and creating role assigments.  You should always remove the Contributor role when adding a different inbuilt or custom role to a service principal.</p><p>The page itself does not mention scope, but clicking on the <em>az role assignment create</em> link takes you through to the https://docs.microsoft.com/en-us/cli/azure/role/assignment#az-role-assignment-create reference page. The command has a --scope switch that defaults to the subscription but can be set to another scope point such as a resource group or an individual resource.</p>
</div>

## End of Lab 5

We have reached the end of the lab. We're now using Service Principals for authentication.

We have also looked at the Azure Marketplace offering for Terraform, and at Terraform Enterprise.  If you would like to see a labs on configuring Terraform Enterprise then add a comment below.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab5>.

In the next lab we will look at the terraform.tfstate file.

[◄ Lab 4: Metas](../lab4){: .btn-subtle} [▲ Index](../#labs){: .btn-subtle} [Lab 6: State ►](../lab6){: .btn-success}