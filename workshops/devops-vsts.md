---
layout: article
title: DevOps with VSTS, Azure and Containers
date: 2017-09-29
categories: workshops
tags: [vscode, vsts, nodejs, docker, containers, workshop]
comments: true
featured: true
author: John_And_Ben
excerpt: This workshop is a series of hands-on labs focused on deploying a Node.js app to Azure PaaS using VSTS and a DevOps approach & containers.
image:
  feature: code.jpg
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

## Pre-requisites 

To complete this workshop you will need the following:

Pre-req | Required | Comment
<a href="/guides/subscription" target="_new">Azure Subscription</a> | Required | 
<a href="/guides/vsts" target="_new">Visual Studio Team Services</a> | Required | 
<a href="/guides/git" target="_new">Git</a> | Required | 
<a href="/guides/nodejs" target="_new">Node.js</a> | Required |
<a href="/guides/vscode" target="_new">Visual Studio Code</a> | Required | 
<a href="/guides/docker" target="_new">Docker</a> | Required | Required for Lab 2 only

### Content

## [Lab 1: DevOps with VSTS & Azure](/labs/devops-vsts/)

* Install the pre-requisite applications
* Generate a simple Node.js Express application
* Commit the application code to a local Git repo
* Creation of a VSTS project and code repo
* Push of the local git repo into VSTS
* Create a VSTS Build Definition to build (& optionally test) the application
* Update the build definition to deploy the app to Azure App Service using an ARM Template.
* Setup Azure Application Insights to monitor the application

**Time Required: 2-3 Hours**

## [Lab 2: Containers in Azure](/labs/devops-containers)

* Containerize a Node.js app using Dockerfile
* Build Docker image and test locally
* Deploy Azure Container Registry
* Push your image to Azure Container Registry
* Deploy app as container in Azure using Azure Container Instance

**Time Required: 1-2 Hours**

## Post-workshop Resource Cleanup

As you work through the labs you will have created resources in your Azure Subscription. It would be a good idea to remove these resources now that you no longer need them, otherwise you may be charged for their resource consumption.

* Login to the [Azure Portal](http://portal.azure.com).
* Click on the **Resource Groups** menu
* Click on the **MyAppRG-Staging** resource group
* In the resource group blade, click on **Delete Resource Group** and follow-the on-screen instructions to confirm the deletion.
* Repeat with the **MyAppRG-Containers** resource group if you created one in Lab 2.

You may also wish to delete the VSTS project we created. but before deleting the project we need to disconnect the Service Principal that was created to access Azure:

* Disconnect the Service Principal
  * If you are not logged into VSTS, navigate to https://*[AccountName]*.visualstudio.com/_projects
  * If you are logged in, click the **Team Services** icon in the very top left of the window.
  * Click on the project you were using for the labs (DevOpsLab) to open it
  * Hover over the **settings** icon (the gear icon) and select **Services**. A list of Service Endpoints is displayed.
  * Click on the endpoint matching your Azure Subscription
  * in the right-hand pane, under *Actions* select **Disconnect**

* Delete the VSTS Project
  * Navigate back to your *Account Hub* page by clicking the **Team Services** icon in the very top left of the window.
  * Hover your cursor over the project you wish to delete, then click the *Delete* icon (X).


