---
layout: article
title: Configuring Cloud Shell
date: 2018-05-18
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, cloud, shell]
comments: true
author: Richard_Cheney
excerpt: Tweak those Cloud Shell colours!
image:
  feature: 
  teaser: cloud-lab.png
  thumb: 
---

One of the attractions of using the Azure Cloud Shell is that there is little configuration required.  The containers for both Bash and PowerShell are evergreen, and you can access it from the portal, via <https://shell.azure.com>, from the Azure mobile app for iOS and Android, and also from VS Code using the Azure Account extension.

You cannot install software into the Bash Cloud Shell, but it has a number of [tools](https://docs.microsoft.com/en-gb/azure/cloud-shell/features#tools) preinstalled including az, azcopy, terraform, ansible, git, jq, docker, kubectl, helm, etc.

There are two areas are persisted to the storage account that is automatically created when you use Cloud Shell for the first time:

1. /home/\<user> directory
2. /usr/\<user>/clouddrive (symlinked to ~/clouddrive/)

Note that the clouddrive area is based on Azure Files, and therefore everything will show as 777.  You can also upload files into the area via a number of tools including [Storage Explorer](https://azure.microsoft.com/en-gb/features/storage-explorer/).

## Configuring vi colours

The default cloud shell colours for vim are difficult to read.

As a quick fix you can type `Esc :` and then `colo delek` to switch to a more readable colourscheme.

If you want a colourscheme that more closely resembles the main cloud shell colours then run the following code block:

```bash
umask 022
mkdir --parents ~/.vim/colors
curl -o ~/.vim/colors/cloudshell.vim https://azurecitadel.github.io/guides/cloudshell/cloudshell.vim
echo > ~/.vimrc <<-EOF
    syntax on
    colorscheme cloudshell
EOF
```

This will download a .vim colourscheme file, and then create a .vimrc file to specify the new colourscheme.

## Configure the ls colours

The default colour for listing directories which are world writeable (777) is a rather lurid blue on green, which should never be seen.

If you run the following commands then it will create a dircolors file for you to edit.

```bash
umask 022
dircolors -p > ~/.dircolors
```

You may then edit the ~/.dircolors file using vi or nano and change the `STICKY_OTHER_WRITABLE` and `OTHER_WRITABLE` values to something like `01;33` which will be bold yellow on black.

If you want to customise it further then the .dircolors file includes the codes and their impact.