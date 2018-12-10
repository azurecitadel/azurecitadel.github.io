---
layout: article
title: Azure PowerShell Module
date: 2018-10-30
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, template]
comments: true
author: Richard_Cheney
excerpt: Instructions to update PowerShell and add in the Az module.
image:
  feature:
  teaser: cloud-builder.png
  thumb:
---

## Overview

Add a module to PowerShell to add cmdlets for Azure.  The older AzureRm module has been replaced with a newer Az module.  This shortens the cmdlets and works with PowerShell Core and Cloud Shell.

Note that the Az module will only reach full parity with the AzureRm module during November.  But the most common commands are already there and it can be configured with aliases so that existing scripts will work.

> If you are concerned by this then leave the page and follow the [AzureRm installation instructions](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps).

The Az module will have parity with AzureRm in November 2018, and no more updates will be applied to the AzureRm module after December 2018.

## Open PowerShell as Administrator

All current Windows desktop operating systems have PowerShell installed.

Right click either the PowerShell prompt or the PowerShell ISE, and Run as Administrator.  This whole guide assumes that you are running PowerShell as Administrator.

### Ensure PowerShellGet is installed

PowerShellGet is included in Windows Management Framework 5, which includes PowerShell 5.x. Most versions of Windows 10 have this installed by default.

* Run `Get-Module PowerShellGet -list | Select-Object Name,Version,Path` to confirm that PowerShellGet is installed and the version is 1.0.0.1 or later
* If PowerShellGet is not installed, then install [WMF 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395)

## List and remove any AzureRm modules

All versions of the AzureRm module should be removed before installing the Az module.

* List any installed AzureRM modules using `Get-Command -Module AzureRM -ListAvailable`. TEST
* For each version, run `Uninstall-AllModules -TargetModule AzureRM -Version <X.X.X> -Force`.

## Set ExecutionPolicy

* List out the current ExecutionPolicy using `Get-ExecutionPolicy -List | Format-Table -AutoSize`.
* If the LocalMachine scope is Undefined then
    * Run `Set-ExecutionPolicy RemoteSigned` and say `Yes`.

Example `Get-ExecutionPolicy -List | Format-Table -AutoSize` output:

```powershell
PS C:\Windows\system32> Get-ExecutionPolicy -List | Format-Table -AutoSize

        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser       Undefined
 LocalMachine    RemoteSigned
```

## Install and Import the Az PowerShell module

You need to install and then load the module:

* `Install-Module -Name Az`
* `Import-Module -Name Az`
* `Get-Module -Name Az` to confirm which version of the module is loaded
* Type `Login-AzAccount`, follow the dialog to log in and show the subscription name

## Add the AzureRm alias

The AzureRm aliases ensures that older scripts will continue to run without having to refactor all of the cmdlets.

* `Enable-AzureRmAlias`

Test that `Get-AzContext` and `Get-AzureRmContext` will both work and show the same output.