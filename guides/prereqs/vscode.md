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
Install and configure the lightweight VScode app for JSON authoring

## Install Visual Studio Code

Visual Studio Code is a free alternative source code editor to Visual Studio.  It is a smaller, more lightweight, and cross platform application.  Visual Studio Code is optimized for building and debugging modern web and cloud applications but may also be used for ARM template authoring.

Whilst VS Code is not as tightly integrated with Azure as Visual Studio, it does includes IntelliSense code completion and colour coding for JSON templates.  It can be integrated further by adding the Azure Resource Manager Tools extension.  And you can then make use of the Azure quickstart templates on GitHub and the ARM template references for the various Azure service providers on the Azure docs site.

*	Install VS Code from [https://code.visualstudio.com](https://code.visualstudio.com) 

## Install CLI 2.0 

If you are going to be using CLI 2.0 within the integrated bash console in VS Code then pre-install the [Azure CLI 2.0](https://aka.ms/GetTheAzureCLI) to the OS. 

> Note tha installing CLI 2.0 to the Windows Subsystem for Linux will not make it availanble within the integrated console.  Install the Windows MSI version so that `az` may be called on the Command Prompt.

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