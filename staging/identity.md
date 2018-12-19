---
layout: article
title: Extending Identities to the Cloud
date: 2017-09-19
categories: labs
tags: [aad, identity, hybrid]
comments: true
author: Tom_Wilde
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
Extending Identities to the Cloud.

{% include toc.html %}

## Overview
During this lab we will learn how to extend our on premise identities to the cloud.  This allows you to provide a common identity for your users for Office 365, Azure, SaaS applications integrated with Azure AD + a whole lot more.
![](./images/ExtendingIdentities_exampleSSO.png)

We will create a new Windows Active Directory Forest, a new Azure Active Directory tenant, prepare Active Directory for AD connect and then use AD connect to synchronize users.

To demonstrate I will be creating a new on premise domain called **wildecompany.local** but you can create something relevant for you.

## Topology
We will end up with a single forest, single Azure AD tenant topology. This is most common topology used, a single on-premises forest, with one or multiple domains and a single Azure AD tenant.  
Pass-through Authentication will be used and we will not be synchronizing passwords. This means our on premise Active Directory Domain Controller will be completing all the authentications and passwords won't be stored in Azure. This is just one of the **many** ways AD Connect can be configured and is asked for by customers that want to utilise on premise infrastucture, keep passwords on-premises but still utilise the cloud.

![](./images/ExtendingIdentities_singleforestsingledirectory.png)

## Pre-requisites
The workshop requires the following:
* [Azure Subscription](/guides/prereqSubscription.md)
* Some of these steps will require a public domain (e.g. microsoft.com) with the ability to edit the DNS settings so we can match our on premise identities to the cloud. If you do not own one you can skip certain steps and still use AD Connect but it wouldn't be a great user experience in a production environment.

## Labs
* [Lab: **Create Windows Active Directory Forest**](./create-ad)
* [Lab: **Create Azure Active Directory Tenant**](./create-aad)
* [Lab: **Prepare Windows Active Directory**](./prepare-ad)
* [Lab: **Configure AD Connect**](./configure-adc)


