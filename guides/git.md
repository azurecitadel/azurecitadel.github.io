---
layout: article
title: Installing Git for Windows or Mac
date: 2018-01-23
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, template]
comments: true
author: John_Duckmanton
excerpt: Install Git client software for Windows or Mac.
image:
  feature: 
  teaser: cloud-lab.png
  thumb: 
---

The following instructions are for installing Git for Windows or Git for Mac client software.  

If you are installing Git into a Linux distro (including the Windows subsystem for Linux) then use the standard module install commands for the distribution.  For example, the commands for Ubuntu would be `sudo apt-get update && sudo apt-get install git`. 

## Download & Install the Git software

* Download & Install [Git for Windows](https://git-scm.com/download/win) or [Git for Mac](https://git-scm.com/download/mac)
    * In the installation wizard take the default options but ensure that the following selections are made:

        1. Select **Ensure the following options are selected**

        ![Git setup image](./git/images/git-installer-1.png)

        2. Ensure **Use Git for the Windows command Prompt** is selected

        ![Git setup image](./git/images/git-installer-2.png)

        3. Ensure **Enable Git Credential Manager** is selected

        ![Git setup image](./git/images/git-installer-3.png)

## Verify the Installation

* Verify that Git is correctly installed by opening a **CMD** or **PowerShell** window & entering the command `git --version`

  If you don't see any errors Git is correctly installed.

## Configure Git

* Open a **CMD** or **PowerShell** new window and run the following commands (substituting your details as required):

```bash
git config --global user.email "youralias@microsoft.com"
git config --global user.name "Your Name"
git config --global credential.helper manager
```

