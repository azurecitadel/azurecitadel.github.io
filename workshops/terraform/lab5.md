---
layout: article
title: "Terraform Lab 5: Multi Tenancy"
categories: null
date: 2018-08-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: false
---

{% include toc.html %}

## Introduction

So far we have been working in Cloud Shell, which works really well for one person doing demos and most development work.  It is not really geared for multiple admins to work in that environment and it is not suitable if you are dealing with multiple tenants.  Also, as the ~/clouddrive area sits on an SMB 3.0 area it does not support symbolic links, which are key to how the modules work in lab 7.

So in this lab we will look at how we could make our Terraform platform work effectively in a multi-tenanted environment.  The principals here apply to any more complex environment where there are multiple subscriptions in play, as well as those supporting multiple tenancies or directories.

We will also look at a couple of alteratives for managing systems and where they make the most sense.

1. The Terraform Marketplace offering in Azure and Managed Service Identity (MSI) authentication
2. Terraform Enterprise from Hashicorp

## End of Lab 5

We have reached the end of the lab. You have used Service Principals for authentication, and mimicked a split environment, enabling customers or business units to deploy their own infrastructure using Terraform whilst referencing the state of centralised systems.

We have also looked at the Azure Marketplace offering for Terraform and at Terraform Enterprise.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab7>.

In the next lab we will

[◄ Lab 4: Metas](../lab4){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 8: State ►](../lab6){: .btn-success}