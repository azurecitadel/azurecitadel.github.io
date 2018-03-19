---
layout: article
title: Starting with the Azure Bot Service
date: 2018-02-28
categories: labs
tags: [bot, node, team services]
comments: true
author: Matt_Biggs
image:
  feature: 
  teaser: BotIntro.png
  thumb: 
excerpt: An introduction to the Azure Bot service, building a basic Node web bot to adding Congnitive Services. 
---


# Overview
The session is an introduction to the Azure Bot Service, Node JS, and Azure Cognitive Services for people with little or no experience of any of it.

The aim is to provide and understanding of Node, an insight into how the Bot Service works, and  high level view of Team Services, although this is more of a by-product. If that sounds like a lot, everything is explained – there is very little assumed knowledge (I would say none, but you never know). There are other workshops and labs on [Citadel](https://azurecitadel.github.io/) that cover Node and DevOps in more detail that are definitely merit a look.

It is also worth having an empty text file open to keep a track of variables and settings while working, do not save this.

A final note before kicking off; the following is written as one way of working, certain tasks can be done in a different order, and there are a number of different methods of coding certain parts.

The walkthrough is written using Windows 10 and associated tools, the main one being VS Code – this is also available Mac and Linux, and using Bash means that this should work across all platforms – just interpret CMD or Command Prompt as Terminal.

I use Team Services to familiarise myself with the tool and the environment setup. If you want to bypass that you can download the file and use azure-publish, or even edit in the online tool if you want to skip right to Node, you can use the online editor!

## List of Activities  
* [1. Prerequisites – software](./bot/apps.md)
* [2. Initial setup – end to end environment](./bot/environment.md)
* [3. Node development](./bot/development.md)
* [4. Cognitive services](./bot/cognitive.md)