---
title: "Automating Linux Virtual Machines"
date: 2019-03-25
author: Richard Cheney
category: automation
comments: true
featured: true
hidden: false
published: false
tags: [ "linux", "virtual machine" ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "linux"
excerpt: Collection of labs using Packer, ARM, Terraform and Ansible to automate Linux VMs
---

## Introduction

This workshops is a collection of labs using a selection of the tooling that we commonly see to automate processes around virtual machines.  Some of the tooling is designed to work across both Windows and Linux servers, but for the sake of these labs we will separate out the two as most admins naturally gravitate to the most common and native tooling for each.  (If you disagree, use the comments below!)

I am not a deep expert in many of these technologies, so if any of the labs configure anything in an odd way then flag that up to me via the comments (or a PR on the GitHub repo) and we'll improve the labs together.

Note that there is a host of useful material within [Microsoft Learn](https://docs.microsoft.com/en-gb/learn/) and the various quickstarts and how to guides within [Microsoft Docs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview), and it is assumed that you are familiar with many of these.

The aim of these labs is to bring together some of these technologies together into a cohesive set of tooling for standing up virtual machines.

## Topics

This collection is a work in progress, but will aim to cover:

* Using Packer to script the generation of custom images
    * Packer template containing shell commands
    * Packer template calling an Ansible playbook
    * Create an image in the Shared Image Gallery
* Using custom-init
    * ARM deployment calling custom-init
    * Terraform module using custom-init
* Using Ansible for last mile configuration
    * ARM deployment calling an Ansible playbook
    * Terraform module calling an Ansible playbook via local-exec
* Virtual Machine Agents
    * Extensions in ARM
    * Extensions in Terraform
    * Using DeployIfNotExists in Azure Policy and Initiatives

## Pre-requisites

You will need a linux terminal environment. If you have macOS or Linux desktop then great, and for Windows 10 users then look at installing Windows Subsystem for Linux.  Failing that then stand up a linux VM.  You can start from a standard platform image such as Ubuntu 18.04 LTS, or use a marketplace image such as the ones for Terraform and Ansible.

----------

[**Azure Subscription**](/guides/subscription){:target="_blank" class="btn-info"}

**Required for all labs.**

You will need access to a subscription (with 'contributor rights'), or an Azure Pass or free account. Click on the button above for more details.

Ensure that it is active by logging onto the [portal](http://portal.azure.com) and creating an resource group.

**💬 Note.** If you are using an Azure Free Pass then please do not activate it using your work email address.  If you do then it will be unlikely that you will have RBAC permissions to create Service Principals and you will be limited to using the Azure CLI authentication.

----------

[**Windows Subsytem for Linux**](https://azurecitadel.github.io/guides/wsl/){:target="_blank" class="btn-info"}

**Required for Windows 10 users.**

For Windows 10 users then enable and use the Windows Subsystem for Linux for these labs.   Follow the instructions here: <https://azurecitadel.github.io/guides/wsl/>.  (This also has the instructions for installing terraform, git, tree and jq.)

> These labs are not tested on Windows 7. If you are using Windows 7 then you cannot install the Windows Subsystem for Linux. It is recommended to upgrade to Windows 10 and use the Windows Subsystem for Linux. It is possible to use both az and terraform commands within a PowerShell integrated console on Windows 7 machine and you can still make your way through the labs, but if there are examples of Bash scripting then you will need to work around that. You may be able to use the Git Bash on Windows 7 but this has not been tested.

----------

[**💻 Additional Binaries**](#){:target="_blank" class="btn-info"}

The labs make use of a few binaries that are not part of a standard Ubuntu install, so please add the following packages if you cannot find them using _which_, e.g. `which jq`:

* jq
* git
* tree

For Ubuntu the install command is `sudo apt update && sudo apt install jq git tree'.

If you have a different distribution then you should use the right package manager for that distribution.

----------

[**💻 Terraform**](https://www.terraform.io/downloads.html){:target="_blank" class="btn-info"}

* Manually download the correct executable from the link above
* Manually move it to a directory in your OS' path

> Note that for Windows that will need to be in your system path, e.g. `C:\Windows\System32\`. Visual Studio Code does not search the Windows user path.

* For linux systems (including the WSL) that use apt as the package manager you may use the following command to download it to /usr/local/bin:

```bash
curl -sL https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/automation/terraform/installLatestTerraform.sh | sudo -E bash -
```

* Run `terraform --version` to verify

----------

[**💻 Azure CLI**](https://aka.ms/GetTheAzureCli){:target="_blank" class="btn-info"}

For Windows, Linux and macOS users, click on the button above to find the right install instructions to install at the operating system level.

For Windows 10 users who have enabled the Windows Subsystem for Linux (WSL) feature then you can installing the Azure CLI in the linux subsystem using [apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest).

**💬 Note.** Use of the legacy Windows CMD prompt is not advised, and use of alternative bash systems (gitbash or cygwin) is discouraged.

----------

[**💻 Packer**](https://aka.ms/GetTheAzureCli){:target="_blank" class="btn-info"}

For Windows, Linux and macOS users, click on the button above to find the right install instructions to install at the operating system level.

For Windows 10 users who have enabled the Windows Subsystem for Linux (WSL) feature then you can installing the Azure CLI in the linux subsystem using [apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest).

**💬 Note.** Use of the legacy Windows CMD prompt is not advised, and use of alternative bash systems (gitbash or cygwin) is discouraged.

----------

[**💻 Azure CLI**](https://aka.ms/GetTheAzureCli){:target="_blank" class="btn-info"}

For Windows, Linux and macOS users, click on the button above to find the right install instructions to install at the operating system level.

For Windows 10 users who have enabled the Windows Subsystem for Linux (WSL) feature then you can installing the Azure CLI in the linux subsystem using [apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest).

**💬 Note.** Use of the legacy Windows CMD prompt is not advised, and use of alternative bash systems (gitbash or cygwin) is discouraged.

----------

[**💻 Visual Studio Code**](/guides/vscode){:target="_blank" class="btn-info"}

Please install and configure Visual Studio Code as per the link in the button above.  We won't be writing any real code, but the editor has some great support for editing the .tf files used by Terraform and integrating with Azure.

**Extensions**

The following extensions should also be installed as they are assumed by the labs:

**Module Name** | **Author** | **Extension Identifier**
Azure Account | Microsoft | [ms-vscode.azure-account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
Terraform | Mikael Olenfalk | [mauve.terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)
Ansible | Microsoft | [vscoss.vscode-ansible](https://marketplace.visualstudio.com/items?itemName=vscoss.vscode-ansible)
JSON Tools | Erik Lynd | [eriklynd.json-tools](https://marketplace.visualstudio.com/items?itemName=eriklynd.json-tools)

Use `CTRL`+`SHIFT`+`X` to open the extensions sidebar.  You can search and install the extensions from within there.

**Integrated Console**

For Windows Subsystem for Linux users then switch your integrated console from the default $SHELL (either Command Prompt or PowerShell) to WSL. Open the Command Palette (`CTRL`+`SHIFT`+`P`) and then search for the convenience command **Select Default Shell**.

**Git**

You will need Git installed at the _operating system_ level. (Linux and macOS should have this already (`which git`) if you have followed the steps above.)

Visual Studio Code will not find the git executable in WSL on Windows 10, so you need to install it and ensure that it is in the _system_ path.  (As vscode also won't find it in the user path.)

You can download and install Git for Windows by following the instructions [here](https://azurecitadel.github.io/guides/git/).

You can check where Git has been installed in Windows 10 by running either:

* Command Prompt: `where git`
* PowerShell: `Get-Command git.exe | Select-Object -ExpandProperty Definition`

It will normally be in the `C:\Program Files\Git\cmd\` directory.

Check that the directory is in your system path by clicking **Start → Run** and typing `SystemPropertiesAdvanced`. This will open the dialog box. Select **Path** in the system variables at the bottom, and then **Edit**. Add the directory if it is missing.

----------

[**💻 Join GitHub**](https://github.com/join){:target="_blank" class="btn-info"}

**Required for lab 3 onwards.**

For lab 3 onwards we will use a public repository in GitHub so you will need to have a GitHub account.

## Assumptions

A good working knowledge of the Azure services and ecosystem has been assumed.

----------

## Labs

**Lab** | **Name** | **Description**
1 | [Basics](lab1) | Use the basic Terraform workflow in Cloud Shell
2 | [Variables](lab2) | Provision from within VS Code and start to use variables
3 | [Core Environment](lab3) | Use a GitHub repo and provision a core environment
4 | [Meta Parameters](lab4) | Make use of copy and other meta parameters
5 | [Multi Tenancy](lab5) | Using Service Principals and Managed Service Identity
6 | [State](lab6) | Configuring remote state and using read only state in split environments
7 | [Modules](lab7) | Learn about modules, converting your .tf files, Terraform Registry
8 | [Extending beyond ARM](lab8) | Use providers and the AAD API to fully configure a kubernetes cluster
9 | [Provisioners](lab9) | Leverage provisioners to customise your virtual machine deployments (_coming soon_)

**💬 Note.** The labs are currently being built and will become available over the coming month.