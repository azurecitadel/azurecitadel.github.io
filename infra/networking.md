---
title: Networking
date: 2020-01-28
category: infra
tags: [ vnet, nsg, vwan, firewall, peering ]
comments: true
featured: true
hidden: false
author: Binal Shah
header:
  overlay_image: images/header/networking.jpg
  teaser: images/teaser/networking.png
excerpt: Work through this set of labs to build up your core understanding of network configuration in Azure.
---

## Introduction

This is a set of labs that has been used in the US to onboard new customers and enable their technical people on networking in Azure. The labs will take you through some of the basics, getting you hands on with both the portal and the Azure CLI, and each lab is simplified in order to demonstrate a specific aspect of Azure networking.

Each lab has a lab diagram to describe the target configuration in each lab, and they naturally build on each other until you are covering more advanced areas such as user defined routes, vNet peering, Virtual WAN and Azure Firewall.

Please use the comments section below to give us feedback on the labs, or to suggest other Azure networking areas you would like to see covered.

## Labs

Here are the individual lab sections:

Lab | Name | Description
1 | [Virtual Networks](https://github.com/binals/azurenetworking/blob/master/Lab%2001%20Virtual%20Network.pdf) | Create a vNet with two subnets and a couple of VMs
2 | [Network Security Groups](https://github.com/binals/azurenetworking/blob/master/Lab%2002%20Network%20Security%20Groups.pdf) | Create layer 4 ACLs and apply at the subnet level
3 | [Azure CLI](https://github.com/binals/azurenetworking/blob/master/Lab%2003%20CLI.pdf) | Create a vNet, a VM and attach an NSG using the Azure CLI
4 | [vNet Peering](https://github.com/binals/azurenetworking/blob/master/Lab%2004%20Virtual%20Network%20Peering.pdf) | Peer two vNets together and allow communication between them
5 | [vNet Peering  - Transitive Behaviour](https://github.com/binals/azurenetworking/blob/master/Lab%2005%20Virtual%20Network%20Peering%20-%20Transitive%20behavior.pdf) | Understand how transitive peering works
6 | [NVA CSR1000v](https://github.com/binals/azurenetworking/blob/master/Lab%2006%20NVA%20CSR1000v.pdf) | Learn how to deploy network virtual appliances from the Marketplace
7 | [Routing Tables](https://github.com/binals/azurenetworking/blob/master/Lab%2007%20Routing%20Tables.pdf) | Customise the routing tables to force traffic through the NVA
8 | [Site-to-site VPN](https://github.com/binals/azurenetworking/blob/master/Lab%2008%20Site-to-site%20VPN.pdf) | See how S2S VPNs are configured
9 | [Virtual WAN](https://github.com/binals/azurenetworking/blob/master/Lab%2009%20Virtual%20WAN.pdf) | Use Microsoft's backbone for your WAN and understand the hub and branch topology
10 | [Standard Load Balancer](https://github.com/binals/azurenetworking/blob/master/Lab%2010%20Standard%20Load%20Balancer.pdf) | Create a load balancer to distribute traffic to backend VMs
11 | [Network Watcher NSG Flow Logs](https://github.com/binals/azurenetworking/blob/master/Lab%2011%20Network%20Watcher%20NSG%20Flow%20Logs.pdf) | Look at the flow content of packets to the VMs
12 | [Firewall](https://github.com/binals/azurenetworking/blob/master/Lab%2012%20Firewall.pdf) | Explore hub and spoke topologies and centralise control using Azure Firewall
13 | [Firewall - Inbound NAT](https://github.com/binals/azurenetworking/blob/master/Lab%2013%20Firewall%20-%20Inbound%20NAT.pdf) | Configure inbound NAT to SSH to a VM within a spoke
14 | [Firewall - Spoke to Spoke](https://github.com/binals/azurenetworking/blob/master/Lab%2014%20Firewall%20-%20Spoke%20to%20spoke%20communication.pdf) | Use the Firewall to forward traffic between spokes

It is recommended to run through the labs in order as they build on each other.

## Futures

The current format of these lab guides is pdf. If a page loads up but looks blank then you may need to just scroll down a little!

If the labs prove as popular as we think they will be then we'll aim to transpose these into standard markdown over time, and perhaps bring them directly into the Azure Citadel repository.
