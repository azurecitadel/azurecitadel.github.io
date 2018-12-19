---
layout: article
title: CLI 2.0 Setup
date: 2017-10-04
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
previous:
  url: ../../cli
  title: Back to CLI 2.0 Overview page
next:
  url: ../cli-2-firststeps
  title: First Steps with CLI 2.0
---
{% include toc.html %}

## Installation

* It is assumed that you have an [Azure subscription]({{ site.url }}/guides/subscription) 
* To access CLI 2.0 then either
  * Use the **Cloud Shell** (**>_**) in the [Azure portal](https://portal.azure.com)
  * [Install CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) locally into your operating system

The Cloud Shell is an important feature for the portal.  As it is built into the browser, it is accessible from anywhere. As well as the browser, Cloud Shell is also in the apps available for both iOS and Android.  Cloud Shell automatically logs into Azure, is always up to date, and any scripts that you create can be persistently held within the storage account that is automatically mounted to /clouddrive.  This provides a lot of power and control for mobile users.

However, for Linux based systems such as Ubuntu, Debian, Red Hat and, arguably, macOS, then having the az CLI installed locally and available in the native termainals is very natural and convenient. 

The Ubuntu subsystem within Windows 10 is highly recommended for power users. Follow the [install instructions]({{ site.url }}/guides/wsl) to get the Linux subsystem enabled as a feature and CLI 2.0 installed. You can then open up Bash using either the dedicated Start Menu option, typing ```bash``` into a Command Prompt or Win+R then ```bash```. 

For Windows 7, 8 and 8.1 users then the Cloud Shell is recommended for this lab.

## Updating CLI 2.0

**Note that Cloud Shell will always be current and does not need to be updated.**

The level of innovation on Azure is reflected in the frequent updates made to CLI 2.0 and therefore it is good practice to update local installs regularly.  Depending on your package manager then the command to update all packages is shown below:

**OS** | **Package Manager** | **Command**
macOS | brew | ```brew upgrade```
Ubuntu | apt-get | ``` sudo apt-get update && sudo apt-get dist-upgrade```
RHEL, Fedora, CentOS | yum | ```yum check-update && sudo yum update```
openSUSE, SLE | zypper | ```sudo zypper refresh && sudo zypper update```

Note that these commands will update all packages, not just the azure-cli package.