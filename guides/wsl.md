---
layout: article
title: Windows Subsystem for Linux
date: 2018-01-23
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

## Install Windows Subsystem for Linux

Follow the instructions to install the [Windows Subsystem for Linux](https://msdn.microsoft.com/en-us/commandline/wsl/install-win10).  

There are now a choice of distros from the Windows Store (Ubuntu, OpenSUSE and SLES).  If you do not have a preference then Ubuntu is a good option.

Note that after installation the Linux distribution will be located at: %localappdata%\\lxss\\.

## Install CLI 2.0

* Open up a Command Prompt, and type `bash`.
* Follow the instructions at https://aka.ms/GetTheAzureCLI.

Verify the installation
* Type `az` to show the base commands
* Type `az login` and follow the instructions to log in to Azure
* Type `az account list` to show the subscription info in JSON output format

## Add Git to the Windows 10 Linux Subsystem

Certain workshops make use of GitHub.  This section adds git to the bash shell. 

* Run Bash on Windows by typing bash in a Command Prompt
* Ensure the package list is up to date and then install the basic Git tools
`sudo apt-get update && sudo apt-get install git-all`
* Verify by going into the bash shell and typing `git` to see the base commands

> Note that apt-get is the package manager for Ubuntu.  If you selected a different distro then search online for the command to install git on that distro.

## *Optional*: Change font and vi colours

The default colours for both the PS1 prompt and for vi and vim can be difficult to read.  If you find that to be the case then follow the instructions below.

* Edit ~/.bashrc (using nano, vi, or vim) and then scroll to the color_prompt section.  
  * The PS1 prompt colours are set in the sections that are in the format `[01:34m\]`.  The 34 is light blue, which is hard to read.  Changing the number from 34 to 36 (cyan) or 33 (yellow) will be more readable. (Info from [here](http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html).)
* For vi(m) users then creating a .vimrc file will also help to set a more readable colour scheme

```bash
umask 022
echo -e "colo murphy\nsyntax on" >> ~/.vimrc
```