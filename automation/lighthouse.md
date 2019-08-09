---
title: "Azure Lighthouse"
date: 2019-08-09
author: [ "Tom Wilde" ]
category: azure
comments: true
featured: true
hidden: false
published: true
tags: [ policy, initiative, compliance, governance, cloud, azure, adoption, framework, lighthouse ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "lighthouse"
excerpt: Azure Lighthouse enables service providers to automate and scale
---

## Azure Lighthouse

Azure Lighthouse essentially provides an easy way for people managing infrastructure in multiple Azure AD tenants. That’s mostly partners but this could help a few customers too, for the sake of ease in this writing I’ll refer to them as partners.

Partners have designed their way around the challenge of managing infrastructure in multiple tenants and I’ve seen various design. Such as, guest accounts or partner users created in customer tenants, service principles, 3rd party tools and more. This has various challenges around identity, auditing, security, compliance, etc and doesn’t really lend itself well to automation so the main cost to partners is time.



Automation is key for partners and really what I spend allot of my time driving with them, if you’re not automating as much as possible then you’re going to be left behind in the years ahead.

This is where Azure Lighthouse comes in and essentially allows a partner to manage customer infrastructure from the partner tenant without logging out or switching tenants. 

![Lighthouse Benefits](/automation/lighthouse/lighthouse-benefits.png)
**Figure 1:** Azure Lighthouse Benefits

It doesn’t matter how the partner is managing resources (CLI, PowerShell, HTTP request, Azure Portal) and it doesn’t matter how the customer is buying Azure (PayG, EA, CSP, etc) either. This is all because Azure Lighthouse is new functionality built into Azure, not outside or added on. Now the partner can automate and scale cloud management allot easier than before and work with any customer or even partner. From the customer side they may have several partners involved, each managing separate resources/services and they can see which partner is doing what as it’s all audited.

Azure Delegated Resource Management is the foundational fabric that when used, projects the customer resources into the partner tenant. So to the partner, it looks like and pretty much acts like the resources are actually in their tenant.

![Before Lighthouse](/automation/lighthouse/lighthouse-before.png)
**Figure 2:** Before Azure Lighthouse

![Using Lighthouse](/automation/lighthouse/lighthouse-after.png)
**Figure 3:** Using Azure Lighthouse


In the following posts we'll explore the uses of Azure Lighthouse.