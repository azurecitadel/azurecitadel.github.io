---
title: "Kubernetes: Module 1 - Deploying Kubernetes"
author: Ben Coleman
date: 2018-10-01
hidden: true

header:
  overlay_image: images/header/kube.png
  teaser: images/teaser/containers.png
sidebar:
  nav: "kubernetes_lab"
---

## Registering Providers

AKS is a generally available (GA) service as of June 2018 and is currently available in select regions across the globe. Please see the current [Product Region Availability](https://azure.microsoft.com/en-us/global-infrastructure/services/?products=kubernetes-service&regions=all) table for updated reference and roadmap regions.

If this is a new subscription created from an Azure Pass or trial, the core `Network`, `Storage` & `Compute` providers may not be registered.
Run the following commands to ensure all four providers are enabled:

```bash
az provider register -n Microsoft.Network
az provider register -n Microsoft.Storage
az provider register -n Microsoft.Compute
az provider register -n Microsoft.ContainerService
```

## Deploying AKS
We will begin by deploying Kubernetes using [*Azure Kubernetes Service (AKS)*](https://azure.microsoft.com/en-us/services/container-service/) (for the rest of the document we will simply refer to it as AKS)

> Pick an Azure region and use it for everything you create in this lab. We will use **westeurope**, but you can use one of the other regions listed in the [Product Region Availability](https://azure.microsoft.com/en-us/global-infrastructure/services/?products=kubernetes-service&regions=all) table.
Note. If you are using an Azure Pass or Internal Use subscription, you will be limited to westeurope and eastus

Set Bash environment variables for the Azure region and resource group you plan to use in this walk through. You can pick anything for the resource group name (no spaces), a suggestion is *kube-lab* for `group`

```bash
group=<resource group name>
region=<azure region name>
```

Using the Azure CLI creating an AKS cluster is easy. First create a resource group:

```bash
az group create -n $group -l $region
```

The most basic form of the AKS create command using all the defaults is simply this. (But please don't run this command) `az aks create -g $group -n aks-cluster -l $region`

However you will probably want to customize your cluster, some common options are:

- **\-\-node-count** - Number of nodes in your cluster
- **\-\-node-vm-size** - Azure VM size (e.g. `Standard_A2_v2`)
- **\-\-kubernetes-version** - Kubernetes version (run `az aks get-versions -o table -l $region` to list available versions)

[📘 AKS Create docs](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create){:target="_blank" class="btn btn--success"}

> **📕 Kubernetes Glossary.** A *Node* is a worker machine in Kubernetes, it hosts the workloads in your cluster and runs the containers

The `az aks create` command uses your default SSH keypair located in **~/.ssh/id_rsa.pub** to provision the cluster nodes. If you've never used Cloud Shell or WSL Bash before, these keys won't exist then you must add `--generate-ssh-keys` to the command, as shown below.

For this lab the recommended cluster configuration and command to run is

```bash
az aks create -g $group -n aks-cluster -l $region \
--node-count 3 --node-vm-size Standard_DS2_v2 \
--kubernetes-version 1.11.10 --verbose
```

This is a three node cluster, running Kubernetes 1.11.10 using D-series VMs with 2 cores to minimize costs but allow for reasonable reliability of the cluster.

**💬 Note 1.** The versions of Kubernetes available in AKS change regularly, if version **1.11.10** is not available run `az aks get-versions -l $region -o table` and use the newest version available. It should not affect the lab.

**💬 Note 2.** The command might take some time to complete, around 6 to 10 mins is normal, but in some cases it may take up to 30 minutes.

**💬 Note 3.** To save costs you can optionally enable auto-shutdown on the node VMs. Find the resource group named **MC_kube-lab_aks-cluster_westeurope** this will contain your cluster's nodes and other Azure resources. Click on each of the VMs and switch on the auto shutdown feature. You will need to manually start them again when you want to use your cluster, which might take around 5 mins, but having the nodes shutdown you can keep your AKS cluster deployed indefinitely for essentially zero cost

## Get Kubectl CLI tool (WSL Bash Only)

To access the Kubernetes system you will be using the standard Kubernetes `kubectl` command line tool. We will be using this command a lot and it allows complete control and administration of a Kubernetes cluster.

If you are using *Azure Cloud Shell* you can skip this part as `kubectl` is already installed, so you can jump to **Accessing your Cluster**

To download the `kubectl` binary run:

```bash
sudo az aks install-cli
```

Test the command has been installed and is in your path by simply running `kubectl`

## Accessing your Cluster

In order to access and manage Kubernetes `kubectl` command works off a set of cached credentials, held in the **.kube** directory your user profile/homedir. The Azure CLI makes getting these credentials for your AKS instance easy. This command effectively "logs you in" to Kubernetes:

```bash
az aks get-credentials -g $group -n aks-cluster
```

## Sanity Check Kubernetes and AKS

It is recommended run the following to check your cluster is up and operational.

```bash
kubectl cluster-info
kubectl get nodes
```

You should see information about your cluster and then information about each of the nodes you requested when you built the cluster (e.g. three) and their status, which should be **Ready**

Another good check to run is listing all the pods running, in the `kube-system` namespace:

```bash
kubectl get all -n kube-system
```

> **📕 Kubernetes Glossary.** A *Namespace* is abstraction used by Kubernetes to support multiple virtual clusters on the same physical cluster. Think of it as a kind of multi-tenancy. For this lab we will be deploying our app to the **default** namespace

## Access Kubernetes Dashboard

Accessing the Kubernetes dashboard is optional, but if it's your first time using Kubernetes it can help provide a lot of visibility into what is going on.

For the lab we will use the command line for everything, and all commands will be provided. However it is useful to be able to sanity check and see what is going on using the dashboard. It's a matter of personal choice if you want to use the dashboard, but it's worth having to hand for triaging problems and investigation.

By default, the Kubernetes dashboard is deployed with minimal read access and displays RBAC access errors. To prevent this, you have to run this command

```bash
kubectl create clusterrolebinding kubernetes-dashboard \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:kubernetes-dashboard
```

If using WSL Bash on your local machine or in Azure Cloud Shell, the dashboard can be accessed via a proxy tunnel into the dashboard pod (which is automatically running in your AKS cluster). To create this proxy, run this command:

```bash
az aks browse -g $group -n aks-cluster
```

- If using WSL Bash locally - Access the dashboard by going to [http://127.0.0.1:8001](http://127.0.0.1:8001) in your browser.
- If using Azure Cloud Shell - The dashboard will open in a new browser tab, check if the pop-up has been blocked. Alternatively click the link provided in the command output

**💬 Note 1.** This command doesn't return to the prompt when executed, so run it in a new window, tab or terminal. Azure Cloud Shell has a 'Open new session' icon on the toolbar for doing this.

**💬 Note 2.**  It is not uncommon for the proxy/tunnel to drop after short periods of inactivity, so be prepared to re-start the command if the dashboard stops responding, use Ctrl+C to stop the command and then re-run it.

## End of Module 1

With an AKS cluster deployed and operational we're in a position to start using it, next we'll prepare the images we need and then look at deploying them to Kubernetes

---

[🡸 Main Lab Index](..){: .btn .btn--primary .btn--large} 
[🡺 Module 2: Azure Container Registry (ACR)](../part2){: .btn .btn--primary .btn--large}  
