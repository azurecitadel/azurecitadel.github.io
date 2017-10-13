---
layout: article
title: Workshop Pre-Requisites
date: 2017-07-04
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, template]
comments: true
author: Richard_Cheney
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
Windows 10 is able to run Ubuntu as a Linux Subsystem (lxss) to enable Bash.  These instructions detail how to:
* Install Bash
* Modify the apt-get sources
* Install CLI 2.0
* Configure for greater readability
* Add in git commands 

## Install Windows 10 Linux subsystem and CLI 2.0

There are many options for installing Azure CLI 2.0.  This section has **Windows 10** instructions for installing the Ubuntu Bash Linux subsystem on Windows 10 and configuring Azure CLI 2.0. 

### Install Bash on Windows

This requires 64 bit Windows 10 with Anniversary Update (minimum), Creators Update (highly recommended.) (Settings -> System -> About, OS Build >= 14393.)
* Turn on Developer Mode
  * Settings -> Update and Security -> For Developers
  * Click the radio button for Developer Mode
* Enable the Windows Subsystem for Linux, either
  * GUI: Select Windows Subsystem for Linux in “Turn Windows features on or off”
  * PowerShell (as Administrator): `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux`
  * Restart Windows

### Initialise Bash

* Run Bash on Windows by typing bash in a Command Prompt
* Accept the licence and type y to continue (it will be installed to %localappdata%\lxss\)
* Create a UNIX username and password (separate to your Windows username and password)

### Modify the apt sources 

* Add to the source list
```
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
```

* Add the key and https transport
```
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893

sudo apt-get install apt-transport-https
```
* Update the package list and then install Azure CLI 2.0
```
sudo apt-get update && sudo apt-get install azure-cli
```
### *Optional*: Change font and vi colours

The default colours for both the PS1 prompt and for vi and vim can be difficult to read.  If you find that to be the case then follow the instructions below.

* Edit ~/.bashrc (using nano, vi, or vim) and then scroll to the color_prompt section.  
  * The PS1 prompt colours are set in the sections that are in the format `[01:34m\]`.  The 34 is light blue, which is hard to read.  Changing the number from 34 to 36 (cyan) or 33 (yellow) will be more readable. (Info from [here](http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html).)
* For vi(m) users then creating a .vimrc file will also help to set a more readable colour scheme
```
umask 022

echo -e "colo murphy\nsyntax on" >> ~/.vimrc
```
Verify the installation
* Type `az` to show the base commands
* Type `az login` and follow the instructions to log in to Azure
* Type `az account list` to show the subscription info in JSON output format
 
### Add Git to the Windows 10 Linux Subsystem

Certain workshops make use of GitHub.  This section adds in git to the bash shell. 

* Run Bash on Windows by typing bash in a Command Prompt
* Ensure the package list is up to date and then install the basic Git tools
```
sudo apt-get update && sudo apt-get install git-all
```
* Verify by opening Git Bash from the Start Menu and typing `git` to see the base commands

#### Links to other pre-requisite instruction pages
 
* [Links to other pre-requisite instructions can be found here](../../prereqs)

