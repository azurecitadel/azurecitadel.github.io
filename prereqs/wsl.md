---
layout: article
title: Windows Subsystem for Linux
date: 2018-10-22
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, ubuntu, wsl, lxss]
comments: true
excerpt: Set up Ubuntu, OpenSUSE or SLES as your Windows subsystem for Linux (WSL). Now with additional customisations!
author: Richard Cheney
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

## *Optional*: Customisations

Customisation is a personal thing, so feel free to use any, all or none of the following.

They are included as you may find that the out of the box colours for both the PS1 prompt and for vi(m) can be difficult to read.  Also some of the labs use git commands locally so the revised PS1 prompt below will show when you are in a repo and which branch you are on.

### Modified colours for new Windows console

The new console is used by Command Prompt and by the WSL linux distros such as Ubuntu.  It is a significant ground up [rework](https://blogs.msdn.microsoft.com/commandline/tag/console/), and is a great improvement on the old console.

You can easily customise the colour scheme for it.  Download [colortools](https://github.com/Microsoft/console/releases) and extract.  The [blog page](https://blogs.msdn.microsoft.com/commandline/2017/08/11/introducing-the-windows-console-colortool/) shows how to use it, but essentially you use `colortools.exe -b <file>` in Command Prompt (or PowerShell).  The file must either be an .ini file or an .itermcolors file, which is used by consoles such as MacOS' iTerm2.

The colortools download will include a few files, but you can also find [repositories](https://github.com/mbadolato/iTerm2-Color-Schemes) full of itermcolors files.

Or you can customise and then export your own ini files in the console, such as this [Nord Extra Dark colour scheme](https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/prereqs/wsl/nord-extra-dark.ini), which is close to the extension in vscode. Right click the link and save alongside the other schemes, and then you can use `.\colortools.exe -b nord-extra-dark` to set.

### Updated PS1 prompt

* Go to your home directory using `cd`.
* Backup your .bashrc file using `cp -p .bashrc .bashrc-backup`.
* Download git-prompt.sh

```bash
umask 022
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > ~/.git-prompt.sh
```

* Run the following to add a couple of lines to the bottom of your .bashrc

```bash
cat << EOF >> ~/.bashrc

source ~/.git-prompt.sh
export PS1='\[\033[01;32m\]\w\[\033[01;33m\]$(__git_ps1 " (%s)") \[\033[01;37m\]\$ '
EOF
```

* Source your profile to see the change: `source ~/.bashrc`

You will need to move to a local git repo to see the branch within the prompt.

There is online documentation available if you want to customise the [colors]((http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html)) or [content](https://help.ubuntu.com/community/CustomizingBashPrompt) of the PS1 string.

### Customised vi(m)

If you are used to editing with vi then add the following lines are in your .bashrc:

```bash
export EDITOR=vi
set -o vi
```

You can also select the colour scheme for legibility:

```bash
umask 022
echo -e "colo delek\nsyntax on" >> ~/.vimrc
```

Or create a custom one, e.g.:

```bash
umask 022
mkdir -p ~/.vim/colors
curl https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/prereqs/wsl/cloudshell.vim > ~/.vim/colors/cloudshell.vim
echo -e "colo cloudshell\nsyntax on" >> ~/.vimrc
```

### Customised ls colours

With WSL you will notice that anything in /mnt/c will appear to linux as if it has 777 permissions.  This is highlighted as insecure in the coloured ls output with an angry looking colour scheme. This can reduce legibility, so if you want to customise that then feel free to run the following commands to customise the output.

```bash
umask 022
curl https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/prereqs/wsl/.dircolors_cloudshell > ~/.dircolors
source ~/.bashrc
ls -lrt --color=auto /mnt/c/Users/$LOGNAME/Downloads
```