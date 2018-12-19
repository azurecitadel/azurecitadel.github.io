---
layout: article
title: "Kubernetes: Module 2 - Azure Container Registry (ACR)"
date: 2018-10-01
tags: [kubernetes, microservices, containers, azure, aks, nodejs]
comments: true
author: Ben_Coleman
image:
  feature: kube.png
  teaser: containers.png
---

{% include toc.html %}

## Overview
*Azure Container Registry* (ACR) is a secure fully hosted private Docker registry which we will use to both build & store our application container images

## Deploying Azure Container Registry 
To create a *Azure Container Registry* instance, pick a name for your ACR, this has to be globally DNS unique (e.g. pick something with your name and the year). We will set this in a Bash variable as we'll be using it a lot

We'll re-use the `$group` and `$region` variables we set when creating the AKS cluster, so make sure you use the same session/window. If need be, reset the variables to your given values as described at the start of [part 1](../part1)

```
ACR_NAME="change-this-to-your-unique-acr-name"
az acr create -n $ACR_NAME -g $group -l $region --sku Standard --admin-enabled true
```
The ACR name can only contain letters and numbers (no dots or dashes, etc), and it's advised to make it all lowercase

**💬 Note. Sept 2018.**  We will be using a feature called *ACR Tasks* this is currently in preview but now quite stable. 


## Configure Kubernetes to use ACR
Get the ACR login password and set it in a Bash variable 
```
ACR_PWD=`az acr credential show -n $ACR_NAME -g $group --query "passwords[0].value" -o tsv`
```

As a sanity check you can display the value of the password using `echo $ACR_PWD` 

In order for the Kubernetes nodes to authenticate with ACR we will set up a *Secret* in Kubernetes which holds the login details for our registry. There are other ways to authenticate between AKS and ACR however they are slightly more complex, so we'll not use them in this lab.  
[📘 ACR and AKS Authentication](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks){:target="_blank" class="btn-info"}

Create a secret called **acr-auth** with this command:
```
kubectl create secret docker-registry acr-auth --docker-server $ACR_NAME.azurecr.io --docker-username $ACR_NAME --docker-password $ACR_PWD --docker-email ignore@dummy.com
```
We will use this secret later on

> **📕 Kubernetes Glossary.** A *Secret* is a Kubernetes object that holds any sensitive information, such as passwords, connection strings or API keys. Setting up *Secrets* lets us refer to them by name in our deployments and avoids having sensitive details held in plain text

## Build container images with ACR

For this section we will be using a brand new feature of *Azure Container Registry*  called "ACR Tasks", this allows us to build container images in Azure without need access to a Docker host or having Docker installed locally. It also pushes the resulting images directly into your registry.

We will build our images directly from source. The source of Smilr is held on GitHub in this repository https://github.com/benc-uk/microservices-demoapp

To use ACR Tasks to run our Docker build task in Azure, we call the `az acr build` sub-command. The first image we'll build is for the Smilr data API component, the source Dockerfile is in the **node/data-api** sub-directory and we'll tag the resulting image `smilr/data-api`
```
az acr build --registry $ACR_NAME -g $group --file node/data-api/Dockerfile --image smilr/data-api https://github.com/benc-uk/microservices-demoapp.git
```
**💬 Note.**  If you are familiar with the Docker command line and the `docker build` command you notice some similarity in syntax and approach

**💬 Note.**  If the CLI times out with a "no more logs" message you can still view the build logs by running `az acr task logs -r $ACR_NAME -g $group` to check on the progress

That should take about a minute or two to run. After that we'll build the frontend, the command will be very similar just with a different source file image tag
```
az acr build --registry $ACR_NAME -g $group --file node/frontend/Dockerfile --image smilr/frontend https://github.com/benc-uk/microservices-demoapp.git
```
This will take slightly longer but should complete in 3-5 minutes

If you want to double check the images have been built and stored in your registry you can run
```
az acr repository list -g $group --name $ACR_NAME -o table
```

## End of Module 2
We now have the application images we need built & stored in a private registry. We also have the authorization in place to get AKS to pull/run our images, so we can proceed to look at deploying our microservices into Kubernetes 

---

[🡸 Module 1: Deploying Kubernetes](../part1){: .btn-success}  
[🡺 Module 3: Deploying the Data Layer](../part3){: .btn-success}  
