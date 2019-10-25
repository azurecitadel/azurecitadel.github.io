---
title: Configuring Cloud Shell
date: 2018-05-18
author: Richard Cheney
category: prereqs
header:
  teaser: /images/teaser/cloud-lab.png
excerpt: Tweak those Cloud Shell colours!
comments: true
---

One of the attractions of using the Azure Cloud Shell is that there is little configuration required.  However the default colours are not the most readable, so feel free to use the commands below to change them.

## Cloud Shell Background

You can access the Cloud Shell from:

* the Azure portal (**>_**)
* <https://shell.azure.com>
* the Azure mobile app for iOS and Android
* from VS Code using the Azure Account extension

The Cloud Shell container image for Bash has a good number of [tools](https://docs.microsoft.com/en-gb/azure/cloud-shell/features#tools) preinstalled including az, azcopy, terraform, ansible, git, jq, docker, kubectl, helm, etc. The containers for both Bash and PowerShell are evergreen, so you never need to worry about updating the software packages.  Which is good as you do not have sudo access, and you cannot install software.

Two areas are persisted to the storage account that is automatically created when you use Cloud Shell for the first time:

1. /home/\<user> directory
2. /usr/\<user>/clouddrive (symlinked to ~/clouddrive/)

Note that the clouddrive area is based on Azure Files and mounted using SMB.  All files and directories in that area will have 777 permissions as defined by the mount options, to keep the file ownership simple.  You can upload files into the area via a number of tools including [Storage Explorer](https://azure.microsoft.com/en-gb/features/storage-explorer/).

## Configuring vi colours

The default cloud shell colours for vi are difficult to read.

As a quick fix you can type `Esc :` and then `colo delek` to switch to a more readable colourscheme.

If you want a colourscheme that more closely resembles the main cloud shell colours then run the following code block:

```bash
umask 022
mkdir --parents ~/.vim/colors
curl -o ~/.vim/colors/cloudshell.vim https://azurecitadel.com/prereqs/cloudshell/cloudshell.vim
cat > ~/.vimrc <<EOF
syntax on
colorscheme cloudshell
EOF
```

This will download a .vim colourscheme file, and then create a .vimrc file to specify the new colourscheme.

## Configure the ls colours

The default colour for listing directories which are world writeable (777) is a rather lurid blue on green, which should never be seen. It is an intentionally garish combination designed to encourage you to specify a more appropriate permission. However, this is the enforced permission for the clouddrive files and directories. Here is how you can make listing the clouddrive a little less headache inducing.

Run the following commands to create a dircolors file.

```bash
umask 022
dircolors -p > ~/.dircolors
```

You may then edit the new ~/.dircolors file using vi or nano and change the `STICKY_OTHER_WRITABLE` and `OTHER_WRITABLE` values to something like `01;33` which will be bold yellow on black.

If you want to customise it differently then the .dircolors file includes the various codes and their impact.

You will see the change take effect the next time you log in.  Or you can type `source ~/.bashrc` to make it take effect immediately.
