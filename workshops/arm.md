---
layout: article
title: Authoring ARM Templates
date: 2017-10-03
categories: workshops
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
featured: true
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
**WORK IN PROGRESS**

{% include toc.html %}

## Introduction
 
This self-paced enablement session will run through a sequence of bite-sized labs that build on each other.

Each lab will always include links to the JSON templates at the start and end so that you may compare your own files and highlight any differences.

It is up to you how far through the labs you need to go.  The labs go through to a level of detail and complexity and leverage a number of the features within the Azure Resource Manager (ARM) templates that provide the power required for more complicated enterprise Infrastructure as Code deployments. 

However the advice would always be to keep it as simple as possible and maximise supportability.  Therefore the recommendation is to stop at the earliest point where you can meet the business requirements.  

The comments section has been enabled and feedback is always welcome.  
 
## Pre-requisites

You will need a working [Azure subscription](/guides/prereqs/subscription).

For the labs we will be using Visual Studio Code, configured as per the [VS Code](/guides/prereqs/vscode) prereqs page.

## Index

Section | Description
<a href="/workshops/arm/theoryARM/" target="_blank">ARM Theory</a> | A short theory session on Azure Resource Manager
<a href="/workshops/arm/theoryTemplates/" target="_blank">ARM Templates</a> | Overview of the ARM template schema and options for creating and deploying 
<a href="/workshops/arm/arm-lab1-firstTemplate/" target="_blank">Lab #1</a> | Create a simple template, factor in parameters, and deploy using CLI or PowerShell
<a href="/workshops/arm/arm-lab2-parameterFilesAndResources" target="_blank">Lab #2</a> | Using parameter files, sources for resources