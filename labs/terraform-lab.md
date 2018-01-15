---
layout: article
title: WORK IN PROGRESS-Hands on lab exercise for using Hashicorp Terraform with Microsoft Azure
date: 2017-09-12
categories: labs
author: Adam_Bohle
image:
  feature: 
  teaser: Education.jpg
  thumb: 
comments: true
published: false
---

{% include toc.html %}

## Introduction

Virtualisation and cloud computing have created an environment where we can provision technical assets such as virtual machines, storage, networking and PaaS level services incredibly quickly. However, two problems have resulted from this technology shift. We are over 10 years into the virtualisation paradigm of IT infrastructure, but still the most popular method for configuring virtualised resources is to configure them manually or in a semi-automated fashion via scripts. If we hope to be able to scale in the cloud computing world then it is essential that we start to treat our infrastructure as if it was code (IaS). When embrace defining our infrastructure as if it was code then we are able to create self provisioning documentation regarding how the infrastructure we operate the business on actually works and operates. 

In Microsoft Azure we can natively achieve IaC by using Azure Resource Manager Templates, or ARM Templates, these are essentially JSON definitions of the "resources" which we want to run within the Azure cloud platform. If you wish to learn more about ARM templates then please follow this link **Insert link here for ARM template lab**

For this lab though we will use a popular open source infrastructure provisioning tool called Terrafom by Hashicorp. Terraform is a provisioning tool which can be used against a wide variety of infrastructure providers. in this lab we will show you how you can use Terraform to specifically provision resources in Microsoft Azure and the steps you need to go through to be successful with utilising Terraform for you IaC requirements

## Prerequisites

First of all we will need to install Terraform on your laptop or workstation. 

You can do this by navigating the Terraform Download page on the Hashicorp website [Terraform Downloads page](https://www.terraform.io/downloads.html)

As you can see on the Downloads page, MAC/Windows/Linux are all supported, please download the appropirate download for your OS platform

If you are using Windows, Terraform runs as a standalone executable and does not need to install on your Windows OS, simply move the downloaded terraform.exe to a sensible location on your OS, for example you may want to create a folder in your C:\Program Files (x86) directory called "Terraform" and place the terraform.exe there.

Note: For ease of use you will most likely want to add this location to your PATH variable so that you can easily reference the terraform.exe at the command line without needing to specify the full path to the .exe

Test that Terraform is working on your workstation by running the terrafom.exe at the command line or terminal and you should see a similar result as below

![](/images/Terraform.png)