---
layout: article
title: 'ARM Lab 1: First Template and Deployment'
date: 2017-11-17
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
previous:
  url: ../theoryTemplates
  title: Azure Resource Manager Templates
next:
  url: ../arm-lab2-functions
  title: Utilising more complex functions 
---

{% include toc.html %}

## Overview

In this lab we will be creating a simple template using Visual Studio Code.  We will then be deploying it into a resource group using Azure CLI 2.0.  We will then factor some of the resource's values up into the parameters section.

## Pre-reqs

Before we start, let's check your configuration.

First of all you will need a working [Azure subscription](/guides/prereqs/subscription).

For this lab we will be using Visual Studio Code, and it is assumed that you have configured it as per the [VS Code prereqs](/guides/prereqs/vscode) page:
* Visual Studio Code
* Git working in Command Prompt
* Either CLI 2.0 (az) installed in Windows, or Azure PowerShell Modules (or both) 
* Bash on Ubuntu (Windows Subsystem for Linux) installed for Windows 10 users, with git and az (optional, recommended)
* VS Code extensions installed (ARM and CLI)
* ARM snippets
* Integrated Console chosen 
