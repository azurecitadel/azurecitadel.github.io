---
layout: article
title: "Kubernetes: Extra Optional Exercises"
date: 2018-10-01
tags: [kubernetes, microservices, containers, azure, aks, nodejs]
comments: true
author: Ben_Coleman
image:
  feature: kube.png
  teaser: containers.png
---
This section contains a few ideas for expanding on what was done in the main lab. These are provided as pointers rather than step by step exercises

## Basic Kubernetes Practices
- **Container Health Probes**  
We haven't told Kubernetes any way to know if Smilr app containers it deployed were healthy and actually operational. A started container is not a direct indication of operational health. Kubernetes provides mechanisms called *Liveness and Readiness Probes* to give it an understanding of the health of the pods  
[📘 Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#define-readiness-probes){:target="_blank" class="btn-info"}

- **Pod Resources**  
We didn't provide Kubernetes with any information about how much memory or CPU our pods would need, or the max they should be allowed to use. This can be done with resource requests and resource limits, and it allows Kubernetes to better distribute pods across the nodes  
[📘 Managing Compute Resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/){:target="_blank" class="btn-info"}

- **Auto Scaling**  
We manually scaled our deployments, however there are many cases where you want the scaling up & down to be done automatically. This can be done with the *Horizontal Pod Autoscaler*  
[📘 Auto Scaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/){:target="_blank" class="btn-info"}

- **Initialisation**  
Rather than manually running the demoData script we could have used an *InitContainer* to run the script before starting the rest of the containers in the data-api pod   
[📘 Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/){:target="_blank" class="btn-info"}


## Extending with Azure
- **Cosmos DB**  
The MongoDB instance could quite easily be replaced with Cosmos DB, it has a MongoDB API and is compatible with the Smilr app   
[📘 Azure Cosmos DB: MongoDB API](https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb-introduction){:target="_blank" class="btn-info"}


## Advanced
- **MongoDB Replication**  
We skipped over this in the main lab, but it can be investigated as an extra task, it requires a "sidecar" container and the use of the StatefulSet we already set up. The sidecar container does some of the Mongo configuration for us  
[📘 Kubernetes sidecar for Mongo](https://github.com/cvallance/mongo-k8s-sidecar){:target="_blank" class="btn-info"}

- **Helm Chart**  
We ended up with a lot of YAML files and in some of them we were making manual changes. Helm provides a way to package Kubernetes apps and manage all the YAML with templates. A Helm chart could be created for Smilr  
[📘 Helm: Package Manager for Kubernetes](https://docs.helm.sh/){:target="_blank" class="btn-info"}
