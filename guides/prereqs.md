---
layout: article
title: Workshop Pre-Requisites
date: 2017-07-04
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, template]
comments: true
author: Richard_Cheney
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
Be ready for a workshop by making sure you have met the pre-requisites.

## Overview

All students must complete the required pre-requisites for the training prior to attendance, to maximise the time and value of the session itself.

**Note that the requirements vary from workshop to workshop. Please refer to the communication for the session to determine which  the requirements for that session are a subset of the list below.**  

## Pre-requisites

Pre-req | Required | Comment
<a href="/guides/prereqs/subscription" target="_prereq">Azure Subscription</a> | Required | 
<a href="/guides/prereqs/lxss" target="_prereq">Bash & CLI 2.0</a> | Optional | Windows 10 only, recommended for power users
<a href="/guides/prereqs/powershell" target="_prereq">Azure Powershell Modules</a> | Optional | Recommended for existing PowerShell users
<a href="/guides/prereqs/vscode" target="_prereq">Visual Studio Code</a> | Optional | Depends on lab or workshop
<a href="/guides/prereqs/git" target="_prereq">Git for Windows or Mac</a> | Optional | Required for DevOps lab
<a href="/guides/prereqs/nodejs" target="_prereq">Node.js</a> | Optional | Required for DevOps Lab
<a href="/guides/prereqs/vsts" target="_prereq">Visual Studio Team Services</a> | Optional | Required for DevOps Lab
<a href="https://www.getpostman.com" target="_prereq">Postman</a> | Optional | Used in the Logic Apps lab to post JSON
<a href="/guides/prereqs/vs2017" target="_prereq">Visual Studio 2017</a> | Optional | The more lightweight VS Code is preferred for most labs

## Always required

An active **Azure subscription**.  You will required **one** of the following:

* Visual Studio subscription (preferred)
* Internal Usage Rights for silver and gold partners
* Free Azure trial account

If the lab or workshop has specific subscription requirements then the documentation will be specific.  A good example is the Extending Identity lab which requires contributor access to the Azure Active Directory for the tenant. 

## Optional Requirements

Refer to the requirements list specified by the trainer to determine whether any or all of the following optional pre-reqs are also a requirement for the workshop session.

**Note that the Cloud Shell built into the Azure portal is the simplest option for most users as it has no install requirements and provides evergreen versions of both CLI 2.0 and PowerShell.**

* PowerShell
  * PowerShell users may add the Azure modules
* Azure CLI 2.0 
  * Power users on Windows 10 may wish to install the Ubuntu Bash Subsystem, and then install Azure CLI 2.0 locally
* Git
  * For Windows 10 power users that have the Windows 10 Linux Subsystem installed, then add git using apt-get
  * Note that the DevOps lab requires a full Git install
* JSON template editor.  It is recommended to have one of the following:
  * Visual Studio Code 
  * Visual Studio 2017