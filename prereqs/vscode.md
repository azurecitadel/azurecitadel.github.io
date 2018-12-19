---
title: Visual Studio Code
date: 2018-06-27
author: Richard Cheney
category: prereqs
tags: [vs2017]
comments: true
header:
  teaser: /images/teaser/code.jpg
excerpt: Install and configure the lightweight vscode and set up Git and Azure CLI for the integrated console
---

## Visual Studio Code

Visual Studio Code is a free alternative source code editor to Visual Studio.  It is a smaller, more lightweight, and cross platform application.  Visual Studio Code (VS Code) is optimized for building and debugging modern web and cloud applications but may also be used for ARM template authoring.

Whilst VS Code is not as tightly integrated with Azure as Visual Studio, it does includes IntelliSense code completion and colour coding for JSON templates.  It can be integrated further by adding the Azure Resource Manager Tools extension.  And you can then make use of the Azure quickstart templates on GitHub and the ARM template references for the various Azure service providers on the Azure docs site.

The instructions also link to the recommended setup for both Ubuntu on Windows 10, and for PowerShell.    The PowerShell configuration will add in both the PowerShell Azure Modules (AzureRM), and also the CLI commands.  The Ubuntu configuration will give you the ability to run the CLI commands, but also to wrap them with Bash shell scripts.

## Summary of Configuration

This guide will run through a number of configurations that are recommended for the various labs.

Here is a summary:

1. [Visual Studio Code](#install-visual-studio-code)
    * Install vscode from [https://code.visualstudio.com](https://code.visualstudio.com)
1. [Git](#install-git-for-windows)
    * Install [Git for Windows](https://git-scm.com/download/win)
    * Remove all Explorer integrations, file associations, and use Command Prompt as the shell
    * Check  `git` works in PowerShell (or Command Prompt)
    * If successful then Git should be the integrated SCM in Visual Studio Code
1. <a href="/guides/powershell" target="_blank">PowerShell</a>
    * Install the [Azure PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps)
    * Install the [Azure CLI installer (MSI)](https://aka.ms/InstallAzureCliWindows)
    * Check `az` works within PowerShell
1. <a href="/guides/wsl" target="_blank">Bash</a> (Windows 10 only)
    * Install Ubuntu into the Windows subsystem for Linux
    * Follow the instructions to add both git and the Azure CLI into the subsystem
1. [Integrated Console](#integrated-console)
    * Bash (Windows 10)
    * PowerShell

There are also some additional sections with some optional personalisation configuration.

## Install Visual Studio Code

Install VS Code from [https://code.visualstudio.com](https://code.visualstudio.com).

## Install Git for Windows

For Git to be recognised as an SCM (source code management) provider, VS Code needs to be able to find the git executable in the PATH.

> Currently VS Code will not find git if you have only installed the Windows Subsystem for Linux and then installed git into the Bash shell. If you type `git` into either the Command Prompt or a PowerShell window then it will not be found.

If you have a Windows desktop OS then install [Git for Windows](https://git-scm.com/download/win) if you have not done so already. Recommended settings:

* **Unselect the checkboxes for Windows Explorer integration and file associations**
* Use Git from the Windows Command Prompt (default)
* Use OpenSSH (default)
* Use the OpenSSL library (default)
* Checkout Windows-style, commit Unix-style endings (default)
* **User Windows' default console window**
* Retain all extra options (caching, Git Credential Manager, symbolic links)

> Note that there is a newer and less intrusive Git installation on the [GitHub Desktop](https://desktop.github.com/) page, but this does not integrate well with VS Code and is therefore not recommended.

Open a Command Prompt and check that `git` produces command help output.

>Note that if you have 2FA enabled on your GitHub account then you will need a [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). Use that in place of the password upon first clone or sync action.

## Install Azure CLI

Install the Azure CLI 2.0 from [https://aka.ms/GetTheAzureCLI](https://aka.ms/GetTheAzureCLI) into your base operating system.

Open a Command Prompt and check that `az` produces command help output.

Type `az login` and follow the instructions to complete the authentication. Type `az account list` to confirm that you are logged in.

## Integrated Console

As per the [VS Code Integrated Console](https://code.visualstudio.com/docs/editor/integrated-terminal#_configuration) configuration information, the shell used by the Integrated Console defaults to:

**OS** | **Default Shell**
Windows 10 | PowerShell
Windows 7/8.x | Command Prompt
MacOS | $SHELL
Linux | $SHELL

Override the default by bringing up the Command Pallette (`CTR:`+`SHIFT`+`P`) and then type "default shell" to find **Terminal: Select Default Shell**.  You can then hit enter to select your preferred shell from a drop down.

## Personalisation

VS Code has great configuration and extensibility options to allow you to personalise it to your own preferences. The following information is therefore entirely optional, but is included for anyone who would like to emulate my VS Code configuration.

The settings cog at the bottom left allows you to select colour and icon themes, and to install new ones. As you can see from the settings file above my installation uses both the Material Theme (for the icons) and the Nord Theme (for the colour scheme).

I also hide the menu bar (which can be toggled back on temporarily using ALT), and I have disabled the minimap by default.

![Personalisation](/prereqs/vscode/images/personalised.png)

> Windows 10 also allows you to set custom colours for Windows' title bars in the Color Settings area.  Mine is set to 59, 66, 82, which is the same as the Nord background colour for the status bar.

## Using Visual Studio Code

Visual Studio Code is amazingly powerful and flexible.

It is highly recommended to spend a little time with the Help and Learn resources on the welcome page in order to familiarise yourself.

## Useful Keyboard Shortcuts

There are a huge number of shortcuts available in Help \| Keyboard Shortcuts Reference.  Here are some useful ones to learn:

### Managing The display

CTRL-B | Toggle Side Bar
CTLK-' | Toggle Integrated Console
F11 | Toggle full screen
CTRL-K, Z | Zen mode (2x ESC to exit)
CTRL-= | Zoom In
CTRL-- | Zoom Out

### Manipulating the layout

CTRL-ALT-LEFT, RIGHT | Move file in split layout
CRTL-\ | Split Editor
ALT-SHIFT-1 | Change editor group layout

### Navigation

CTRL-, | Settings
CTRL-SHIFT-E | File Explorer
CTRL-SHIFT-F | Find in Files
CTRL-SHIFT-G | Git
CTRL-SHIFT-X | Extensions
CTRL-SHIFT-P | Open Command Palette

### Shell commands

code . | Opens the current directory in vscode
code \<filename> | Opens filename as a tab
code azuredeploy.* | Opens the matched files as tabs

### Files

CTRL-P | Open from recent files
CTRL-TAB | Quick switch between open files
CTRL-S | Save
CTRL-W | Close active tab

### Cursor editing

CTRL-F2 | Select all occurrences of selected text
CTRL-ALT-UP, DOWN | Multiple vertically aligned cursors for block editing
ALT | Allow multiple cursors to be placed using the mouse
ESC | Come out of multiple cursor mode

### Editing

CTRL-F | Find dialog
CTRL-H | Replace dialog
CTRL-ALT-ENTER | Replace all

### Extensions

ALT-M / CTRL-ALT-M | Minify / prettify JSON using JSON Tools
CTRL-SHIFT-P | Open Command Palette for Git Clone, Terraform Apply, Open Bash in Cloud Shell etc.

### Cool stuff

* Enter in new filenames including new subdirectories and they will be automatically created
* Copy and paste a folder with a number at the end and the copy will be incremented
* Drag and drop within the Explorer and also between windows