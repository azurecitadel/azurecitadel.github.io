---
title: "Azure Policy and Initiatives"
date: 2019-03-25
author: [ "Tom Wilde", "Richard Cheney" ]
category: automation
comments: true
featured: false
hidden: false
published: false
tags: [ policy, initiative, compliance, governance ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "policy"
excerpt: Governance starts with policy compliance. Work through these labs to make Azure Policy and Initiatives work for you.
---

## Introduction

If you don't have standards in IT, things can get out of control and there's no change in cloud. In fact, there's more of a need for governnce than ever, if you don't have it in cloud it could cause allot of issues, excessive costs, issues supporting and a bad cloud experience to name a few. Azure Policy is essentially designed to help set those standards on Azure use (using policies), making sure it's used in the right way highlighting issues (using compliance) and help fix those issues (using remediation).

You can manually create policies (to check Azure resources are configured in a certain way) or you can use the growing number of pre-built policies.



## Pre-requisites

[**Azure Subscription**](/prereqs/subscription){:target="_blank" class="btn-info"}

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

[**💻 Azure CLI**](https://aka.ms/GetTheAzureCli){:target="_blank" class="btn-info"}

For Windows, Linux and macOS users, click on the button above to find the right install instructions to install at the operating system level.

For Windows 10 users who have enabled the Windows Subsystem for Linux (WSL) feature then you can installing the Azure CLI in the linux subsystem using [apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest).

**💬 Note.** Use of the legacy Windows CMD prompt is not advised, and use of alternative bash systems (gitbash or cygwin) is discouraged.

----------

[**💻 Visual Studio Code**](/prereqs/vscode){:target="_blank" class="btn-info"}

Recommended for editing.

## Assumptions

Read through the [Azure Policy](https://docs.microsoft.com/en-gb/azure/governance/policy/overview) documentation area for your foundational knowledge.

----------

## Labs

**Lab** | **Description**
1 | [Using Deny](lab1) | Use a simple policy to stipulate the permitted regions
2 | [Using Audit](lab2) | Specify allowed VM SKU sizes using Azure CLI
3 | [Initiatives](lab3) | Using a policy initiative DeployIfNotExist for automatic agent deployment
4 | [Using Deploy](lab4) |
5 | [Remediation](lab5) | Reporting and remediating non-compliant resources
6 | [Resource Tagging](lab6) | Create a set of policies for custom tagging
7 | [Resource Naming](lab7) | Custom policy to enforce a naming convention
8 | [Custom Initiatives](lab8) | Create a custom initiative for the tagging and naming policies
9 | [ARM and Terraform](lab9) | Assign the monitoring and custom initiatives to the subscription

**💬 Note.** The labs are currently being built and will become available over the coming month.