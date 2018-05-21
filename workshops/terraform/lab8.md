---
layout: article
title: "Terraform Lab 8: Extending with other providers"
categories: null
date: 2018-06-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

In this lab we will look at other providers that can help with our Azure deployments. One of the reasons for choosing Terraform is the extensible support for multiple providers so that the same workflow and logic can be applied to various public and private cloud platforms.

The same provider extensibility also applies to supporting services and data plane configuration.  In this lab we will look at examples from Cloudflare and Datadog, and deploy an AKS Kubernetes cluster using a combination of the AzureRM provider for the control plane and the Kubernetes provider for the data plane.

Finally will also look at how you can use Terraform to fork a native ARM template deployment.  We'll discuss why that may be useful and some of the caveats to bear in mind.

## End of Lab 8

We have reached the end of the lab. You have provisioned and configured a Kubernetes cluster on the AKS service, and looked at some of the other providers and provider typesz.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab8>.

In the next lab we will also look at provisioners and how they can help to go beyond vanilla image deployments for your virtual machines.

[◄ Lab 7: Multi Tenancy](../lab7){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 9: Provisioners ►](../lab9){: .btn-success}