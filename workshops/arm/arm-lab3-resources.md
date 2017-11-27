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


The first four name:value pairs within the are always present, covering the resource type, the cosmetic name that forms the lasy part of the ID, the api version of the resource provider type and the location (or region) that it will be deployed into, which commonly defaults to the location used by the resource group itself using the `[resourceGroup().location]` Resource Manager function.   

The resource then has name:value tags (up to 15), and then the properties of the resource type itself.