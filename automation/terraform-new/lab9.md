---
title: "Terraform Provisioners"
date: 2020-02-01
author: Richard Cheney
category: automation
comments: true
featured: true
hidden: true
tags: [terraform]
header:
  overlay_image: images/header/terraform.png
  teaser: images/teaser/terraformlogo.png
sidebar:
  nav: "terraform"
excerpt: Nothing to see here...
---
## Introduction

> These labs have been updated soon for 0.12 compliant HCL. If you were working through the original set of labs then go to [Terraform on Azure - Pre 0.12](/automation/terraform-pre012).

In this lab we will look at provisioners, and how they can be used to drive additional virtual machine customisation once the base image has been deployed.

We will also look at templates in the context of Terraform, and how you can use variables to customise the creation of text files on your servers.

## End of Lab 9

We have reached the end of the lab. You have use provisioners and templates to demonstrate how you could direc additional configuration in your virtual machines once they have been deployed from a template.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-pre-012-lab9>.

In the next lab we will look at one of the other Hashicorp products that complements this area, and how you can use Packer to programmatically create custom images to underpin your Azure virtual machine deployments.

[◄ Lab 8: Extending](../lab8){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 10: Packer ►](../lab10){: .btn .btn--primary}
