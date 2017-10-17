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

Whilst VS Code is not as Azure integrated as Visual Studio, it does includes IntelliSense code completion and colour coding for JSON templates.  It can be integrated further by adding the Azure Resource Manager Tools extension.  And you can then make use of the Azure quickstart templates on GitHub and the ARM template references for the various Azure service providers on the Azure docs site.

*	Install VS Code from [https://code.visualstudio.com](https://code.visualstudio.com) 

## Install Extensions

### Install the Azure Resource Manager Tools Extension

* Press (`Ctrl+P`) and enter `ext install` or lcick on the Extension icon into the toolbar
* Search for **Azure Resource Manager Tools** and select it
* Click on the green **Install** button

![Azure ARM Tools Extension](../images/vscode/vscode-azurerm-extension-install.png)

*	Click the **Reload** button to enable the extension

### Install the Azure Tools for Visual Studio Code Extension

* Press (`Ctrl+P`) and enter `ext install` or click on the Extension icon into the toolbar
* Search for **Azure Tools** and select **Azure Tools for Visual Studio Code**
* Click on the green **Install** button
* sClick the **Reload** button to enable the extension

* Type `Ctrl-Shift-P` to open the Command Palette.  Examples: 
    * Typing `azure` shows all of the available extension commands
    * Typing `login` will bring up the Azure login
    * Typing `active` will set the default Azure datacentre 
    * Typing `search` will bring up the Azure Quickstart template search

*	Whilst typing in the main body of an Azure Resource Manager JSON template, the editor will show IntelliSense for the available commands, and will also show snippets that can be quickly inserted

