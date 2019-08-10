---
title: "Kubernetes: Module 5 - Deploying the Frontend"
author: Ben Coleman
date: 2018-10-01
hidden: true

header:
  overlay_image: images/header/kube.png
  teaser: images/teaser/containers.png
sidebar:
  nav: "kubernetes_lab"  
---

## Overview
Now we know how to create deployments and services, we can pick up the pace a little, and get the frontend microservice up and running 

## Deploy Frontend
For the frontend we can start with the service, it doesn't matter that the pods for it don't exist yet, that is what the selector is for, it will pick them up when they are created. This service also needs to be a `LoadBalancer` as we clearly want to access it externally.

Create a new file called **frontend.svc.yaml** (run `touch frontend.svc.yaml` and refresh the files view in the editor) and paste the following YAML contents.
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
Save the file and then run run `kubectl apply -f frontend.svc.yaml`

As before check the status with `kubectl get service`, you can wait for the external IP to be assigned or carry on with the next step

Create another new file called **frontend.deploy.yaml** (run `touch frontend.deploy.yaml` and refresh the files view in the editor) and paste the following YAML contents. You will need to replace **{acr_name}** and **{data_api_external_ip}** (it's public IP we accessed earlier) with their real values.  
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

By now the `frontend-svc` should have an external IP, get this IP using `kubectl get svc/frontend-svc` and copy and paste it into your browser. 

The Smilr app client UI should load and look something like this, (here I've opened the browser console with F12 to check some of the log messages output by the app)

![smilr-app](../images/smilr1.png)

We have a functioning app! Well mostly, wouldn't it be great to have some data in the app to look at. We could use the admin screens to manually create some events, but there is another way and we'll use another feature of Kubernetes to do it

## Create Demo Data
Lastly we'll load some demo data into the app, we can do this by calling the data API we've just deployed and POSTing over example data from a JSON file. The demo data is held in the Smilr git repo

Download the demo data and push it into the app with the following two commands, change the `<<data_api_ip>>` to the actual value of your data API external IP (obtained in the previous step)

```bash
wget https://raw.githubusercontent.com/benc-uk/smilr/master/etc/demodata.json
curl -d @demodata.json -H "Content-Type: application/json" -X POST http://<<data_api_ip>>:4000/api/bulk
```

Now refresh the Smilr app in your browser, and check there are events on the home screen, and go into the reports view to validate there is example feedback in the database.

## End of Module 5
What we have at this stage in Kubernetes is our desired state
![Application Architecture Diagram](../images/arch.png)

But there's a few final improvements we need to make our app more robust

---

[🡸 Module 4: Services & Networking](../part4){: .btn .btn--primary .btn--large}  
[🡺 Module 6: Scaling & Persistence](../part6){: .btn .btn--primary .btn--large} 
