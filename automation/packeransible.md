---
title: "Using Packer and Ansible"
date: 2019-10-07
author: Richard Cheney
category: automation
comments: true
featured: true
hidden: false
published: true
tags: [ "virtual machine", "images", "packer", "ansible" ]
header:
  overlay_image: images/header/gherkin.jpg
  teaser: images/teaser/packeransible.png
sidebar:
  nav: "linux"
excerpt: Collection of labs using Packer and Ansible to automate VM image creation and management
---

## Introduction

This workshops is a collection of labs using a selection of the tooling that we commonly see to automate processes around virtual machine image creation.  Some of the tooling is designed to work across both Windows and Linux servers, but for the sake of these labs we will separate out the two as most admins naturally gravitate to the most common and native tooling for each.  (If you disagree, use the comments below!)

I am not a deep expert in many of these technologies, so if any of the labs configure anything in an odd way then flag that up to me via the comments (or a PR on the GitHub repo) and we'll improve the labs together.

Note that there is a host of useful material within [Microsoft Learn](https://docs.microsoft.com/en-gb/learn/) and the various quickstarts and how to guides within [Microsoft Docs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview), and it is assumed that you are familiar with many of these.

The aim of these labs is to bring together some of these technologies together into a cohesive set of tooling for standing up virtual machine images.

## Pre-requisites

Please set up your laptop as per the [automation prereqs](./prereqs) page.

Not everything is needed for the Packer and Ansible labs, but chances are that you'll dig into the other content as well!

----------

## Labs

**Lab** | **Name** | **Description**
1 | [Packer](lab1) | Use Packer to generate a VM image
2 | [Ansible](lab2) | Use Ansible for ad hoc VM management
3 | [Dynamic Inventories](lab3) | Automatically generate server inventories and groups
4 | [Ansible Playbooks](lab4) | Use Ansible playbooks to manage server groups declaratively
5 | [Custom Roles](lab5) | Publish your own Ansible custom roles
6 | [Shared Image Gallery](lab6) | Use Packer and Ansible together to publish to a Shared Image Gallery
7 | [Config Management Image](lab7) | Example config management image with last mile config and managed identity

## Future Labs

This set of labs is focused on linux technologies.  There is good documentation out there for using Packer and Ansible on Windows VMs, but we are open to creating a couple of Windows specific labs if you let us know in the comments.
