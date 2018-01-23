---
layout: article
title: Azure Subscriptions
date: 2018-01-23
categories: guides
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, subscription]
comments: true
author: Richard_Cheney
excerpt: If you are working through labs then you'll need a subscription.  Here are your options!
image:
  feature: 
  teaser: cloud-city.png
  thumb: 
---

{% include toc.html %}

All of the workshops require a working Azure subscription.  Ensure that you have one of the following options enabled and verified.
* Visual Studio Subscription
* Internal User Rights
* Azure Free
* Azure Pass

## Visual Studio Subscription

The Visual Studio Enterprise subscription is the replacement for MSDN subscriptions, and should only be used for test/dev scenarios.  A Microsoft partner with the Cloud Platform competency receives a number of Visual Studio 2017 Enterprise with MSDN subscriptions:

**Cloud Platform Competency** | **Visual Studio Subscriptions**
Silver | 10
Gold | 35

The Global Administrator for the [Partner Membership Center](https://partners.microsoft.com/) can assign the subscription under Requirements & Assets -> Assign Privileges, as per the competency partner section of the [support page](https://support.microsoft.com/en-gb/help/4013871/microsoft-partner-network-mpn-visual-studio-subscriptions?tpqid=800-000036). 

Visual Studio Enterprise subscribers are entitled to $150 of Azure credits per month.  
To activate the benefit:
* Go to [https://my.visualstudio.com/benefits](https://my.visualstudio.com/benefits)
* Click on Activate on the Azure tile
* Follow the sign up wizard

No credit card is required for the activation.  Your subscription will be disabled if you exceed the $150/mth limit, although it will be re-enabled the following month if usage is reduced.


## Internal Usage Rights

Microsoft Cloud Platform partners are also entitled to [internal usage rights](https://azure.microsoft.com/en-us/pricing/member-offers/mpn-benefits/) Azure credits.  

**Cloud Platform Competency** | **Internal Usage Rights**
Silver |$6,100
Gold | $12,100

The internal usage rights ([IUR](http://aka.ms/iur)) credits may be used for 
* internal business use
* customer demo
* internal development and testing
* internal training for employees and customers 

The internal usage rights may be activated at [http://aka.ms/ActivateIUR](http://aka.ms/ActivateIUR).  

## Azure Free Account

An Azure Free account may be created.  The account provides £150 of free credit for the first 30 days, with free access to some of the most popular products for 12 months before defaulting to more than 25 always free products.  

Visit [https://azure.microsoft.com/en-gb/free](https://azure.microsoft.com/en-gb/free) to set up the account. 

Credit card details need to be provided for identity verification, but the spending limit is set to $0 to ensure that it remains free.  The spending limit may be changed if the account is going to be used ongoing.  

Note that some of the services under a trial licence will be restricted, e.g. CPU quotas, and therefore an Azure Free account is not appropriate for some of the larger workshops such as Virtual Data Centre.

The [FAQ](https://azure.microsoft.com/en-gb/free/free-account-faq/) includes details of the included services and quotas. 

## Azure Pass

If you are a partner working with Microsoft's One Commercial Partner group and the session is being hosted by a Cloud Solution Architect (CSA), then they may provide you with an **Azure Pass** subscription.  
   * Open a private browser session, go to http://signup.live.com and create a clean new Microsoft account in  **_labname.firstname.lastname_@outlook.com** format 
    * Go to https://www.microsoftazurepass.com and follow the instructions to redeem the code and activate your Azure Pass

## Common Pitfalls to Avoid

* Free Trial accounts may have a CPU quota that is insufficient for the lab environment deployment to successfully complete
* Redeeming an Azure Pass code against an email address previously used for a trial will succeed, but the activation will fail
* Using a work email may mean that you do not have write access to the company's directory and therefore you cannot create users and groups

## Verification 

Once the account is enabled, prove that it is working correctly by 
* logging into the portal at [http://portal.azure.com](http://portal.azure.com) 
* create a Resource Group called 'Azure101IaaS' in West Europe
