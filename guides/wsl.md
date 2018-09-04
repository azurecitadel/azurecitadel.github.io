---
layout: article
title: Windows Subsystem for Linux
date: 2018-08-29
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, ubuntu, wsl, lxss]
comments: true
excerpt: Set up Ubuntu, OpenSUSE or SLES as your Windows subsystem for Linux (WSL).
author: Richard_Cheney
image:
  feature:
  teaser: cloud-tools.png
  thumb:
---

## Enable the Windows Subsystem for Linux

First, click on the button below to open the instructions to enable the Windows Subsystem for Linux itself.  There are now a choice of distros from the Windows Store (Ubuntu, OpenSUSE and SLES).  If you do not have a preference then Ubuntu is a good option.

[**Windows Subsystem for Linux**](https://docs.microsoft.com/en-gb/windows/wsl/install-win10){:target="_new" class="btn-info"}

----------

It is then recommended to install some of the commonly used binaries into the linux subsystem if you are working with Azure. It is common to install the az cli, jq, git and terraform binaries at both the Windows 10 OS level and to then also install them into the linux subsytem as well.)

> This guide will detail the commands to install the binaries into the Windows Subsystem for Linux, and it has been assumed that you are using Ubuntu, which uses apt as the package manager.  If you selected a different distro then search online for the package manager commands for that distribution.

----------

## az

* Follow the instructions at <https://aka.ms/GetTheAzureCLI> to download the Azure CLI 2.0

Verify the installation

* Type `az` to show the base commands
* Type `az login` and follow the instructions to log in to Azure
* Type `az account list` to show the subscription info in JSON output format

----------

## Installing git, jq and tree packages

There are a few standard packages that are useful to have installed.  You may have your own preferred packages to add to the list.

* Open up a Command Prompt, and type `bash`.
* Update the package list and then install the desired packages
    * `sudo apt update && sudo apt --assume-yes install git jq tree`
* Verify by going into the bash shell and typing `jq` or `git` to see the base commands
* Check that tree is there by running `which tree`

> Note that you should also install git at the Windows 10 OS level if you wish to use the SCM functionality in Visual Studio Code.

----------

## Terraform

Terraform is not installed using a package manager.

The manual installation path is to go to the Terraform [downloads](https://www.terraform.io/downloads.html) page, download the 64 bit linux version and place it in the path.

If you are trusting then you can run the following script to download the latest version and install into /usr/local/bin.  You will be prompted for your password as the script uses sudo. Note that it will install zip if that is not present on the system. (Triple click to select the whole line.)

```bash
curl -sL https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/workshops/terraform/installLatestTerraform.sh | sudo -E bash -
```

* Verify by running `which terraform` and `terraform --version`

----------

## *Optional*: Change font and vi colours

The default colours for both the PS1 prompt and for vi and vim can be difficult to read.  If you find that to be the case then follow the instructions below.

* Edit ~/.bashrc (using nano, vi, or vim) and then scroll to the color_prompt section.
    * The PS1 prompt colours are set in the sections that are in the format `[01:34m\]`.  The 34 is light blue, which is hard to read.  Changing the number from 34 to 36 (cyan) or 33 (yellow) will be more readable. (Info from [here](http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html).)
* For vi(m) users then creating a .vimrc file will also help to set a more readable colour scheme

```bash
umask 022
echo -e "colo murphy\nsyntax on" >> ~/.vimrc
```