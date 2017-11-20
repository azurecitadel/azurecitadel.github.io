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
excerpt: Install and configure the lightweight VScode app for JSON authoring
---

{% include toc.html %}

## Install Visual Studio Code

Visual Studio Code is a free alternative source code editor to Visual Studio.  It is a smaller, more lightweight, and cross platform application.  Visual Studio Code (VS Code) is optimized for building and debugging modern web and cloud applications but may also be used for ARM template authoring.

Whilst VS Code is not as tightly integrated with Azure as Visual Studio, it does includes IntelliSense code completion and colour coding for JSON templates.  It can be integrated further by adding the Azure Resource Manager Tools extension.  And you can then make use of the Azure quickstart templates on GitHub and the ARM template references for the various Azure service providers on the Azure docs site.

Install VS Code from [https://code.visualstudio.com](https://code.visualstudio.com) 

## Recommended Extensions Setup 

Use Case | Logo | Extension | Search 
ARM Templates | ![](/guides/prereqs/images/vscode/armLogo.png) | <a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-vscode-extension" target="_vscode">Azure Resource Manager Tools</a> | "Azure Resource Manager Tools" 
Docker | ![](/guides/prereqs/images/vscode/dockerLogo.png) | <a href="https://code.visualstudio.com/docs/languages/dockerfile" target="_vscode">Docker extension</a> |  docker publisher:microsoft 

Installing extensions via shortcuts
* Press `Ctrl+P` 
* Type `ext install`
* Search for the extension 
* Click **Install** then **Reload**

## Adding Snippets for Azure Resource Manager

Do not install the third party Azure Resource Manager Snippets extension availble in the gallery.  This only has a subset of the snippets that you will find in the [GitHub repository](https://github.com/sam-cogan/azure-xplat-arm-tooling/blob/master/VSCode/armsnippets.json), and so we will copy those snippets straight from the repo into the User Snippets within VS Code.

1. Browse to the [snippets file](https://raw.githubusercontent.com/sam-cogan/azure-xplat-arm-tooling/master/VSCode/armsnippets.json) and copy the contents
2. In VS Code, go to File -> Preferences -> User Snippets -> JSON
3. Paste in the contents before the last curly brace 
4. Ensure the JSON file has no syntax errors and save

> You can create your own snippets.  Many of the snippets in the file have been contributed back to the repo by users. 

## Git Integration

For Git to be recognised as an SCM (source code management) provider, VS Code needs to be able to find git.exe in the PATH.  

> Currently VS Code will not find git if you have installed the Windows Subsystem for Linux and then installed git into the Bash shell. If you type `git` into either the Command Prompt or a PowerShell window then it will not be found.

The newest and least intrusive Git installation is [GitHub Desktop](https://desktop.github.com/).  Install and configure.  You will need to log in to GitHub, so you can either create an ID as part of the install process, or provide your existing credentials.  ([GitHub Desktop](https://desktop.github.com/) is preferred to the older [Git for Windows](https://git-scm.com/download/win).) 

The installer for GitHub Desktop makes use of a portable Git deployment, placing a number of executables including git.exe into `%LOCALAPPDATA%\GitHub\PortableGit_*COMMITID*\mingw32\\bin`.  You can ensure VS Code can find this by either:
1. adding the directory to the PATH environment variable and restarting VS Code
2. setting **git.path** in Settings (CTRL-,)

An example settings.json file can be found below.

> If you have 2FA enabled on your GitHub account then you will need to generate a [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) and use that as your password upon first connection. 

## Integrated Console 

As per the [VS Code configuration information](https://code.visualstudio.com/docs/editor/integrated-terminal#_configuration), the shell used by the Integrated Console defaults to:

**OS** | **Default Shell**
Windows 10 | PowerShell
Windows 7/8.x | Command Prompt
MacOS | $SHELL
Linux | $SHELL

To override the defaults, you can manually configure the settings.json.  Open up the settings by typing CTRL-, (or select File \| Preferences \| Settings). The system settings are shown in the left pane and the user overrides shown on the right.  The user overrides are in a standard JSON format containing name:value pairs separated by commas.

You can override the shell used by Windows in the integrated console by setting the **terminal.integrated.shell.windows** value:

Shell Location | Notes
"C:/Windows/sysnative/cmd.exe" | 64-bit Command Prompt if available, if not 32-bit
"C:/Windows/sysnative/WindowsPowerShell/v1.0/powershell.exe" | 64-bit PowerShell if available, if not 32-bit
"C:/Windows/sysnative/bash.exe" | [Bash on Ubuntu](/guides/prereqs/lxss) (Windows Subsystem for Linux (WSL) on Windows 10)

> Note that pathing may use either forward or backslashes in the settings.json file, but backslashes will need to be escaped (i.e. \\\\) 

The example settings file at the bottom of this page shows an example of the shell being overridden. 

## Example settings.json

For reference, here is an example settings.json user override area:

```json
{
    "bashpath": "C:/Windows/sysnative/bash.exe",
    "poshpath": "C:/Windows/sysnative/WindowsPowerShell/v1.0/powershell.exe",
    "terminal.integrated.shell.windows": "C:/Windows/sysnative/bash.exe",
    "git.path": "C:/Users/richeney/AppData/Local/GitHub/PortableGit_f02737a78695063deace08e96d5042710d3e32db/mingw32/bin/git.exe",
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "workbench.colorTheme": "Nord",
    "workbench.iconTheme": "eq-material-theme-icons",
    "editor.minimap.enabled": false,
    "window.zoomLevel": 1,
    "workbench.panel.location": "bottom",
    "window.menuBarVisibility": "toggle"
}
```



The bashpath and poshpath variables are ones I have created.  As they are not used in the main settings file they will have a wiggly underscore. It is possible to open multiple terminal sessions by clicking on the *+* icon.  And if you change the terminal.integrated.shell.windows then you can open up sessions using different shells, as shown in the screenshot below:

![](/guides/prereqs/images/vscode/multipleShells.png) 

Personalising VS Code using the menu options will also change this configuration file.

## Personalisation

VS Code has great configuration and extensibility options to allow you to personalise it to your own preferences. 
 
The settings cog at the bottom left allows you to select colour and icon themes, and to install new ones. As you can see from the settings file above my installation uses both the Material Theme (for the icons) and the Nord Theme (for the colour scheme).

I also hide the menu bar (which can be toggled back on temporarily using ALT), and I have disabled the minimap by default.

> Windows 10 also allows you to set custom colours for the title bar in the Color Settings area.  Mine is set to 59, 66, 82, which is the same as the Nord background colour for the status bar. 

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