---
layout: single
title: Creating ARM Templates
date: 2018-01-08
category: automation
tags: [arm, template]
author: Richard Cheney
header:
  overlay_image: images/header/arm.png
  teaser: images/teaser/cloud-builder.png
excerpt: Learn how to use Infrastructure as Code with Azure Resource Manager template deployments.
sidebar:
  nav: "arm"
featured: true
---
## Introduction

This self-paced enablement session will run through a sequence of bite-sized labs that build on each other.

Each lab will always include links to the JSON templates at the start and end so that you may compare your own files and highlight any differences.

It is up to you how far through the labs you need to go.  The labs go through to a level of detail and complexity and leverage a number of the features within the Azure Resource Manager (ARM) templates that provide the power required for more complicated enterprise Infrastructure as Code deployments.

However the advice would always be to keep it as simple as possible and maximise supportability.  Therefore the recommendation is to stop at the earliest point where you can meet the business requirements.

The comments section has been enabled and feedback is always welcome.

The short URL to get back to this page is:

[**aka.ms/citadel/arm**](https://aka.ms/citadel/arm){:target="_blank" class="btn-info"}

## Pre-requisites

Set up your machine as per the [automation prereqs](../prereqs) page.

Note that you won't need the Terraform or Packer binaries for these labs.

## Index

Lab | Section | Description
| [Azure Resource Manager](/automation/arm/theoryARM/) | A short theory session on Azure Resource
| [ARM Templates](/automation/arm/theoryTemplates/) | Template structure overview, options for creating and deploying
1 | [First Template](/automation/arm/lab1) | Create a simple template, factor parameters, and deploy using the CLIs
2 | [Sources of Resources](/automation/arm/lab2) | Different sources of templates
3 | [References and Secrets](/automation/arm/lab3) | Functions, references, and how to handle secrets
4 | [Conditional Resources](/automation/arm/lab4) | Using conditions to selectively deploy resources
5 | [Using Copy](/automation/arm/lab5) | Use the copy property to create multiple resources
6 | [Objects and Arrays](/automation/arm/lab6) | More complex parameters, variables and outputs
7 | [Nesting Templates](/automation/arm/lab7) | Nesting templates inline and with linked templates
