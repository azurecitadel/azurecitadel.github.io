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

Some important notes on the configuration of the Smilr app:
- The frontend listens for HTTP traffic on port **3000** and is stateless
- The frontend passes the API endpoint to the Angular client, this is set via an environmental variable called `API_ENDPOINT`
- The frontend makes no connection to the data-api, it only serves the Angular client app. This is a common architectural pattern for [*Single Page Applications*](https://medium.com/@NeotericEU/single-page-application-vs-multiple-page-application-2591588efe58){:target="_blank"}. This is different from traditional 3-tier applications you might be familiar with
- The data-api listens for HTTP traffic on port **4000** and is stateless
- The data-api connects to MongoDB using a connection string, this is set via an environmental variable called `MONGO_CONNSTR`
- The MongoDB component is a standard MongoDB 3.4 server, with no authentication. This is obviously stateful 


### Assumptions & Scope
This lab does not require any prior Kubernetes skills or knowledge, however being familiar with some of the concepts and what Kubernetes does, would clearly be advantageous 

[📘 What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/){:target="_blank" class="btn-info"} 

As Kubernetes is built on top of containers and Docker, and we'll be using Azure, baseline level of knowledge is assumed in two main areas:
- **Standard use of Azure:** - Azure CLI, Resource groups, subscriptions, etc. 
- **Docker basics:** - What are images & containers, tags, container registries etc. If you need to get up to speed quickly, you can try reading the [Containers Tech Primer](/guides/tech-primer-containers)


## Pre-Reqs
There are several things you will need before starting this lab:

- [**An Azure Subscription**](/guides/subscription)  
Either an existing Azure subscription you have access to (with 'contributor' rights) or Azure Pass or free account.  
We will deploy an Azure Container Service (AKS) cluster however this is not necessarily an expensive service, and could easily run for several weeks in the credit provided by an Azure Pass  
***Note On Permissions*** - If using an existing subscription you will need rights to create a service principal in the Azure AD tenant you use. This is a pre-req to deploying AKS. ***If you activate an Azure Pass do not use your company/work email address***

- [**Docker Installed Locally**](/guides/docker)  
Having Docker installed is preferred, however this is only required to populate the *Azure Container Registry* with private copies of the Smilr images (using docker pull and push). This is optional and can be skipped if the use of *Azure Container Registry* (Module 2) is omitted, and instead public images used directly from Dockerhub.

- [💻 Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest){:target="_blank" class="btn-info"}  
You will need at least **version 2.0.27** of the CLI installed. You can install the Azure CLI under Windows (i.e. run from PowerShell terminal) or within WSL bash.  
An alternative is to use [Azure Cloud Shell](https://shell.azure.com/) (which has everything installed we need). Using bash either from WSL or the Cloud Shell is the preferred option.  
Use of the legacy Windows CMD prompt is not advised, and use of alternative bash systems (gitbash or cygwin) is discouraged

- [💻 Visual Studio Code](https://code.visualstudio.com/){:target="_blank" class="btn-info"}  
We will not be writing real code but there will be significant editing of YAML files. You can use other text editors if you wish (but not Notepad!). VS Code has good support for YAML and the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=brendandburns.vs-kubernetes) can be extremely useful for working with Kubernetes 

---

## Lab Contents
As this lab is quite long, it has been split into several modules:

[Module 1 - Deploying Kubernetes](part1){: .btn-success}  
[Module 2 - Azure Container Registry (ACR)](part2){: .btn-success}   
[Module 3 - Deploying the Data Layer](part3){: .btn-success}  
[Module 4 - Services & Networking](part4){: .btn-success}  
[Module 5 - Deploying the Frontend](part5){: .btn-success}  
[Module 6 - Scaling & Persistence](part6){: .btn-success}  
[Extra - Optional Exercises](extra){: .btn-success}

---

## Supporting Slides
[Azure Container Strategy & Orchestration with Kubernetes](https://1drv.ms/b/s!AhEX99ErZbKGg1n8wQOPvgtQoYsl){:target="_blank" class="btn-info"}

