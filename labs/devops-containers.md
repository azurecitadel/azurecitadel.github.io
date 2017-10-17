---
layout: article
title: Containerizing Apps with Azure
date: 2017-10-17
categories: labs
tags: [vscode, docker, containers, nodejs, lab]
comments: true
author: Ben_Coleman
excerpt: In this lab we will containerize a simple Node.js web application and deploy it to Azure
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---

{% include toc.html %}

# Overview

This lab is a continuation of the ["DevOps with VS Code, VSTS & Azure App Service"](/labs/devops-vsts/) lab where a Node.js application was created, built & deployed using CI/CD. This lab can follow on directly, or you can jump in and start at this point

The high-level flow is:
1. Containerize the Node.js app using Dockerfile
2. Build Docker image and test locally
3. Deploy Azure Container Registry
4. Push your image to Azure Container Registry
5. Use Azure Cloud Shell
6. Deploy app as container in Azure using Azure Container Instance

![deployment pipeline](./images/vscode-git-ci-cd-to-azure.png)

# Main Lab Flow

[Ensure you have all the pre-requisites installed](/workshops/devops-vsts/) before starting the main lab.

### Base Node.js application
The starting point requires a functioning Node.js application, there are two options:
- Continue from the previous lab, in which case carry on using the **myapp** Node.js project which you already have on your local machine
- Jump in at this point, in which case download [myapp.zip](./myapp.zip) which has been already created and prepared, and extract onto your local machine in a suitable location

### Create Dockerfile
If you downloaded the app, then have VSCode open the extracted folder as a project. Right click on the folder in Windows Explorer and pick "Open with Code". If you are using your own app, then VSCode should already be open.

- Open the VSCode command pallet `Ctrl + Shift + P` and pick **Add docker files to workspace**
- Pick *Node.js* and *3000* when prompted 

This will add three files to your project, the two compose YAML files we can ignore. The **Dockerfile** is what we're interested in. We don't need to make any changes but if you're unfamiliar with Docker, it's worth opening and looking at, if you've created Docker images before, then move on.  
Here is some high level explanation of what the **Dockerfile** is doing:  
- Since, a Docker image is nothing but a series of layers built on top of each other, you always start from a base image. The `FROM` command sets this base image, here we're using an image pre-built with Node.js. This is an official image published by the Node foundation and [hosted on Dockerhub](https://hub.docker.com/_/node/). The default image is the Alpine Linux variant, which means it is very small and lightweight  
- The series of `COPY` and `RUN` commands go about running the `npm install` which is a required build step for Node.js applications
- The `EXPOSE` command is a hint which network ports your application uses and will be listening on. These will be mapped out to the Docker host when this container runs.  
- The last `CMD` part is what starts the app up, in this case it's the `npm start` command (if you did the previous lab you will be familiar with this)

### Build Docker image and test
Ensure that Docker is installed and running on your local machine.  
- Open the VSCode terminal `Ctrl + '`
- Run `docker build . -t myapp-image` you will see Docker pull down the required base image and run the build steps in the Dockerfile
- Start the container locally by running `docker run -d -p 3000:3000 myapp-image` then validate the container is running with `docker ps`, and by going to `http://localhost:3000` and viewing the Node.js Express web app in your browser
- Kill and remove the running container by running `docker rm -f <container-id>` where \<container-id\> is the ID of the container when you ran `docker ps`. Tip. You can enter the first 2 or 3 characters of the ID and Docker will match it.

### Deploy Azure Container Registry

### Push image up to Azure Container Registry

### Deploy as container in Azure Container Instance
`az container create --n mycontainer -g <resource-group> --image <your-registry>.azurecr.io/lab/myapp-image --ip-address public --port 3000`

---

Congratulations. You finished the lab! 

To summarise what you just did:

* You did things
* You did more things

# Follow-on Activities

1. ????