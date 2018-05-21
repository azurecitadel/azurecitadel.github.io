---
layout: article
title: "Terraform Lab 3: Core Environment"
categories: null
date: 2018-06-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

In this lab we will build out a core environment, with some of the core networking services you would expect to see in a hub and spoke topology.  We will start using multiple .tf files, and we'll make use of GitHub as our repository so that you get the benefits of version control.

This environment will be the basis of the remaining labs in the workshop, so no need to blow it away at the end of the lab!

## End of Lab 3

We have reached the end of the lab. You have started to use GitHub and work with multiple resource groups, resources and .tf files.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab3>, although you may have spread your Terraform stanzas across your .tf files differently dependent on how you have it organised.

In the next lab we will look at some of the meta parameters that you can use in Terraform to gain richer functionality.

[◄ Lab 2: Variables](../lab2){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 4: Metas ►](../lab4){: .btn-success}