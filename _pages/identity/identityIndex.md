---
layout: article
title: Extending Identities
date: 2017-09-19
categories: null
permalink: /identity/
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

## Introduction
During this lab we will learn how to extend our on premise identities to the cloud to open up all the cloud goodness to those users.

We will create a new Active Directory Domain, a new Azure Active Directory Domain, prepare Active Directory for AD connect and then use AD connect to synchronise users.

## Pre-requisites
The workshop requires the following:
* [Azure Subscription](../prereqs/prereqSubscription.md)
* Some of these steps will require a public domain (e.g. microsoft.com) so we can match our on premise identities to the cloud, if you do not own one you can skip completing these steps but still learn from the lab.

## Topology
We will end up with a single forest, single Azure AD tenant topology.  This is most common topology used, a single on-premises forest, with one or multiple domains (one in this lab), and a single Azure AD tenant.  
Pass-through Authentication will also be used so our on premise Active Directory Domain Controller will be completing all the authentications.

## Labs
* [Lab: **Create Windows Active Directory Domain**](./azure101PortalLab.md/#introduction)
* [Lab: **Create Azure Active Directory Tenant**](./azure101VMLab.md/#introduction)
* [Lab: **Prepare Windows Active Directory**](./azure101WebAppLab.md/#introduction)
* [Lab: **Configure AD Connect**](./azure101LogicAppLab.md/#introduction)


