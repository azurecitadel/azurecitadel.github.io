---
layout: article
title: "Kubernetes: Module 2 - Azure Container Registry (ACR)"
date: 2018-03-22
tags: [kubernetes, microservices, containers, azure, aks, nodejs]
comments: true
author: Ben_Coleman
image:
  feature: kube.png
  teaser: containers.png
---

## Overview
This part can be skipped entirely and you can run through the lab simply using images stored publicly on Dockerhub, this shortens and simplifies the exercise. However using a private registry such as *Azure Container Registry* represents a much secure and more real-world use case. If you wish to skip this jump straight to [Lab Module 3 - Deploying the Data Layer](../part3)

## Deploying Azure Container Registry 
To create a *Azure Container Registry* (ACR) instance, pick a name for your ACR, this has to be globally DNS unique (e.g. pick something with your name and the year). We will refer to this name later on. 

Run these commands substituting your ACR name:
```
az acr create -n {acr_name} -g kube-lab -l westeurope --sku Standard --admin-enabled true
```

## Configure Kubernetes to use ACR
Get the ACR login password and make a note of it, we will use it in the next command
```
az acr credential show -n {acr_name} -g kube-lab
```

In order for the Kubernetes nodes to authenticate with ACR we will set up a *Secret* in Kubernetes which holds the login details for our ACR. There are other ways to authenticate between AKS and ACR however they are slightly more complex, so we'll not use them in this lab.  
[📘 ACR and AKS Authentication](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks){:target="_blank" class="btn-info"}

Create secret called **acr-auth** with this command:
```
kubectl create secret docker-registry acr-auth --docker-server {acr_name}.azurecr.io --docker-username {acr_name} --docker-password {acr_password} --docker-email ignore@dummy.com
```
We will use this secret later on

> **📕 Kubernetes Glossary.** A *Secret* is a Kubernetes object that holds any sensitive information, such as passwords, connection strings or API keys. Setting up *Secrets* lets us refer to them by name in our deployments and avoids having sensitive details held in plain text

## Populate ACR with images
The Smilr images used for this lab are publicly available on Dockerhub:
- https://hub.docker.com/r/smilr/data-api
- https://hub.docker.com/r/smilr/frontend

To get the images into our ACR we will pull them from Dockerhub, tag them and push to ACR. This step requires that you have Docker installed and running or have configured the `docker` client to work with a remote Docker host (e.g. Docker Machine in Azure)

First login to ACR (so you can push images), The Azure CLI has a helper command to do this. Note. this is the same as running `docker login $acrName.azurecr.io -u $acrName -p $acrPwd`
```
az acr login -n {acr_name} -g kube-lab
```

### Pull, re-tag and push **Data API** image
This effectively copies the smilr/data-api image from public Dockerhub to your private ACR 
```
docker pull smilr/data-api
docker tag smilr/data-api {acr_name}.azurecr.io/smilr/data-api
docker push {acr_name}.azurecr.io/smilr/data-api
```


### Pull, re-tag and push **Frontend** image
```
docker pull smilr/frontend
docker tag smilr/frontend {acr_name}.azurecr.io/smilr/frontend
docker push {acr_name}.azurecr.io/smilr/frontend
```

---

[🡸 Module 1: Deploying Kubernetes](../part1){: .btn-success}  
[🡺 Module 3: Deploying the Data Layer](../part3){: .btn-success}  
