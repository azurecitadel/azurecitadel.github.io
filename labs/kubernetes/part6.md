---
layout: article
title: "Kubernetes: Module 6 - Scaling & Persistence"
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

### Optional - Validate Load Balancing
Demonstrating the load balancing is really happening is a little tricky, you can access the Data API info URL:  
`http://{data-api-svc_external_ip}/api/info`  
And look at the hostname returned, it should change as you make multiple requests (F5) but sometimes your browser or the Azure Load Balancer will decide to stick you to a single host. Another way to see it in action is running the following command repeatedly and observing the hostname returned

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

**💬 Note 1.** There is nothing stopping us scaling the pods to more replicas than we have nodes, Kubernetes will just distribute them across the nodes. There are reasons why you might want to do this (e.g. take advantage of multiple cores on the nodes) but there becomes a point of diminishing returns and scaling out to 80 replicas is not going to magically improve your app performance 80 fold!

**💬 Note 2.** We haven't told Kubernetes anything about the resources our pods will need, e.g. CPU and memory - if we did so it could make more intelligent resource scheduling decisions, this has been left as an optional exercise

---

## Stateful Microservices - MongoDB
We can't simply horizontally scale out the MongoDB deployment with multiple replicas as it is **stateful**, i.e. it holds data and state. 

Kubernetes does provide a feature called *StatefulSets* which greatly helps with the complexities of running multiple stateful services across in a cluster  
[📘 StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/){:target="_blank" class="btn-info"}

> **📕 Kubernetes Glossary.** A *StatefulSet* is much like a *Deployment* but it guarantees the ordering and uniqueness of the *Pods* it controls and each *Pod* is given a persistent identifier that is maintained across any rescheduling.

*StatefulSets* are not a magic wand however - any stateful components such as a database (e.g. MongoDB), still needs to be made aware it is running in multiple places and handle the data synchronization/replication. This [can be done with MongoDB](https://github.com/cvallance/mongo-k8s-sidecar) but is deemed too complex for this lab, and is left for an optional exercise

**💬 Note.** The `ClusterIP` service we created will quite happily "round-robin" between multiple replicas inside the cluster. It's not quite true load balancing, but close enough, this means our choice of service is not the issue here. 

There's also a second more fundamental problem with our MongoDB instance - **it lacks persistence**. Pods (and therefore containers) are by default ephemeral, so any data they write is lost when they are destroyed or re-scheduled

You can test this out by deleting the MongoDB pod, the deployment (*ReplicaSet*) will then immediately re-create it, so it's effectively a restart
```
kubectl delete pod -l app=mongodb
```
After about 30 seconds, reload the Smilr UI and you'll see you've lost all the demo data you had loaded!


### Persisting data with StatefulSets and VolumeClaims
Let's fix our data loss problem. This next part will introduce a lot of new topics, but ends up being quite simple in the end.

Persisting data with Docker containers (not just in Kubernetes) is done through *Volumes*, these are logical chunks of data much like disks. These volumes are managed by the Docker engine, and mounted into a running container at a mount point on the container's internal file system   
[📘 Docker Storage](https://docs.docker.com/storage/){:target="_blank" class="btn-info"}



We'll change the MongoDB deployment to use a *StatefulSet*. Create new file called **mongo.stateful.yaml** (run `touch mongo.stateful.yaml` and refresh the files view in the editor)  and paste the following YAML into the file:
```yaml
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: mongodb
spec:
  serviceName: mongodb
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb-pod
        image: mongo:3.4-jessie
        ports:
        - containerPort: 27017
        volumeMounts:
          - name: mongo-vol
            mountPath: /data/db
  volumeClaimTemplates:
    - metadata:
        name: mongo-vol
      spec:
        accessModes: [ "ReadWriteOnce" ]
        storageClassName: default
        resources:
          requests:
            storage: 500M       
```
This looks a lot like the *Deployment* object we created in module 3, but there's some big differences:
- We declare it as `kind: StatefulSet`
- All *StatefulSets* must have a `serviceName`, this is used when naming the pods it creates in an ordinal series
- We've added a `volumeMounts` section which mounts a volume named `mongo-vol` to the **/data/db** directory inside the container. This is where MongoDB has been configured to persist its database files on the filesystem
- There is a `volumeClaimTemplates` section which defines a *PersistentVolumeClaim* with a *StorageClass* of type **default**. The request is for a *PersistentVolume* with 500Mb storage. This volume is named `mongo-vol` to link to the volumeMount of the container spec

> **📕 Kubernetes Glossary.** A *PersistentVolume* (PV) is a piece of storage in the cluster that has been provisioned by an administrator. It is a resource in the cluster just like a node is a cluster resource. A *PersistentVolumeClaim* (PVC) is a request for storage by a user. A *StorageClass* provides a way for administrators to describe the “classes” of storage they offer.  

[📘 Kubernetes Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#introduction){:target="_blank" class="btn-info"}

**💬 Note.** With AKS two *StorageClasses* are provided out of the box, both are backed by Azure Managed Disks

That's a lot of info to digest, however don't sweat the details. Let's destroy the existing MongoDB deployment
```
kubectl delete -f mongo.deploy.yaml
```

And stand up our new stateful version 
```
kubectl apply -f mongo.stateful.yaml
```

This will take about 5 mins to be fully ready as it needs to create the volume, the Azure disk and then bind that to the host with the pod and also mount the volume into the container in the pod

You can check what is happening, firstly check the *PersistentVolumeClaim* 
```
kubectl get pvc
```
You should see `mongo-vol-mongodb-0` listed and it should move from status **Pending** to **Bound** after a minute. You can also check the *PersistentVolume* with `kubectl get pv`

The pod will be created at this point, but it will be waiting for the *PersistentVolumeClaim* to be bound to it, when you run:
```
kubectl get pods -l app=mongodb -o wide
```
You will see it in **ContainerCreating** status for a few minutes.

To better see what is happening in the pod, and get details, event messages etc, you can run:
```
kubectl describe pod mongodb-0
```
Don't be alarmed if it re-tries a few times and there's some warnings in the events, keep running `kubectl describe` and eventually the container should start and the pod change to **Running** status

**💬 Note.** Notice, the pod doesn't have a randomly generated name as before, this is because *StatefulSets* will name the pods in ordinal sequence, this ensures they will pick up the correct volumes if they were to be re-scheduled into a new host.

We are nearly done, if you wish you can validate the data persistence is working by creating some data in the app (or using the demoData script as before), delete the MongoDB *StatefulSet* with `kubectl delete -f mongo.stateful.yaml` and recreate it `kubectl apply -f mongo.stateful.yaml` the data you created before deletion should be there

## End of Module 6
We are finally done!  
We covered a lot, building up from simple basics to having a scaled out robust & persistent microservices based app. In summary we have:
- Deployed a Kubernetes cluster using AKS
- Created an Azure Container Registry and populated with images
- Used Kubernetes to deploy a number of pods and containers
- Created network services to allow for service discovery & load balancing
- Scaled our app out and made the database persist through failures

However this was just the beginning and only touches on a fraction of what Kubernetes can do, if you have more time take a look at the optional exercises and extra things to investigate

---

[🡸 Module 5: Deploying the Frontend](../part5){: .btn-success}  
[🡺 Extra Optional Exercises](../extra){: .btn-success}
