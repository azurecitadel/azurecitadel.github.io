---
layout: article
title: "Terraform Lab 6: State"
categories: null
date: 2018-08-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

In this lab we will go a little deeper in understanding the Terraform state. We will also look at how you can configure remote state to protect it and make it usable in an environment with multiple Terraform admins.

We will also cover locking (and how to remove leases on Azure blob storage), as well as importing existing resources into the state.

## End of Lab 6

We have reached the end of the lab. You have configured remote state into an Azure storage account and imported an existing resource into teh configuration.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab6>.

In the next lab we will look at some of the additional areas to consider with multi-tenanted environments, including the use of Service Principals and referencing read only states.  We will also look at some of the other ways of managing environments, such as the Terraform Marketplace offering in Azure, and Hashicorp's Terraform Enterprise.

[◄ Lab 5: Modules](../lab5){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 7: Multi Tenancy ►](../lab7){: .btn-success}