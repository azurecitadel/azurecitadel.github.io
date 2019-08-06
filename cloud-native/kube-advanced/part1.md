---
title: "Kubernetes Advanced: Module 1 - Using an Ingress"
author: Ben Coleman
date: 2019-07-17
hidden: true

header:
  overlay_image: images/header/kube.png
  teaser: images/teaser/containers.png
sidebar:
  nav: "kubernetes_lab2"
---

## Introduction to Ingresses 
If you recall in the previous lab we exposed our frontend and data-api *Services* via the `LoadBalancer` type which means they each had external public IP addresses. You might also recall how we had to wait several minutes for the IP to be assigned, and also edit our YAML manifests hardcoding the IP address into one of them. 

This is generally a bad idea for the following reasons:
- Consuming a public IP per service you want to expose is very wasteful
- External IPs will not be stable
- DNS configuration painful and manual
- No way to provide SSL/TLS termination
- No routing

You'll be pleased to know there is a better way. And that is using an *Ingress*. There's two parts to how *Ingresses* operate, there is the *Ingress Controller* which implements the rules defined in the *Ingress* objects you create.

> **📕 Kubernetes Glossary.** An **Ingress** is a Kubernetes object that provides instructions on how to route external HTTP and HTTPS traffic to **Services** running inside the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

The *Ingress Controller* is an of instance web server or proxy running in your cluster which will be looking for *Ingress* objects to pick up and configure itself with. Kubernetes is not highly opinionated and does not implement this controller itself, instead it provides extension mechanisms for other projects to plug themselves in. One of the most common *Ingress Controllers* used is [NGINX](https://www.nginx.com/), so much so that AKS provides a simple means to quickly deploy one in your cluster

Thankfully most of the details on how this operates and happens, can generally be brushed over and you don't need to know anything about NGINX to use an Ingress

## AKS 'HTTP application routing' Addon
To easily add an ingress controller to our cluster we will use the 'HTTP application routing' add-on to AKS. The add-on deploys two components: 

- **NGINX Ingress controller**: The standard NGINX Ingress controller which is exposed to the internet by using a service of type `LoadBalancer`.
- **External-DNS controller**: Watches for Kubernetes Ingress resources and creates DNS A records in a cluster-specific DNS zone (provided when enabling the add-on)

[📘 Azure Docs: AKS HTTP application routing](https://docs.microsoft.com/en-us/azure/aks/http-application-routing){:target="_blank" class="btn btn--success"}

Enabling the add on is simple:
```bash
az aks enable-addons --resource-group $group --name aks-cluster --enable-addons http_application_routing
```

After it is enabled you can get the name of the new DNS zone that has been allocated for you
```bash
az aks show --resource-group $group --name aks-cluster --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table
```
It's this DNS name we will be using in our Ingress rules so make a note of it

## End of Module 1

With an AKS cluster deployed and operational we're in a position to start using it, next we'll prepare the images we need and then look at deploying them to Kubernetes

---

[🡸 Main Lab Index](..){: .btn .btn--primary .btn--large} 
[🡺 Module 2: SOMETHING](../part2){: .btn .btn--primary .btn--large}  
