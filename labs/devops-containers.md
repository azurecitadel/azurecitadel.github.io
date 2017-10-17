---
layout: article
title: Containerizing Apps with Azure
date: 2017-10-17
categories: labs
tags: [vscode, docker, containers, nodejs, lab]
comments: true
author: Ben_Coleman
excerpt: In this lab we will containerize a simple Node.js web application and deploy it to Azure
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---

{% include toc.html %}

# Overview

This lab is a continuation of the ["DevOps with VS Code, VSTS & Azure App Service"](devops-vsts) lab where a Node.js application was created, built & deployed using CI/CD. This lab can follow on directly, or you can jump in and start at this point

The high-level flow is:
1. Containerize the Node.js app using Dockerfile
2. Build Docker image and test locally
3. Deploy Azure Container Registry
4. Push your image to Azure Container Registry
5. Use Azure Cloud Shell
6. Deploy app as container in Azure using Azure Container Instance

![deployment pipeline](./images/vscode-git-ci-cd-to-azure.png)

# Main Lab Flow

[Ensure you have all the pre-requisites installed](/workshops/devops-vsts/) before starting the main lab.

### Node.js application
The starting point requires a functioning Node.js application, there are two options:
- Continue from the previous lab, in which case use the `devops-lab-workspace\myapp` Node.js project which you already have on your local machine
- Jump in at this point, in which case download [myapp.zip](./myapp.zip) which has been already created and prepared, and extract onto your local machine in a suitable location

### Create Dockerfile

### Build Docker image

### Deploy Azure Container Registry

### Push image up to Azure Container Registry

### Deploy as container in Azure Container Instance

---

Congratulations. You finished the lab! 

To summarise what you just did:

* You did things
* You did more things

# Follow-on Activities

1. ????