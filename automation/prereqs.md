---
title: "Prereqs"
date: 2019-06-12
author: Richard Cheney
category: automation
comments: true
featured: true
hidden: false
published: true
tags: [ "prereqs", "automation" ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
excerpt: Standard machine configuration for the automation labs
---

## Introduction

The labs in the automation category are intended to be complementary to each other. We have evolved a preferred set of tooling which is assumed for the labs.  Therefore it makes sense to consolidate the prereqs into one area so that you can get your machine set up once. It also means that our intro pages for the labs can be shorter!

We are a broad church and happy that different users use different systems and preferred tooling.  (We like to test the waters with multiple OS and editing and provisioning tools ourselves.)  If you are comfortable installing and using other tools then don't feel that we are restricting you.  (Although if you're hoping for lots of PowerShell and Windows VMs then you might be in the wrong place; we do have a linux focus here.)

Standard caveats and disclaimers apply:

* some of the labs will assume certain tools are installed
* some of the code examples assume you've added the packages we suggested
* you can't expect us to become a support function for any issues you have with your particular setup!

OK, here is the tooling we tend to use:

## Pre-requisites

You will need a linux terminal environment. If you have macOS or linux desktop then great, you're there.  Windows 10 users then you need to install the Windows Subsystem for Linux (install instructions below).  If you are stuck on Windows 7 then you can stand up a linux VM.  You can start from a standard platform image such as Ubuntu 18.04 LTS, or use a marketplace image such as the ones for Terraform and Ansible.

----------

[**Azure Subscription**](/prereqs/subscription){:target="_blank" class="btn-info"}

**Required for all labs.**

You will need access to a subscription (with 'contributor rights'), or an Azure Pass or free account. Click on the button above for more details.

Ensure that it is active by logging onto the [portal](http://portal.azure.com) and creating an resource group.

**💬 Note.** If you are using an Azure Free Pass then please do not activate it using your work email address.  If you do then it will be unlikely that you will have RBAC permissions to create Service Principals and you will be limited to using the Azure CLI authentication.

----------

[**Windows Subsystem for Linux**](https://azurecitadel.github.io/guides/wsl/){:target="_blank" class="btn-info"}

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

[**💻 Azure CLI**](https://aka.ms/GetTheAzureCli){:target="_blank" class="btn-info"}

For Windows, Linux and macOS users, click on the button above to find the right install instructions to install at the operating system level.

For Windows 10 users who have enabled the Windows Subsystem for Linux (WSL) feature then you can installing the Azure CLI in the linux subsystem using [apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest).

**💬 Note.** Use of the legacy Windows CMD prompt is not advised, and use of alternative bash systems (gitbash or cygwin) is discouraged.

----------

[**💻 Terraform**](https://www.terraform.io/downloads.html){:target="_blank" class="btn-info"}

Needed for the Terraform labs.

* Manually download the correct executable from the link above
* Manually move it to a directory in your OS' path

> Note that for Windows that will need to be in your system path, e.g. `C:\Windows\System32\`. Visual Studio Code does not search the Windows user path.

* For linux systems (including the WSL) that use apt as the package manager you may use the following command to download it to /usr/local/bin:

```bash
curl -sL https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/automation/terraform/installLatestTerraform.sh | sudo -E bash -
```

* Run `terraform --version` to verify

----------

[**💻 Packer**](https://www.packer.io/downloads.html){:target="_blank" class="btn-info"}

Used in the virtual machine image creation labs.

The approach is the same for Packer as it is for Terraform. You may use the following to automate the install:

```bash
curl -sL https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/automation/images/installLatestPacker.sh | sudo -E bash -
```

----------

[**💻 Visual Studio Code**](/prereqs/vscode){:target="_blank" class="btn-info"}

Please install and configure Visual Studio Code as per the link in the button above.

**Extensions**

The following extensions should also be installed as they are assumed by the labs:

**Module Name** | Labs | **Author** | **Extension Identifier**
Azure Account | All | Microsoft | [ms-vscode.azure-account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
JSON Tools | All | Erik Lynd | [eriklynd.json-tools](https://marketplace.visualstudio.com/items?itemName=eriklynd.json-tools)
Azure Resource Manager Tools | ARM | Microsoft | [msazurermtools.azurerm-vscode-tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)
Terraform | Terraform | Mikael Olenfalk | [mauve.terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)
Advanced Terraform Snippets Generator | Terraform | Richard Sentino | [mindginative.terraform-snippets](https://marketplace.visualstudio.com/items?itemName=mindginative.terraform-snippets)
Ansible | Images | Microsoft | [vscoss.vscode-ansible](https://marketplace.visualstudio.com/items?itemName=vscoss.vscode-ansible)

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

Certain labs will use a public repository in GitHub so you will need to have a GitHub account for those.
