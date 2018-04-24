---
layout: article
title: Visual Studio Code
date: 2018-01-23
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, vscode]
comments: true
author: Richard_Cheney
image:
  feature: 
  teaser: code.jpg
  thumb: 
excerpt: Install and configure the lightweight VScode and set up Git and Azure CLI for the integrated console
---

{% include toc.html %}

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

To override the defaults, you can manually configure the settings.json.  Open up the settings by typing CTRL-, (or select File \| Preferences \| Settings). The system settings are shown in the left pane and the user overrides shown on the right.  The user overrides are in a standard JSON format containing name:value pairs separated by commas.

You can override the shell used by Windows in the integrated console by setting the **terminal.integrated.shell.windows** value:

Shell Location | Notes
"C:\\\\Windows\\\\System32\\\\cmd.exe" | Command Prompt
"C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" | 64-bit PowerShell if available, if not 32-bit
"C:/Windows/System32/bash.exe" | [Bash on Ubuntu](/guides/wsl) (Windows Subsystem for Linux (WSL) on Windows 10)

> Note that you should set the shell location to "C:/Windows/*sysnative*/bash.exe" for the 32 bit version of Visual Studio Code.

Note that pathing may use either forward or backslashes in the settings.json file, but backslashes will need to be escaped (i.e. \\\\).  The exception is Command Prompt which requires backslashes as shown.

The example settings file at the bottom of this page shows an example of the shell being overridden.

## Example settings.json

For reference, here is an example settings.json user override area:

```json
{
    "terminal.integrated.shell.windows": "C:/Windows/system32/bash.exe",
    // "terminal.integrated.shell.windows": "C:/Windows/system32/WindowsPowerShell/v1.0/powershell.exe",
    "editor.minimap.enabled": false,
    "window.zoomLevel": 1,
    "workbench.panel.location": "bottom",
    "window.menuBarVisibility": "toggle"
}
```

It is possible to open multiple terminal sessions by clicking on the *+* icon, and this is the reason that this settings file includes the commented fields with the additional shell paths.  If you change the terminal.integrated.shell.windows then you can open up sessions using different shells, as shown in the screenshot below:

![Multiple Shells](/guides/vscode/images/multipleShells.png)

Personalising VS Code using the menu options will also change this configuration file.

## Personalisation

VS Code has great configuration and extensibility options to allow you to personalise it to your own preferences. The following information is therefore entirely optional, but is included for anyone who would like to emulate my VS Code configuration.

The settings cog at the bottom left allows you to select colour and icon themes, and to install new ones. As you can see from the settings file above my installation uses both the Material Theme (for the icons) and the Nord Theme (for the colour scheme).

I also hide the menu bar (which can be toggled back on temporarily using ALT), and I have disabled the minimap by default.

![Personalisation](/guides/vscode/images/personalised.png)

> Windows 10 also allows you to set custom colours for Windows' title bars in the Color Settings area.  Mine is set to 59, 66, 82, which is the same as the Nord background colour for the status bar.

## Using Visual Studio Code

Visual Studio Code is amazingly powerful and flexible.

It is highly recommended to spend a little time with the Help and Learn resources on the welcome page in order to familiarise yourself.

## Useful Keyboard Shortcuts

There are a huge number of shortcuts available in Help \| Keyboard Shortcuts Reference.  Here are some useful ones to learn:

Keyboard Shortcut | Action
CTRL-B | Toggle Side Bar
CTLK-' | Toggle Integrated Console
CTRL-, | Settings
F11 | Toggle full screen
CTRL-K, Z | Enter Zen mode
ESC x 2 | Exit Zen mode
CRTL-\ | Split Editor
ALT-SHIFT-1 | Change editor group layout
CTRL-= | Zoom In
CTRL-- | Zoom Out
CTRL-SHIFT-E | File Explorer
CTRL-SHIFT-F | Find in Files
CTRL-SHIFT-G | Git
CTRL-SHIFT-X | Extensions
CTRL-SHIFT-P | Open Command Palette