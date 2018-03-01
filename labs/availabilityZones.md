---
layout: article
title: Availability Zones
categories: labs
date: 2018-03-06
tags: [azure, virtual machines, scales sets, vm, vmss, availability, set, zones, load balancer, storage, protect]
comments: true
author: Richard_Cheney
image:
  feature: 
  teaser: coming-soon.jpg
  thumb: 
excerpt: Hands on lab to work through making VMs and scale sets highly available between Azure datacentres within a region.
published: false
---
{% include toc.html %}

## Introduction

This lab is follows on from the Availability Set lab and is part of a set of labs around protecting services within Azure.  In this lab we will make virtual machines, scale sets, load balancers and storage accounts availability zone aware for high availability across datacentres within an Azure region.  

The follow on labs will cover some of the other types of protection:

* Using Traffic Manager and geo-replicated Azure services to create globally available services
* Using Azure Backup to protect systems both within Azure and in other location
* Using Azure Site Recovery as the foundation for business continuity in the event of the loss of an entire Azure region or for specific customer scenarios and compliancy requirements

Note that, once again, I wil be using the Azure CLI (including JMESPATH queries) to drive the configuration.  If you are not familiar with those then it is recommended to work through the CLI, JMESPATH and Bash guide first before running through this lab.

## Overview

If you remember from the first lab, we gained a 99.9% SLA from using virtual machines with premium disks, and then upped that to 99.95% SLA when we protected virtual machines from a number of scenarios relating to fault domain and update domains within a datacentre, using availability sets, load balancers and also virtual machine scale sets and images.

######################
YOU ARE HERE!!!!!
######################

When defining service level availability of an application, there are a wide number of factors that input to the final number.  One of the key inputs is the SLA of the infrastructure availability itself. Azure publishes a number of [SLAs](https://azure.microsoft.com/en-gb/support/legal/sla/) for the various services, and so we will explore the ones that apply to virtual machines (VMs) and Virtual Machine Scale Sets (VMSS) within an Azure datacentre.

Once these are understood, it is highly recommended that you continue to the Availability Zones lab to cover the same ground and understand how to configure high availability at the region level rather than datacentre level, and the trade offs that introduces.

