---
title: "Kubernetes Advanced: Quick Start"
author: Ben Coleman
date: 2019-07-17
hidden: true

header:
  overlay_image: images/header/kube.png
  teaser: images/teaser/containers.png
sidebar:
  nav: "kubernetes_lab2"
---

## Quick Start
If you want to jump straight in and skip the first lab, this section provides the manifest files and guidance to do so. This is only recommended if you are comfortable with Kubernetes, have some basic experience with AKS and core Kubernetes primitives such as Deployments, Pods and Services

The assumption is you are working in a bash shell (Cloud Shell or local WSL) with the Azure CLI installed and `kubectl` command available 

## Quick Create Cluster
You can use an existing AKS cluster if you have one deployed, alternatively create one as follows:

Set variables
```bash
group=<resource group name>
region=<azure region name>
```

Create resource group and cluster
```bash
az group create -n $group -l $region
az aks create -g $group -n aks-cluster -l $region \
--node-count 3 --node-vm-size Standard_DS2_v2 \
--kubernetes-version 1.13.7 --verbose
```

**💬 Note 1.** The versions of Kubernetes available in AKS change regularly, if version **1.13.7** is not available run `az aks get-versions -l $region -o table` and use the newest version available. It should not affect the lab

Once deployed, connect to it and validate it is running
```bash
az aks get-credentials -g $group -n aks-cluster
kubectl get nodes
```

## Azure Container Registry (ACR)
To save time, rather than use ACR, the pre-built images hosted publicly on Dockerhub will be used.


## Set Up Project & Manifests
Set up your lab project directory and download/extract the Kubernetes manifests from the first lab.

```bash
mkdir kube-lab
cd kube-lab
wget https://azurecitadel.com/cloud-native/kube-advanced/lab1-manifests.zip
unzip lab1-manifests.zip
```

## Quick Deploy Steps
Deploy the data api and MongoDB database:
```bash
kubectl apply -f mongo.stateful.yaml
kubectl apply -f mongo.svc.yaml
kubectl apply -f data-api.deploy.yaml
kubectl apply -f data-api.svc.yaml
```
It might take a minute for MonogDB to start, but you can jump to the next step rather than wait

Get the external IP of data api service, press Ctrl-C when the IP goes from pending to a real public IP
```bash
kubectl get svc/data-api-svc -w
```


Edit **frontend.deploy.yaml** and change the `{data_api_ip}` to the IP address assigned above

Deploy frontend of app:
```bash
kubectl apply -f frontend.deploy.yaml
kubectl apply -f frontend.svc.yaml
```

Get the external IP of frontend service, press Ctrl-C when the IP goes from pending to a real public IP
```bash
kubectl get svc/frontend-svc -w
```

Go to the frontend IP in your browser to access and validate the app is running.

You are now at a point where the last lab finished, and ready to carry on.

---

[🡸 Main Lab Index](..){: .btn .btn--primary .btn--large} 
[🡺 Module 1: Using an Ingress](../part1){: .btn .btn--primary .btn--large}  
