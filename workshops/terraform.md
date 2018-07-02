---
layout: article
title: "Terraform on Azure"
categories: none
date: 2018-06-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
featured: false
published: true
image:
  feature: terraform.jpg
  teaser: terraform.png
excerpt: Series of labs for Terraform on Azure 
---

{% include toc.html %}

## Introduction

This workshops is made up of a series of labs to take you through the fundamentals of using Terraform to manage the deployment and removal of simple Azure services, through to modularising your own standards to effectively manage large scale deployments.

This lab will cover a lot of ground, including

* Terraform principles, workflows and terminology
* The three ways of authenticating the Terraform Azure Provider
* Using the interpolation syntax
* Variables, locals, data, outputs
* Load order and overrides
* Dependencies and the graph database
* Using modules and the Module Registry
* Provisioners and using the taint command
* Meta-parameters such as *count* and *depends_on*
* Using the splat operator
* Protecting and locking your state
* Using workspaces and read only states
* Sensitive data
* Integrating with git repositories

## Pre-requisites

[**Azure Subscription**](/guides/subscription){:target="_blank" class="btn-info"}

You will need access to a subscription (with 'contributor rights'), or an Azure Pass or free account. Click on the button above for more details.

Ensure that it is active by logging onto the [portal](http://portal.azure.com) and creating an resource group.

**💬 Note.** If you are using an Azure Free Pass then please do not activate it using your work email address.  If you do then it will be unlikely that you will have RBAC permissions to create Service Principals and you will be limited to using the Azure CLI authentication.

----------------------

[**💻 Visual Studio Code**](/guides/vscode){:target="_blank" class="btn-info"}

Please install and configure Visual Studio Code as per the link in the button above.  We won't be writing any real code, but the editor has some great support for editing the .tf files used by Terraform and integrating with Azure.

The following extensions should also be installed as they are assumed by the labs:

**Module Name** | **Author** | **Extension Identifier**
Azure Account | Microsoft | [ms-vscode.azure-account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
Azure Terraform | Microsoft | [ms-azuretools.vscode-azureterraform](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform)
Terraform | Mikael Olenfalk | [mauve.terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)
Advanced Terraform Snippets Generator | Richard Sentino | [mindginative.terraform-snippets](https://marketplace.visualstudio.com/items?itemName=mindginative.terraform-snippets)
Azure Storage | Microsoft | [ms-azuretools.vscode-azurestorage](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurestorage)

Use `CTRL`+`SHIFT`+`X` to open the extensions sidebar.  You can search and install the extensions from within there.

For the Azure Terraform extension you may also need a couple of additional installations:

* [**Terraform**](https://www.terraform.io/downloads.html)
    * For lab 2 you will need to download the executable and make sure it is in your OS' path
        * For Windows that will need to be in your system PATH, e.g. into`C:\Windows\System32\`
        * Avoid using the User Path or vscode may not be able to find it  
    * For lab 5 you will need terraform in your integrated terminal, and the lab covers how to do this for Windows Subsystem for Linux users
* [**Node.js 6.0+**](https://nodejs.org/en/)
    * Required for lab 2
    * Note that node.js is only required for the Azure Terraform extension in vscode, not for Terraform itself
* [**GraphViz**](http://www.graphviz.org/) - optional if you are using the visualize feature to ss the Terraform graph

----------------------

[**💻 Azure CLI**](https://aka.ms/GetTheAzureCli){:target="_blank" class="btn-info"}

The first lab will make use of the Azure [Cloud Shell](https://shell.azure.com/) which already has both the Azure CLI and the Terraform binary installed.  They will also be automatically updated over time as the base container image is automatically managed by Microsoft.

You may wish to switch at some point to running the Azure CLI and Terraform locally.

For Windows 10 users we highly recommend enabling the Windows Subsystem for Linux (WSL) feature and then downloading one of the Linux distros available on the Windows Store (such as [Ubuntu](ms-windows-store://pdp/?productid=9NBLGGH4MSV6&referrer=unistoreweb&scenario=click&webig=43bd1422-74f7-4017-88ae-c3f84bb60893&muid=35E9D9E2EDE76C043B35D293ECDF6DB9&websession=1745cfbb549648ecac5167207ba91c13)).  Once that is configured then you can installing the Azure CLI using [apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest).

For Linux and macOS users, click on the button above to find the right install instructions.

**💬 Note.** Use of the legacy Windows CMD prompt is not advised, and use of alternative bash systems (gitbash or cygwin) is discouraged.

----------------------

## Assumptions

A good working knowledge of the Azure services and ecosystem has been assumed.

A background knowledge of Terraform is advised. The button below will take you to Terraform's intro guide.

[**Terraform Intro**](https://aka.ms/terraform/intro){:target="_blank" class="btn-info"}

----------------------

## Lab Contents

**Lab** | **Name** | **Description**
1 | [Basics](lab1) | Use the basic Terraform workflow in Cloud Shell
2 | [Variables](lab2) | Provision from within VS Code and start to use variables
3 | [Core Environment](lab3) | Use a GitHub repo and provision a core environment
4 | [Meta Parameters](lab4) | Make use of copy and other meta parameters
5 | [Multi Tenancy](lab5) | Using Service Principals and Managed Service Identity
6 | [State](lab6) | Configuring remote state and using read only state in split environments
7 | [Modules](lab7) | Learn about modules, converting your .tf files, Terraform Registry
8 | [Extending with other Providers](lab8) | Use other providers to configure an AKS Kubernetes cluster
9 | [Provisioners](lab9) | Leverage provisioners to customise your virtual machine deployments
10 | [Packer](lab10) | Use Packer to create custom images for virtual machine deployments

**💬 Note.** The labs are currently being built and will become available over the coming month.