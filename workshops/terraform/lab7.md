---
layout: article
title: "Terraform Lab 7: Multi Tenancy"
categories: null
date: 2018-08-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: false
---

{% include toc.html %}

## Introduction

In this lab we will look at how we could make our Terraform platform work effectively in a multi-tenanted environment.  The principals here apply to any more complex environment where there are multiple subscriptions in play, as well as those supporting multiple tenancies or directories.

We will also look at read only states, and why they can be useful when carving up larger environments, delineating responsibilty for them and applying role based access.

Finally we will look at a couple of alteratives for managing systems:

1. The Terraform Marketplace offering in Azure and Managed Service Identity (MSI) authentication
2. Terraform Enterprise from Hashicorp

## End of Lab 7

We have reached the end of the lab. You have used Service Principals for authentication, and mimicked a split environment, enabling customers or business units to deploy their own infrastructure using Terraform whilst referencing the state of centralised systems.

We have also looked at the Azure Marketplace offering for Terraform and at Terraform Enterprise.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab7>.

In the next lab we will

[◄ Lab 6: State](../lab6){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 8: Extending ►](../lab8){: .btn-success}