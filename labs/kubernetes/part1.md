---
layout: article
title: "Kubernetes: Module 1 - Deploying Kubernetes"
date: 2018-03-24
tags: [kubernetes, microservices, containers, azure, aks, nodejs]
comments: true
author: Ben_Coleman
image:
  feature: kube.png
  teaser: containers.png
---

{% include toc.html %}

## Deploying AKS
We will begin by deploying Kubernetes using [*Azure Container Service (AKS)*](https://azure.microsoft.com/en-us/services/container-service/) (for the rest of the document we will simply refer to it as AKS)

**💬 Note.** At the time of writing (Mar 2018) AKS is in preview and the only regions where AKS can be deployed are: **westeurope, westus2, eastus, centralus, canadacentral** & **canadaeast**   
> Pick a location and use it for everything you create in this lab. We will use **westeurope**, but you can use one of the other regions listed above if you wish

Using the Azure CLI creating an AKS cluster is easy. First create a resource group:
```
az group create -n kube-lab -l westeurope
```

The most basic form of the AKS create command using all the defaults is simply:
```
az aks create -g kube-lab -n aks-cluster -l westeurope
```

However you will probably want to customize your cluster, some common options are:
- **\-\-node-count** - Number of nodes in your cluster
- **\-\-node-vm-size** - Azure VM size (e.g. `Standard_A2_v2`)
- **\-\-kubernetes-version** - Kubernetes version (run `az aks get-versions -o table` to list available versions)

[📘 AKS Create docs](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create){:target="_blank" class="btn-info"}

> **📕 Kubernetes Glossary.** A *Node* is a worker machine in Kubernetes, it hosts the workloads in your cluster and runs the containers

A recommended cluster configuration for this lab is as follows:
```
az aks create -g kube-lab -n aks-cluster -l westeurope --node-count 3 --node-vm-size Standard_B4ms --kubernetes-version 1.9.2
```
This is a three node cluster, running Kubernetes 1.9.2 using B-Series burstable VMs to minimize costs

**💬 Note 1.** The command might take some time to complete, around 30 mins is normal, but in some cases up to an hour.

**💬 Note 2.** The `az aks create` command uses your default SSH keys located in **~/.ssh/id_rsa.pub** to provision the cluster nodes. If these keys don't exist then a SSH key pair will be created for you. If you have your own SSH keys you wish to use, then add the `--ssh-key-value` parameter and provide the key public contents as a string

**💬 Note 3.** To save costs you can optionally enable auto-shutdown on the node VMs. Find the resource group named **MC_kube-lab_aks-cluster_westeurope** this will contain your cluster's nodes and other Azure resources. Click on each of the VMs and switch on the auto shutdown feature. You will need to manually start them again when you want to use your cluster, which might take around 5 mins, but having the nodes shutdown you can keep your AKS cluster deployed indefinitely for essentially zero cost


## Get Kubectl and Credentials
To access the Kubernetes system you will be using the standard Kubernetes `kubectl` command line tool. We will be using this command a lot and it allows complete control and administration of a Kubernetes cluster.  
To download the `kubectl` binary run:
```
az aks install-cli
```
If you get an error try running with `sudo` or by specifying the output file and path e.g. `az aks install-cli --install-location /home/blah/kubectl` If you do this, it is your responsibility to add the `kubectl` binary to your path

The `kubectl` command works off a set of cached credentials, held in the **.kube** directory your user profile/homedir. The Azure CLI makes getting these credentials for your AKS instance easy. This command effectively "logs you in" to Kubernetes:
```
az aks get-credentials -g kube-lab -n aks-cluster
```

## Sanity Check Kubernetes and AKS
It is recommended run the following to check your cluster is up and operational.
```
kubectl get nodes
```
You should see each of the nodes you requested when you built the cluster (e.g. three) and their status, which should be **Ready**


Another good check to run is listing all the pods running, in the `kube-system` namespace:
```
kubectl get all -n kube-system
```
> **📕 Kubernetes Glossary.** A *Namespace* is abstraction used by Kubernetes to support multiple virtual clusters on the same physical cluster. Think of it as a kind of multi-tenancy. For this lab we will be deploying our app to the **default** namespace


## Access Kubernetes Dashboard 
Accessing the Kubernetes dashboard is entirely optional, but if it's your first time using Kubernetes it can help provide visibility into what is going on. 

For the lab we will use the command line for everything, however it is nice to be able to sanity check and see what is going on using the dashboard

The dashboard is accessed via a proxy tunnel into the Kubernetes cluster itself. To create this proxy:
```
az aks browse -g kube-lab -n aks-cluster
```
To access the dashboard go to [http://127.0.0.1:8001](http://127.0.0.1:8001) in your browser. 

**💬 Note 1.** This command doesn't return to the prompt when executed, so run it in a new window or terminal

**💬 Note 2.**  It is fairly common for the proxy to drop after short periods of inactivity, so be prepared to re-start the `az aks browse` command if the dashboard stops responding

---

[🡸 Lab Index](..){: .btn-success}  
[🡺 Module 2: Azure Container Registry (ACR)](../part2){: .btn-success}
