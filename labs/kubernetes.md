---
layout: article
title: "Kubernetes: Hands On With Microservices"
categories: labs
date: 2018-03-23
tags: [kubernetes, microservices, containers, azure, aks, nodejs]
comments: true
author: Ben_Coleman
featured: true
image:
  feature: kube.png
  teaser: containers.png
excerpt: Designed for people wanting to learn Kubernetes; going from basics to deploying a real working microservices application, with clustering, scaling and persistence 
---

{% include toc.html %}

## Introduction
This lab aims to introduce people to Kubernetes and Azure Container Service (AKS) by working through a practical example; that of deploying a working microservices application. During this lab you will deploy a Kubernetes cluster using AKS, configure your own container registry, deploy a number of microservices, configure their network access to combine the services into a working end to end application. Finally you look at how Kubernetes can be used to make the app resilient and scalable

The application we will be using is called 'Smilr' and is [covered in much more detail in this demo guide](/demos/microservices/). Smilr allows people to provide feedback on events or sessions they have attended via a simple web & mobile interface. The feedback consists of a rating (scored 1-5) and supporting comments. Administrators can create new events and schedule them

For the purpose of this lab we can ignore much of the low level detail & software architecture of the application, and treat it as a set of microservice containers to be deployed into Kubernetes. 

### Core Technologies
- Kubernetes
- Docker
- Azure Container Service (AKS) 
- Azure Container Registry

**💬 Note.** The Smilr app makes use of many other open source technologies such as *Angular, Node.JS, Express* and *MongoDB*, however for this lab we will focus on Kubernetes so the internal workings of each software component will not be covered in any detail


### Application Architecture
This is a simplified view of the Smilr application:
![Application Architecture Diagram](/labs/kubernetes/images/arch.png)

This is what we will be standing up and deploying piece by to Kubernetes over the course of this lab

Some important notes on the configuration of the Smlir app:
- The frontend listens for HTTP traffic on port **3000** and is stateless
- The frontend passes the API endpoint to the Angular client, this is set via an environmental variable called `API_ENDPOINT`
- The frontend makes no connection to the data-api, it only serves the Angular client app. This is a common architectural pattern for [*Single Page Applications*](https://medium.com/@NeotericEU/single-page-application-vs-multiple-page-application-2591588efe58){:target="_blank"}. This is different from traditional 3-tier applications you might be familiar with
- The data-api listens for HTTP traffic on port **4000** and is stateless
- The data-api connects to MongoDB using a connection string, this is set via an environmental variable called `MONGO_CONNSTR`
- The MongoDB component is a standard MongoDB 3.4 server, with no authentication. This is obviously stateful 


### Assumptions & Scope
This lab does not require any Kubernetes skills or knowledge, however being familiar with some of the concepts, and what Kubernetes is for; would be clearly be advantageous 

[📘 What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/){:target="_blank" class="btn-info"} 

However a baseline level of knowledge is assumed in two main areas:
- **Standard use of Azure:** resource groups, subscriptions, etc. 
- **Docker basics:** What are images & containers, tags, container registries etc. If you need to get up to speed quickly, try reading the [Containers Tech Primer](/guides/tech-primer-containers)


### Pre-Reqs
- [**An Azure subscription**](/guides/subscription/)  
We will deploy an Azure Container Service (AKS) cluster however this is not expensive and can easily run for several weeks using the £150 of credit in a free Azure account or Azure Pass 

- [**Docker installed locally**](/guides/docker)  
This is optional if you want to skip want to skip using *Azure Container Registry* (Part 2) and use public images directly from Dockerhub

- [💻 Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest){:target="_blank" class="btn-info"}  
You can install the Azure CLI under Windows (i.e. run from PowerShell terminal) or within WSL bash. Using WSL bash is **strongly recommended**  
Use of the legacy Windows CMD prompt is not advised, and use of alternative bash systems (gitbash or cygwin) is discouraged

- [💻 Visual Studio Code](https://code.visualstudio.com/){:target="_blank" class="btn-info"}  
We will not be writing code other than YAML config files, so you can use other text editors if you wish (but not Notepad!). VS Code has good support for YAML and the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=brendandburns.vs-kubernetes) can be very useful for seeing what is going on 

---

## Lab Contents
As this lab is quite long, it has been broken into several modules:

- [Module 1 - Deploying Kubernetes](part1){: .btn-success}  
- [Module 2 - Azure Container Registry (ACR)](part2){: .btn-success}  
- [Module 3 - Deploying the Data Layer](part3){: .btn-success}  
- [Module 4 - Services & Networking](part4){: .btn-success}
- [Module 5 - Deploying the Frontend](part5){: .btn-success}
- [Module 6 - Scaling & Persistence](part6){: .btn-success}
- [Extra - Optional Exercises](extra){: .btn-success}
