---
layout: article
title: New Kubernetes and microservices lab
date: 2018-04-09
comments: true
tags: [lab, kubernetes, microservices, docker, containers, registry]
author: Ben_Coleman
image: /images/kube.png
excerpt: New lab for Kubernetes
---

Ben Coleman has put together a fantastic new lab on Kubernetes and microservices.

![Kubernetes](/images/kube.png)

The lab is making use of the existing container images put together as part of the Smilr project, so if you are interested in how those container images were put together and the application architecture, then go to <https://aka.ms/citadel/smilr>. The lab just makes use of those images in the registry so there is no dependency on you to have application development experience.

This lab will introduce you to Kubernetes and Azure Container Service (AKS) by working through a practical example; that of deploying a working microservices application. During this lab you will deploy a Kubernetes cluster using AKS, configure your own container registry, deploy a number of microservices, configure their network access to combine the services into a working end to end application. Finally you look at how Kubernetes can be used to make the app resilient and scalable.

The lab will cover a number of core technologies:

* Kubernetes
* Docker
* Azure Container Service (AKS)
* Azure Container Registry (ACR)

Go to <https://aka.ms/citadel/kubernetes> to access the lab!

-----------------------

For information, the Smilr app makes use of many other open source technologies such as Angular, Node.JS, Express and MongoDB, however for this lab the focus is very much on Kubernetes.

![Application Architecture Diagram](/labs/kubernetes/images/arch.png)