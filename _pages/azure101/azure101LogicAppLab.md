---
layout: article
title: Azure 101 Logic App Lab
date: 2017-08-29
categories: null
permalink: /azure101/logicapp/
tags: [azure, 101, paas, logic, app, twitter]
comments: true
author: Richard_Cheney`
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
Logic App lab for the Azure 101 workshop.

{% include toc.html %}

## Introduction

Logic Apps are quick plug and play "if .. then ..." constructs to help developers and power users to quickly integrate systems.  They complement some of the other PaaS type offerings such as serverless Functions, or Event Grid and other event based services.

In this section we will use logic apps to poll for tweets from the
presenter, and automatically send that content out from your own Twitter
account.

* In the Azure101PaaS resource group, click Add and find Logic Apps
* Create a new Logic App in West Europe
* Click into it and select Twitter for the new tweet trigger
  * Sign in to Twitter
  * Search on tweets with the hashtag \#azure101
  * Set frequency to every two minutes
* Add a condition for the Twitter username to be the one specified by the trainer
* Click on new action, search on tweet and pick Post a Tweet, and in the Tweet Text dialog box select Tweet Text
* The trainer will take a photo and tweet using the \#azure101 hashtag
* The trigger history should eventually show a status other than skipped
* Refreshing your webpage should show the updated twitter feed
