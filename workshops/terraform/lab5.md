---
layout: article
title: "Terraform Lab 5: Modules"
categories: null
date: 2018-08-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: false
---

{% include toc.html %}

## Introduction

In this lab we will create modules.  Modules are a fantastic way of managing the core building blocks that you will want to deploy into multiple customer configurations.  This lab will cover:

* why modules are important
* key characteristics
* how to convert your existing .tf files
* the Terraform Registry

## End of Lab 5

We have reached the end of the lab. You have introduced modules to your environment and started to think about how to make use of those to define your standards underpinning different deployments for various reference architectures or customer requirements.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab5>.

In the next lab we will go a little bit deeper on Terraform state and how to manage and protect that in a multi-tenanted environment with multiple admins.

[◄ Lab 4: Metas](../lab4){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 6: State ►](../lab6){: .btn-success}