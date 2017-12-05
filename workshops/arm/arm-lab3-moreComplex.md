---
layout: article
title: 'ARM Lab 2: Other sources of resources'
date: 2017-11-17
categories: null
tags: [authoring, arm, workshop, hackathon, lab, template]
comments: true
author: Richard_Cheney
previous:
  url: ../arm-lab1-firstTemplate
  title: Creating your first template
next:
  url: ../arm-lab3-moreComplex
  title: Utilising more complex functions 
---

{% include toc.html %}


## Azure Quickstart templates

In the previous section we were working in the portal, and you may have noticed the "Load a GitHub quickstart template" option.  There is a GitHub repo that has a wide selection of ARM templates that have been contributed by both Microsoft employees and by the wider community.  You can find it by searching for "Azure quickstart templates", which will find both the main [Azure Quickstart GitHub repo](https://github.com/Azure/azure-quickstart-templates) and the [Azure Quickstart Templates portal](https://azure.microsoft.com/en-gb/resources/templates/) site that helps to navigate some of the content.  

Go via either route and search for "availability zones".  You'll find a number of templates, but we'll take a look at the "201-multi-vm-lb-zones" template that has been contributed by Aaron Lower, one of the Microsoft employees based in Redmond.  If you have gone through the Microsoft Azure route, then select the  Browse on GitHub button.  You should now be [here](https://github.com/Azure/azure-quickstart-templates/tree/master/201-multi-vm-lb-zones).

You will find the azuredeploy.json and azuredeploy.parameters.json as expected.  There are also a couple of other files that are there for the repo to work as expected:

1. **metadata.json** contains the information that dictates how the entry is shown in the Microsoft Azure Quickstart Templates site.  The parameters information is pulled directly from the azuredeploy.json, pulling out the name and metadata description.
1. **readme.md** is a readme file in markdown format.  Click on the raw format to see how the markdown is written and rendered into the static HTML that you see when browsing the GitHub repo itself.

Copy out the azuredeploy.json and azuredeploy.parameters.json out into new files in a lab2c folder. This is a nice template that introduces a number of interesting functions.  Let's take a look.

#### Parameters

It looks rather innocuous, but the most interesting .  

#### Variables

You'll see a few variables that pull the IDs for various resources and subresources.  

There are also a number of simple string variables that could easily be moved up into the parameters section.

The most interesting 
