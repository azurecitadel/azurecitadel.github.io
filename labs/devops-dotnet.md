---
layout: article
title: Azure DevOps Lab using .NET Core and Docker Machine
date: 2017-09-29
categories: labs
author: Ben_Coleman
image:
  feature: code.jpg
  teaser: project.png
comments: true
excerpt: create a working web application running in Azure, in Linux containers, deployed via an automated DevOps CI/CD pipeline
---

This lab is a walkthrough guide on creating a web app with .NET Core (using the CLI & VSCode no Visual Studio required!). Then deploy it into Azure via VSTS and using Docker Machine to stand-up a Docker host

The scenario will cover:

- .NET Core (ASP MVC webapp)
- Docker & Docker Machine
- Azure
- VSTS

You do not need to be an .NET expert for the coding part but you will need to make basic changes to a C# file, and some HTML. Likewise no prior experience with VSTS and Azure is required (but obviously beneficial). 

> Note. The scenario purposely does not use Azure Container Service, for this learning scenario Docker Machine presents a simpler & more lightweight way to get started with Docker running in Azure

## [![link](/images/icons/link.svg) Access the full lab on my GitHub](https://github.com/benc-uk/azure-devops-core-docker)
