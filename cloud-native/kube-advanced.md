---
title: "Kubernetes: Advanced Lab"
author: Ben Coleman
date: 2019-07-17
tags: [kubernetes, microservices, aks]
category: cloud-native
featured: false
published: true

header:
  overlay_image: images/header/kube.png
  teaser: images/teaser/kube.png
excerpt: "Follow on from the 'Kubernetes: Hands On With Microservices' lab, covering some more advanced areas of Kubernetes such as networking, monitoring, scaling and DevOps"

sidebar:
  nav: "kubernetes_lab2"
---

## Introduction
This is a follow on from the [Kubernetes: Hands On With Microservices](../kubernetes) lab, and aims to introduce users to some more advanced and real world usage of Kubernetes. The areas we will address are:

[[ !TODO! Update when lab complete ]]
- Ingress for routing HTTP traffic
- Enabling TLS for HTTPS
- Secrets
- Managing Compute Resources 
- Horizontal Auto Scaling
- Monitoring
- DevOps

### Assumptions & Scope
As this lab follows on from previous exercise, you will need to have completed the [first lab](../kubernetes) as far as the end of part-6, alternatively a set of quick start steps is provided below to allow you to jump in and "fast forward" to be ready to pick up & start this lab

## Pre-Reqs
>Note. These pre-reqs are identical to the first lab

There are several things you will need before starting this lab:

- [Azure Subscription](/prereqs/subscription){:target="_blank" class="btn-info"}   
Either an existing Azure subscription you have access to (with 'contributor' rights) or Azure Pass or free account.  
We will deploy an *Azure Container Service (AKS)* cluster however this is not necessarily an expensive service, and could easily run for several weeks in the credit provided by an Azure Pass
  - ***Note On Permissions*** - If using an existing subscription you will need rights to create a service principal in the Azure AD tenant you use. This is a pre-req to deploying AKS. 
  - If you activate an Azure Pass ***do not use your company/work email address***

- [Option 1: Azure Cloud Shell](https://azure.microsoft.com/en-gb/features/cloud-shell/){:target="_blank" class="btn-info"}  
This is the preferred and recommended approach for a number of reasons. The *Azure Cloud Shell* is an online browser based shell, accessed either from the Azure Portal or directly via **[https://shell.azure.com/bash](https://shell.azure.com/bash){:target="_blank"}**. There is nothing you need to install, however if you have not used it before it will prompt you for a few set-up steps. We will be using the Bash version of the Cloud Shell, not PowerShell. You will need your Azure subscription setup before you can start.

- [Option 2: WSL Bash](https://docs.microsoft.com/en-us/windows/wsl/install-win10){:target="_blank" class="btn-info"} 

The majority of this lab is command-line based, and you can use Linux Bash. One great option for running Bash is to use the *Windows Subsystem for Linux (WSL)*. If you have this already installed and working this would be the preferred option. For this lab you can go ahead and install WSL however be aware it takes some time to install & requires a reboot.  
  - You will additionally need to [install the Azure CLI v2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
  - **Note.** Any WSL distro should work, however only *Ubuntu* has been tested.


- [Visual Studio Code](https://code.visualstudio.com/){:target="_blank" class="btn-info"}  
We will not be writing real code but there will be significant editing of YAML files. You can use other text editors if you wish (but please not Notepad!). VS Code has good support for YAML and the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=brendandburns.vs-kubernetes) can be extremely useful for working with Kubernetes 

---

## Lab Contents
This lab has been split into several modules:

[Module 0 - Quick Start (Optional)](quickstart){: .btn .btn--primary .btn--large}   
[Module 1 - Using an Ingress](part1){: .btn .btn--primary .btn--large}   

---

## Supporting Slides
[Azure Container Strategy & Orchestration with Kubernetes](https://1drv.ms/b/s!AhEX99ErZbKGg1n8wQOPvgtQoYsl){:target="_blank" class="btn-info"}
