---
layout: article
title: Azure PowerShell Module
date: 2018-01-23
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, template]
comments: true
author: Richard_Cheney
excerpt: Instructions to update PowerShell and add in the AzureRM module.
image:
  feature: 
  teaser: cloud-builder.png
  thumb: 
---

## Overview

Extend PowerShell functionality by adding in the Azure module, plus CLI 2.0

## Install the Azure PowerShell Module

### Open PowerShell as Administrator

All current Windows desktop operating systems have PowerShell installed.  Open up either the PowerShell prompt, or the PowerShell ISE (interactive scripting environment) as an Administrator.  (Note that PowerShell is also available for Linux and MacOS.)

### Install PowerShellGet

PowerShellGet is included in Windows Management Framework 5, which includes PowerShell 5.x.
* Run `Get-Module PowerShellGet -list | Select-Object Name,Version,Path` to confirm that PowerShellGet is installed and the version is 1.0.0.1 or later  
* If PowerShellGet is not installed, then install [WMF 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395)

### Install or Update Azure PowerShell
Make sure that PowerShell is still open with admin privileges. 
* Run `Install-Module AzureRM`
* If the AzureRM module is already installed, then update with `Update-Module AzureRM`
* The available versions may be listed using `Get-Module AzureRM -ListAvailable`
* Older versions may be uninstalled using `Uninstall-Module AzureRM -RequiredVersion 3.3.0`, where 3.3.0 is the version of the AzureRM module being uninstalled

## Verify the module installation
Note that the AzureRM module isn’t imported by default.
* Typing `Import-Module AzureRM` will import the module for use (note possible error below)
* If there are multiple versions of the module side by side then the version may be specified using, for example, `Import-Module AzureRM -RequiredVersion 3.8.0`
* `Get-Module AzureRM` will confirm if the module is loaded and which version number
* `Get-Command -Module AzureRM` will list all the available AzureRM commands
* Type `Login-AzureRmAccount` and follow the dialog to log in andl show the subscription name

NB. If you receive a PowerShell execution error, then check your Execution Policy settings using `Get-ExecutionPolicy -List | Format-Table -AutoSize`.  The `Set-ExecutionPolicy RemoteSigned` command should set the correct policy.

The instructions are taken from [https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps).

## Install Azure CLI (optional)

* Download the [Azure CLI installer(MSI)](https://aka.ms/InstallAzureCliWindows) and run it.
* Check that the `az` commands works within PowerShell

