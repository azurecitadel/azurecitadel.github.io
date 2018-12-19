---
title: "VDC Lab 1: Explore"
date: 2018-07-19
category: infra
comments: true
hidden: true
author: Richard Cheney
sidebar:
  nav: "vdc"
header:
  overlay_image: /images/header/vdc.png
  teaser: /images/teaser/blueprint.jpg
excerpt: Explore the baseline VDC environment
---

{% include toc.html %}

## 1.0 Introduction

In this lab, we will explore the environment that has been deployed to Azure by the ARM templates.

## 1.1 Topology

The lab environment has the following topology:

![Main VDC Image](/infra/vdc/images/VDC-Networking-Main.jpg)

**Figure 1:** VDC Lab Environment

*Note that some of your resources will be named subtly differently.*

## 1.2 Resources

Each of the virtual networks resides in its own Azure resource group. While this environment could be deployed in one resource group only, splitting it up in this manner makes it easier to apply Role Based Access Control to the various areas individually.

Use the Azure portal to explore the resources that have been created for you. Navigate to the various resource groups in turn to get an overall view of the resources deployed.

![VDC-Spoke1 Resource Group Image](/infra/vdc/images/VDC-Spoke1-RG.png)

**Figure 2:** VDC-Spoke1 Resource Group View

**Tip**: Select 'group by type' on the top right of the resource group view to group the resources together.

## 1.3 Subnets

Under the resource groups *VDC-Hub* and *VDC-OnPrem*, look at each of the virtual networks and the subnets created within each one.

You will notice that *Hub-vnet* and *OnPrem-vnet* have an additional subnet called *GatewaySubnet* - this is a special subnet used for the VPN gateway.

## 1.4 Load balancers

Navigate to the *Spoke1-lb* load balancer in the VDC-Spoke1 resource group. From here, navigate to 'Backend Pools' - you will see that both virtual machines are configured as part of the backend pool for the load balancer, as shown in figure 3.

![LB Backend Pools](/infra/vdc/images/BackendPools.png)

**Figure 3:** Load Balancer Backend Pools View

Under the load balancer, navigate to 'Load Balancing Rules'. Here, you will see that we have a single rule configured (*DemoAppRule*) that maps incoming HTTP requests to port 3000 on the backend (our simple Node.js application listens on port 3000).

**Note:** Two types of load balancer are available in Azure - basic and standard.  The standard has more features, such as being zone aware.  Also the load balancer can be either external or internal. In our case, we have an internal load balancer deployed; that is, the load balancer has only a private IP address.  In other words, it is not accessible from the Internet.

## Finishing up

Now that you are familiar with the overall architecture, let's move on to the next lab where you will start to add some additional configuration.

[◄ Setup](../lab0){: .btn-subtle} [▲ Index](../#labs){: .btn-subtle} [Lab 2: Configure ►](../lab2){: .btn-success}