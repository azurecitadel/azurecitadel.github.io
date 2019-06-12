---
title: "Automating linux VM image creation"
date: 2019-06-17
author: Richard Cheney
category: automation
comments: true
featured: true
hidden: false
published: false
tags: [ "linux", "virtual machine", "images" ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "linux"
excerpt: Collection of labs using Packer and Ansible to automate Linux VMs image creation
---

## Introduction

This workshops is a collection of labs using a selection of the tooling that we commonly see to automate processes around virtual machine image creation.  Some of the tooling is designed to work across both Windows and Linux servers, but for the sake of these labs we will separate out the two as most admins naturally gravitate to the most common and native tooling for each.  (If you disagree, use the comments below!)

I am not a deep expert in many of these technologies, so if any of the labs configure anything in an odd way then flag that up to me via the comments (or a PR on the GitHub repo) and we'll improve the labs together.

Note that there is a host of useful material within [Microsoft Learn](https://docs.microsoft.com/en-gb/learn/) and the various quickstarts and how to guides within [Microsoft Docs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview), and it is assumed that you are familiar with many of these.

The aim of these labs is to bring together some of these technologies together into a cohesive set of tooling for standing up virtual machine images.

## Pre-requisites

Please set up your laptop as per the [automation prereqs](./prereqs) page.

Not everything is needed for the image labs, but chances are that you'll dig into the other content as well!

----------

## Labs

**Lab** | **Name** | **Description**
1 | [Packer](lab1) | Use Packer to generate a VM image
2 | [Ansible](lab2) | Add in Ansible for declarative image creation
3 | [Shared Image Gallery](lab3) | Use Shared Image Gallery as a target for multi-tenancy images
4 | [Azure DevOps](lab4) | Create a build pipeline in Azure DevOps

**💬 Note.** The labs are currently being built up and will become available over the coming months.

## Future Labs

Creating the images is a good start, but these labs make even more sense when combined with other parts of the automation.  Here are some areas under consideration:

* Using custom-init
    * ARM deployment calling custom-init
    * Terraform module using custom-init
* Using Ansible for last mile configuration
    * ARM deployment calling an Ansible playbook
    * Terraform module calling an Ansible playbook via local-exec
* Virtual Machine Agents
    * Extensions in ARM
    * Extensions in Terraform
    * Using DeployIfNotExists in Azure Policy and Initiatives
