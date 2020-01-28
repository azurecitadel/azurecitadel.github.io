---
title: "Terraform on Azure - Pre 0.12"
date: 2018-09-05
author: Richard Cheney
category: automation
comments: true
featured: false
hidden: false
tags: [terraform]
header:
  overlay_image: images/header/terraform.png
  teaser: images/teaser/terraformlogo.png
sidebar:
  nav: "terraform"
excerpt: Series of labs for Terraform on Azure (OLD VERSION)
---

## Introduction

> This is the older version of the Terraform labs that were created before 0.12 came along and dramatically cleaned up the HCL and enabled rich list and map support when interacting with modules. If you haven't started the labs then switch to the newer set. If you have already started with these then feel free to continue, nut please let me know if you encounter any broken links!

This workshops is made up of a series of labs to take you through the fundamentals of using Terraform to manage the deployment and removal of simple Azure services, through to modularising your own standards to effectively manage large scale deployments.

This lab will cover a lot of ground, including

* Terraform principles, workflows and terminology
* The three ways of authenticating the Terraform Azure Provider
* Using the interpolation syntax
* Variables, locals, data, outputs
* Load order and overrides
* Dependencies and the graph database
* Using modules and the Module Registry
* Provisioners and using the taint command
* Meta-parameters such as *count* and *depends_on*
* Using the splat operator
* Protecting and locking your state
* Using workspaces and read only states
* Sensitive data
* Integrating with git repositories

----------

## Pre-requisites

For labs 1 and 2 you only need an Azure subscription as we will use the Cloud Shell.

For labs 3 then please get your machine set up as per the [automation prereqs](./prereqs) page.

----------

## Assumptions

A good working knowledge of the Azure services and ecosystem has been assumed.

A background knowledge of Terraform is advised. The button below will take you to Terraform's intro guide.

[**Terraform Intro**](https://aka.ms/terraform/intro){:target="_blank" class="btn-info"}

----------

## Labs

**Lab** | **Name** | **Description**
1 | [Basics](lab1) | Use the basic Terraform workflow in Cloud Shell
2 | [Variables](lab2) | Provision from within VS Code and start to use variables
3 | [Core Environment](lab3) | Use a GitHub repo and provision a core environment
4 | [Meta Parameters](lab4) | Make use of copy and other meta parameters
5 | [Multi Tenancy](lab5) | Using Service Principals and Managed Service Identity
6 | [State](lab6) | Configuring remote state and using read only state in split environments
7 | [Modules](lab7) | Learn about modules, converting your .tf files, Terraform Registry
8 | [Extending beyond ARM](lab8) | Use providers and the AAD API to fully configure a kubernetes cluster
9 | [Provisioners](lab9) | Leverage provisioners to customise your virtual machine deployments (_coming soon_)