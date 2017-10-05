---
layout: article
title: CLI 2.0, Bash and JMESPATH Tech Primer
date: 2017-10-04
categories: guides
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
excerpt: Delve into CLI 2.0 and understand how to work with the interface, integrate with Bash scripts and work with the JMESPATH queries. 
---
WORK IN PROGRESS

{% include toc.html %}

## Introduction

Azure is flexible in offering a number of different interfaces, from the Azure Portal, to the PowerShell and CLI 2.0 command line interfaces, the various SDKs for languages such as Python, Node.js, Ruby etc. and finally the REST API.  The aim is to enable admins, power users and developers to use the interfaces that are most natural for them, rather than force them down a particular path.

This self paced tech primer is for CLI 2.0, the second iteration of a Bash compliant command line interface.  CLI 2.0 is designed to be natural for those coming from the Linux and Unix world with an interface that integrates well with Bash scripting, and the JSON outputs also fit well with the data constructs within languages such as Python and Perl.

Working through this lab will give you some of the tools to unleash the power of CLI 2.0 and Azure itself.

## Set Up

* It is assumed that you have an [Azure subscription]({{ site.url }}/guides/prereqs/subscription) 
* To access CLI 2.0 then either
  * Use the **Cloud Shell** (**>_**) in the [Azure portal](https://portal.azure.com)
  * [Install CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) locally into your operating system

The Cloud Shell is an important feature for the portal.  As it is built into the browser, it is accessible from anywhere. As well as the browser, Cloud Shell is also in the apps available for both iOS and Android.  Cloud Shell automatically logs into Azure, is always up to date, and any scripts that you create can be persistently held within the storage account that is automatically mounted to /clouddrive.  This provides a lot of power and control for mobile users.

However, for Linux based systems such as Ubuntu, Debian, Red Hat and, arguably, macOS, then having the az CLI installed locally and available in the native termainals is very natural. 

The Ubuntu subsystem within Windows 10 is highly recommended for power users. Follow the [install instructions]({{ site.url }}/guides/prereqs/lxss) to get the Linux subsystem enabled as a feature and CLI 2.0 installed. You can open up Bash either using the dedicated Start Menu option, typing ```bash``` into a Command Prompt or Win+R then ```bash```. 

For Windows 7, 8 and 8.1 users then the Cloud Shell is recommended for this lab.

## Updating CLI 2.0

Cloud Shell will always be current and does not need to be updated.

For the locally installed versions then the innovation on Azure is reflected in the frequent updates made to CLI 2.0 and therefore it is good practice to update regularly.  Depending on your package manager then the command to update all packages is shown below:

| **OS** | **Package Manager** | **Command** |
| macOS | brew | ```brew upgrade```|
| Ubuntu | apt-get | ``` sudo apt-get update && sudo apt-get dist-upgrade``` |
| RHEL, Fedora, CentOS | yum | ```yum check-update && sudo yum update``` |
| openSUSE, SLE | zypper | sudo zypper refresh && sudo zypper update |

Note that these commands will update all packages, not just the azure-cli package.

## First Steps
### Logging into Azure 

Log into Azure using ```az login```.  

You will be prompted to enter a code into the http://aka.ms/devicelogin and then authenticate the session.  The session tokens survive for a number of days so if you are using a shared machine then always issue ```az logout``` at the end of your session.

If you have multiple subscriptions linked to different IDs then browser cache and cookies can cause issues.  If that occurs then start an InPrivate or Incognito window and authenticate within that.

Note: Most terminals support copy (of selected text) and paste with either the right mouse button, or CTRL-INS / SHIFT-INS.  For instance, in the Windows Bash shell you can double click the code to select it then right click to copy.

### Orientation  

* ```az``` shows the main help and list of the commands
* ```az <command> --help``` shows help for that command
  * if there are subcommands then you can use the ```--help``` or ```-h``` at any level
  * the [CLI 2.0 reference](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) has a description of the available commands and parameters 
* ```az configure``` initiates an interactive session to configure defaults for your output format, logging of sessions, data collection.  
* ```az configure --default group=myRG location=westeurope```