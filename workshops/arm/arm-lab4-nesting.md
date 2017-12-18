---
layout: article
title: 'ARM Lab 4: Nesting templates'
date: 2017-12-13
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template, nesting]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab3-moreComplex
  title: Key vault secrets, conditions and copy loops 
next:
  url: http://aka.ms/armtemplates
  title: Placeholder - links to GitHub templates  
---

WORK IN PROGRESS

{% include toc.html %}


## Introduction

In this lab we will introduce the use of complex variable objects.  It is common to use these to group together certain variable combinations as a set, and then select those using a simple string parameter.  We will also show how to do nested deployments, and will revisit the key vault secrets.

## Complex variable structures

You have already been using some complex variables when using functions such as subscription() and resourceGroup().  They return JSON objects, and then you usually pull out one of the values, such as resourceGroup().location.

Here are some example complex variables:

```json
"variables": {
  "production": { 
    "availabilitySet": {
      "name": "[concat(parameter('vmPrefix'), '-avSet')]",
      "faultDomains": 2,
      "updateDOmains": 5
    "vmCount": 3,
    "nicType": "private",
    "loadBalancer": "[concat(parameter('vmPrefix'), '-lb')]" 
    "small":  {
      "vm": "Standard_B1s",
      "diskSize": 200,
      "diskCount": 1,
      "nicCount": 1
    },
    "medium": {
      "vm": "Standard_A1",
      "diskSize": 1023,
      "diskCount": 2,
      "nicCount": 1
    },
    "large": {
      "vm": "Standard_A4",
      "diskSize": 1023,
      "diskCount": 4,
      "nicCount": 2
    }
  },
  "test": {
    "availabilitySet": null,
    "vmCount": 1,
    "nicType": "public",
    "loadBalancer": null 
    "small":  {
      "vm": "Standard_B1s",
      "diskSize": 200,
      "diskCount": 1,
      "nicCount": 1
    },
    "medium": {
      "vm": "Standard_A1",
      "diskSize": 1023,
      "diskCount": 2,
      "nicCount": 1
    },
    "large": {
      "vm": "Standard_A4",
      "diskSize": 1023,
      "diskCount": 4,
      "nicCount": 2
    }
  }
}
```
THIS NEEDS TESTING AND TWEAKING

So using `"[variables(parameter('size')).diskCount]"` should return 2 if the size parameter was set to 'medium'.

Add to this page:
1. Complex variables
1. Using templates with empty resource arrays to test variables in the outputs
1. Create a copyIndex based object.  Lab to output a string, a boolean, an array and the new object 
1. Recommendations on testing
1. Nested templates - here templates v parameters etc.
1. Introduction to complex deployments and t-shirt sizes, all of the online docs and PDFs from the AzureCAT team

