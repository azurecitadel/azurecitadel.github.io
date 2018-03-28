---
layout: article
title: "Kubernetes: Module 6 - Scaling & Persistence"
date: 2018-03-24
tags: [kubernetes, microservices, containers, azure, aks, nodejs]
comments: true
author: Ben_Coleman
image:
  feature: kube.png
  teaser: containers.png
---

## Overview
In this final module we will look at ways to make our app resilient and performant through the use of pod scaling and volume persistence


## Scale Up Stateless Microservices
Both the Data API and Frontend microservices are stateless, this means we are free to scale them across multiple instances (aka horizontal scaling)

Kubernetes makes this very easy and the *ReplicaSet* which was created by our *Deployment* will do the work for us. You can scale a deployment with a simple `kubectl scale` command. 

### Scale Data API
Let's scale the `data-api` deployment to three replicas:
```
kubectl scale --replicas=3 deploy/data-api
```

An alternative way to do this is editing the **data-api.deploy.yaml** file, change the replicas from 1 to 3 and then run `kubectl apply -f data-api.deploy.yaml`. Either way works

Now list our Data API pods, using wide output so we get more details 
```
kubectl get pods -o wide -l app=data-api
```

You should see three pods, all named with the same **data-api-** prefix and those pods have automatically been spread out to run across different nodes (three nodes if you built the cluster as per the defaults). 

The *Service* we placed in front of the Data API was a *LoadBalancer*, so that will automatically start to distribute requests across the three pods. Because we specified a selector (`app=data-api`) the new pods are matched against this selector and automatically picked up. There's nothing we need to do, this highlights some of the power and ease of scaling that Kubernetes provides.

### Optional - Validate Loadbalancing
Demonstrating the load balancing is really happening is a little tricky, you can access the Data API info URL:  
`http://{data-api-svc_external_ip}/api/info`  
And look at the hostname returned, it should change as you make multiple requests (F5) but sometimes your browser or the Azure Loadbalancer will decide to stick you to a single host. Another way to see it in action is running the following command repeatedly and observing the hostname returned

```
wget -q -O- http://{data-api-svc_external_ip}/api/info | jq '.hostname'
```

### Scale Frontend
Now scale the `frontend` deployment to three replicas:
```
kubectl scale --replicas=3 deploy/frontend
```

As previously; an alternative way to do this is editing the **frontend.deploy.yaml** file, change the replicas from 1 to 3 and then run `kubectl apply -f frontend.deploy.yaml`. 

You can validate the scale out has happened by running: `kubectl get pods -o wide -l app=frontend`

### Benefits
What are the benefits of what we've just 

## Stateful Microservices - MongoDB


---

[🡸 Module 5: Deploying the Frontend](../part5){: .btn-success}  
[🡺 Module x: xxxxxxxx](#){: .btn-success}
