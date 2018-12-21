---
title: Smilr - Microservices
date: 2018-12-21
category: cloud-native
author: Ben Coleman
tags: [microservices, kubernetes, angular, nodejs, aks]
header:
  teaser: /images/teaser/blueprint.png
excerpt: Learn about microservices and modern optimized application architecure, with a working reference application
---

Smilr is a multi component application & reference architecure. It has been designed to showcase microservices design patterns & deployment architectures. It consists of a front end single page application (SPA), two lightweight services, supporting database and back end data enrichment functions.

The Smilr app is very simple, it allows users to provide feedback on events or sessions they have attended via a simple web & mobile interface. The feedback consists of a rating (scored 1-5) and supporting comments.

- The user interface is written in Angular (Angular 6) and is completely de-coupled from the back end, which it communicates with via REST. The UI is fully responsive and will work on on both web and mobile.

- The two microservices are both written in Node.js using the Express framework. These have been containerized so can easily be deployed & run as containers

- The database is a NoSQL document store holding JSON, provided by MongoDB and/or *Azure Cosmos DB*

The app has been designed to be deployed to Azure, but the flexible nature of the design & chosen technology stack results in a wide range of deployment options and compute scenarios, including:
- Containers: *Azure Kubernetes Service* or *Azure Container Instances* 
- Platform services: Regular Windows *Azure App Service (Web Apps)* or Linux *Web App for Containers*
- Serverless: *Azure Functions*
- Virtual Machines: Sub-optimal but theoretically possible

This application supports a range of demonstration, and learning scenarios, such as:
 - A working example of microservices design
 - Use of containers, Docker & Kubernetes
 - No-SQL and document stores over traditional relational databases
 - CQRS (Command & Query Responsibility Segregation) as a possible pattern to separate read and write actions and stores 
 - Development and deployment challenges of single page applications 
 - Platform services for application hosting
 - Using serverless technology to support or provide services
 - Use of an open source application stack such as Angular and Node.js
 - RESTful API design 
 - The Actor model as an alternative to a traditional data model


# Architecture & Core App Components
![arch](architecture.png)

# Learn More
The full project is on GitHub, along with source code, documentation, deployment templates and other resources allowing you to try it out

[Smilr Project ⇒](https://smilr.benco.io/){: .btn .btn--primary .btn--large}