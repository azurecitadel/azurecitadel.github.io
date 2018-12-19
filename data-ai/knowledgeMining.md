---
title: Build a Cognitive Search Solution
date: 2018-10-10
comments: true
author: Faris_Haddad
category: data-ai
tags: [cognitive, search, knowledge, data]
author: Faris Haddad
header:
  overlay_image: images/header/nothing.png
  teaser: images/teaser/project.png
featured: true
excerpt: This one day training will focus on hands-on activities that develop proficiency with Cognitive Search, an Azure Search AI-oriented capability
---

## Welcome

Real-world data is messy. It often spans media types (e.g. text documents, PDF files, images, databases), changes constantly, and carries valuable knowledge in ways that is not readily usable.

Cognitive Search adds data extraction, natural language processing (NLP), and image processing skills to an Azure Search indexing pipeline, making previously unsearchable or unstructured content more searchable. Information created by Cognitive Search Skills, such as entity recognition or image analysis, gets added to an index in Azure Search.

This solution alleviates the large effort needed to accomplish the typical solution pattern needed for this: ingest-enrich-explore. Sidesteps usual challenges like large scale change tracking to file format support, and even composition of multiple AI models. Today it takes a huge amount of effort, requires branching into multiple unrelated domains (from cracking PDFs to handling AI model composition). This is where Cognitive Search comes in.

This one day training will focus on hands-on activities that develop proficiency with Cognitive Search, an Azure Search AI-oriented capability. These labs assume an introductory to intermediate knowledge of [Visual Studio](https://www.visualstudio.com/vs/community/), the [Azure Portal](https://portal.azure.com), [Azure Functions](https://azure.microsoft.com/en-us/services/functions/) and [Azure Search](https://azure.microsoft.com/en-us/services/search/). If you are not at that skill level, we have prerequisite materials below that you **need** to complete prior to beginning this training.

## Goals

We will focus on hands-on activities to learn how to create a Cognitive Search solution for all types of business documents. The documents include pdfs, docs, ppts and images, as well as documents with multiple languages.
In this training, you will create a data flow that uses cognitive skills to enrich your business documents. These enrichments will become part of an Azure Search index.

At the end of this workshop, you should have learned:

+ **What** Cognitive Search is
+ **How** to implement this Cognitive Search Solution
+ **Why** to use this solution with demos, POCs and other business scenarios

## Prerequisites

Since this is an AI training on top of Microsoft Azure Services, before we start you need:

+ **If if you don't have prior experience:**
1. **To Read:** [Visual Studio](https://docs.microsoft.com/en-us/visualstudio/ide/visual-studio-ide) tutorial
1. **To Read:** [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) quick introduction
1. **To Read:** [Azure Search](https://docs.microsoft.com/en-us/azure/search/search-what-is-azure-search) overview
1. **To Read:** [Using Postman](https://docs.microsoft.com/en-us/azure/search/search-fiddler) tutorial
1. **To Watch:** [MVA: C# Fundamentals](https://mva.microsoft.com/en-us/training-courses/c-fundamentals-for-absolute-beginners-16169?l=Lvld4EQIC_2706218949) short videos

+ **Mandatory**
1. **To Create:** You need a Microsoft Azure account to create the services we use in our solution. You can create a [free account](https://azure.microsoft.com/en-us/free/), use your [MSDN account](https://azure.microsoft.com/en-us/pricing/member-offers/credit-for-visual-studio-subscribers/) or use any other subscription where you have permission to create services.
1. **To Install:** [Visual Studio 2017](https://www.visualstudio.com/vs/) version version 15.5 or later, including the Azure development workload.
1. **To Install:** [Postman](https://www.getpostman.com/). To call the labs APIs.

## Agenda

Since you have finished the prerequisites, let's start the training. You just need to follow the workshop structure presented below.

+ [Introduction](https://github.com/farishaddad/Knowledge-Mining-using-Cognitive-Search/blob/master/01-Introduction.md) - 1 hour - Motivation, context, key concepts
+ [Solution Architecture](https://github.com/farishaddad/Knowledge-Mining-using-Cognitive-Search/blob/master/02-Solution-Architecture.md) - 1 hour - Diagram, use cases, deployment options and costs
+ [Environment Creation](https://github.com/farishaddad/Knowledge-Mining-using-Cognitive-Search/blob/master/03-Environment-Creation.md) - 1 hour - Using the Azure Portal, we will create the services we need fo the workshop
+ [Lab 1](https://github.com/farishaddad/Knowledge-Mining-using-Cognitive-Search/blob/master/04-Lab-1-Text-Skills.md) - 2 hours - Create a Cognitive Search Enrichment Process: **Text** Skills
+ [Lab 2](https://github.com/farishaddad/Knowledge-Mining-using-Cognitive-Search/blob/master/05-Lab-2-Image-Skills.md) - 1 hour - Create a Cognitive Search Skillset: **Image** Skills
+ [Lab 3](https://github.com/farishaddad/Knowledge-Mining-using-Cognitive-Search/blob/master/06-Lab-3-Custom-Skills.md) - 2 hours - Create a Cognitive Search Skillset with **Custom** Skills
+ [Final Case](https://github.com/farishaddad/Knowledge-Mining-using-Cognitive-Search/blob/master/07-Final-Case.md) - 0.5 hour - Brainstorm - Create a Cognitive Search Solution