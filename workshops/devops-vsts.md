---
layout: article
title: DevOps with VSTS, Azure and Containers
date: 2017-09-29
categories: workshops
tags: [vscode, vsts, nodejs, docker, containers, workshop]
comments: true
author: John_And_Ben
excerpt: This workshop is a series of hands-on labs focused on deploying a Node.js app to Azure using VSTS and a DevOps approach. 
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
In this workshop we will start by using *Visual Studio Code* and *Visual Studio Team Services* to create a continuous integration/continuous deployment pipeline to deploy a Node.js application to *Azure App Service* using an ARM Template.

Then, in Lab 2, we will move on to containerizing the application using <a href="https://www.docker.com" target="_blank">Docker</a> and deploying to *Azure Container Instances*.

The workshop will cover:
* Node.js & Express
* Visual Studio Code (VSCode)
* Git & GitHub
* Visual Studio Team Services (VSTS)
* Azure Web App
* ARM Templates
* Docker
* Azure Container Registry
* Azure Container Instances

You do not need to have prior knowledge of Node.js or Express for this workshop but you will need to make basic changes to Javascript files. Likewise no prior experience with VSTS, Docker or Azure is required (but obviously beneficial). You will be able to complete these labs using either a Windows or Mac machine, but some of the commands documented here are Windows variants.

Lab | Description
<a href="/labs/devops-vsts/" target="_new">DevOps with VSTS & Azure</a> | Learn how to create a continuous delivery pipeline with VS Code, VSTS & Azure App Service
<a href="/labs/devops-containers" target="_new">Containerizing Apps with Azure</a> | Convert your deployed application to a Docker container and deploy it as an Azure Container Instance

### Pre-requisites 

To complete this workshop you will need the following:

Pre-req | Required | Comment
<a href="/guides/prereqs/subscription" target="_new">Azure Subscription</a> | Required | 
<a href="/guides/prereqs/vsts" target="_new">Visual Studio Team Services</a> | Required | 
<a href="/guides/prereqs/git" target="_new">Git</a> | Required | 
<a href="/guides/prereqs/nodejs" target="_new">Node.js</a> | Required |
<a href="/guides/prereqs/vscode" target="_new">Visual Studio Code</a> | Required | 
<a href="/guides/prereqs/docker" target="_new">Docker</a> | Required | Required for Lab 2 only

### Content

#### Lab 1: DevOps with VSTS & Azure

* Install the pre-requisite applications
* Generate a simple Node.js Express application
* Commit the application code to a local Git repo
* Creation of a VSTS project and code repo
* Push of the local git repo into VSTS
* Create a VSTS Build Definition to build ( & optionally test) the application
* Update the build definition to deploy the app to Azure App Service using an ARM Template.
* Setup Azure Application Insights to monitor the application

**Time Required: 2-3 Hours**

#### Lab 2: Containers

* Containerize the Node.js app using Dockerfile
* Build Docker image and test locally
* Deploy Azure Container Registry
* Push your image to Azure Container Registry
* Deploy app as container in Azure using Azure Container Instance

**Time Required: 1-2 Hours**
