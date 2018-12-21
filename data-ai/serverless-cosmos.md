---
title: Cognitive Services with Logic Apps & Cosmos
date: 2018-08-01
category: data-ai
tags: [cosmosdb, logicapps, cognitive-services]
author: Ben Coleman
toc: false
header:
  teaser: /images/teaser/serverless.png
excerpt: Learn how to build a serverless application tying together Cognitive Services with Logic Apps and storing data in Cosmos DB
---

This is a hands on lab guide for Azure. In this lab you will deploy a serverless application which uses Azure Cognitive Services to analyze photos gathered from twitter. An Azure Logic App drives the process and carries out most of the tasks.

The Logic App flow is:

- Calls the Twitter API and searches for tweets containing a certain hashtag
- Calls the Azure cognitive service API for each photo and gets the result which is a description of the contents of the photo
- Stores the result in Azure Cosmos DB

The Azure cognitive service uses a pre-trained computer vision model to return results describing the image as a JSON object. Cosmos DB is a No-SQL database, which the Logic App uses to store the results as JSON documents, one for each photo result.

The final part of the application is a simple web app, written in Node.js. This web app is hosted in Azure as an Web App Service, it connects to Cosmos DB and displays the photo analysis results as a simple web page.

![arch](arch.png)

The guide steps through deploying and configuring the complete end to end solution in Azure

[Go to the full lab guide ⇒](http://code.benco.io/serverless-cosmos-lab/){: .btn .btn--primary .btn--large}
