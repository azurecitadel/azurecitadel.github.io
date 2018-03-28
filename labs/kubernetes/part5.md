---
layout: article
title: "Kubernetes: Module 5 - Deploying the Frontend"
date: 2018-03-24
tags: [kubernetes, microservices, containers, azure, aks, nodejs]
comments: true
author: Ben_Coleman
image:
  feature: kube.png
  teaser: containers.png
---

## Overview
Now we know how to create deployments and services, we can pick up the pace a little, and get the frontend microservice up and running 

## Deploy Frontend
For the frontend we can start with the service, it doesn't matter that the pods for it don't exist yet, that is what the selector is for, it will pick them up when they are created. This service also needs to be a `LoadBalancer` as we want to access it externally.

Create a new file called **frontend.svc.yaml** and paste the following YAML contents, save the file and then run run `kubectl apply -f frontend.svc.yaml`
```yaml
kind: Service
apiVersion: v1
metadata:
  name: frontend-svc
spec:
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  selector:
    app: frontend
```
As before check the status with `kubectl get service`, you can wait for the external IP to be assigned or carry on with the next step

Create another new file called **frontend.deploy.yaml** and paste the following YAML contents. You will need to replace **{acr_name}** and **{data_api_ip}** with their real values.  
If you skipped Part 2, you are not using ACR, then you can omit the registry and just use `smilr/frontend` as the image and remove the `imagePullSecrets:` section.

Save the file and then run `kubectl apply -f frontend.deploy.yaml`
```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend-pod
        image: {acr_name}.azurecr.io/smilr/frontend
        ports:
        - containerPort: 3000
        env:
        - name: API_ENDPOINT
          value: http://{data_api_ip}/api
      imagePullSecrets:
      - name: acr-auth
```
Check the frontend pod is running with `kubectl get pods`. 

By now the `frontend-svc` should have an external IP, get this IP using `kubectl get svc/data-api-svc` and copy and paste it into your browser. 

The Smilr app client UI should load and look something like this, (here I've opened the browser console with F12 to check some of the log messages output by the app)

![smlir-app](/labs/kubernetes/images/smilr1.png)

We have a functioning app! Well mostly, wouldn't it be great to have some data in the app to look at. We could use the admin screens to manually create some events, but there is another way and we'll use another feature of Kubernetes to do it

## Create Demo Data
Inside the data-api container image is a Node.js script which can be run to initialise the MongoDB database with some demo data. Let's look how we can run that script.

First get the name of the data-api pod with:
```
kubectl get pods -l app=data-api
```

Next we execute a command directly on one of the pods, in this case the bash shell 
```
kubectl exec -it {pod_name} bash
```
You should see a linux command prompt, as this will drop us into a bash shell session right inside the running container in the pod. Run the `ls` command and have a look about, and running `ps -ef` you will see the node process which is the microservice data-api app running inside the container 

**💬 Note.**  The `-it` part of the kubectl command tells Docker to give us an interactive session, and we run `bash` as it the Smilr images are based on Linux. Not all Linux containers have bash installed and sometimes you need to fall back to plain `sh`. If this was a Windows container you would use `powershell` or the new `pwsh` command to start PowerShell Core

To run the script we need in the container:
```
cd demoData
node demoData.js
```
This will connect to MongoDB, and inject some demo data (events and feedback) you should see some messages confirming what it has done.

Now refresh the Smilr app in your browser, and check there are events on the home screen, and go into te reports view to validate there is example feedback in the database.

## End of Module 5
What we have have at this stage in Kubernetes is our desired state
![Application Architecture Diagram](/labs/kubernetes/images/arch.png)

But there's a few final improvements we need to make our app more robust

---

[🡸 Module 3: Deploying the Data Layer](../part3){: .btn-success}  
[🡺 Module 5: Deploying the Frontend](../part5){: .btn-success}
