---
layout: article
title: Microservices App Architecture - Smilr
date: 2018-02-20
categories: demos
tags: [microservices]
comments: true
author: Ben_Coleman
image:
  teaser: blueprint.png
---


This is a multi component application designed to showcase microservices design patterns & deployment architectures. It consists of a front end single page application (SPA), two lightweight services, supporting database and back end data enrichment functions.

The application is called *'Smilr'* and allows people to provide feedback on events or sessions they have attended via a simple web & mobile interface. The feedback consists of a rating (scored 1-5) and supporting comments.

- The user interface is written in Angular (Angular 5) and is completely de-coupled from the back end, which it communicates with via REST. The UI is fully responsive and will work on on both web and mobile.

- The two microservices are both written in Node.js using the Express framework. These have been containerized so can easily be deployed & run as containers

- The database is a NoSQL document store holding JSON, provided by *Azure Cosmos DB*

The app has been designed to be deployed to Azure, but the flexible nature of the design & chosen technology stack results in a wide range of deployment options and compute scenarios, including:
- Containers: *Azure Container Service (ACS or AKS)* or *Azure Container Instances* 
- Platform services: Regular Windows *Azure App Service (Web Apps)* or Linux *Web App for Containers*
- Serverless: *Azure Functions*
- Virtual Machines: Sub-optimal but theoretically possible

![](https://user-images.githubusercontent.com/14982936/32730129-fb8583b2-c87d-11e7-94c4-547bfcbfca6b.png)

This application supports a range of demonstration, and learning scenarios, such as:
 - A working example of microservices design
 - Use of containers, Docker & Kubernetes
 - No-SQL and document stores over traditional relational databases
 - Development and deployment challenges of single page applications 
 - Platform services for application hosting
 - Using serverless technology to support or provide services
 - Use of an open source application stack such as Angular and Node.js
 - RESTful API design 


## [![link](/images/icons/link.svg) Full details, docs, deployment guides and source code is on GitHub](https://github.com/benc-uk/microservices-demoapp) 
