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

This lab is a continuation of the ["DevOps with VS Code, VSTS & Azure App Service"](/labs/devops-vsts/) lab where a Node.js application was created, built & deployed using CI/CD. This lab can follow on directly, or you can jump in and start at this point. Note this lab is intended for people that have very little or no exposure to Docker & containers, it is not a deep dive and only scratches the surface of what can be done with containers in Azure

The high-level flow is:
1. Containerize the Node.js app using Dockerfile
1. Build Docker image and test locally
1. Deploy Azure Container Registry
1. Push your image to Azure Container Registry
1. Deploy app as container in Azure using Azure Container Instance

# Main Lab Flow

[Ensure you have all the pre-requisites installed](/workshops/devops-vsts/) before starting the main lab.

### Base Node.js application
The starting point requires a functioning Node.js application, there are two options:
- Continue from the previous lab, in which case carry on using the **myapp** Node.js project which you already have on your local machine
- Jump in at this point, in which case download [myapp.zip](./myapp.zip) which has been already created and prepared, and extract onto your local machine in a suitable location

### Create Dockerfile
If you downloaded the app, then have VSCode open the extracted folder as a project. Right click on the folder in Windows Explorer and pick "Open with Code". If you are using your own app, then VSCode should already be open.

- Open the VSCode command pallet `Ctrl + Shift + P` and type "docker" and then pick **Add docker files to workspace** from the results.
- When prompted for application platform pick *Node.js*, and *3000* for the port

This will add three files to your project, the two .yml files we can ignore, we won't be using Docker Compose. The **Dockerfile** is what we're interested in. We don't need to make any changes but if you're unfamiliar with Docker, it's worth opening and looking at, if you've created Docker images before, then move on.  
Here is some high level explanation of what the **Dockerfile** is doing:  
- Since, a Docker image is a series of layers built on top of each other, you always start from a base image. The `FROM` command sets this base image, here we're using an image pre-built with Node.js. This is an official image published by the Node foundation and [hosted on Dockerhub](https://hub.docker.com/_/node/). The default image is the Alpine Linux variant, which means it is very small and lightweight  
- The series of `COPY` and `RUN` commands go about running the `npm install` which is a required build step for Node.js applications
- The `EXPOSE` command is a hint which network ports your application uses and will be listening on. These will be mapped out to the Docker host when this container runs.  
- The last `CMD` part is what starts the app up, in this case it's the `npm start` command (if you did the previous lab you will be familiar with this)

### Build Docker image and test
Ensure that Docker is installed and running on your local machine.  
- Open the VSCode terminal `Ctrl + '`
- Run `docker build . -t myapp-image` this tells Docker to run the build process in the current directory (it looks for **Dockerfile** by default so there's no need to specify it), and tag the resulting image with the name **myapp-image**
You will see Docker pull down the required base image and run the build steps in the **Dockerfile**
- Start the container locally by running `docker run -d -p 3000:3000 myapp-image` then validate the container is running with `docker ps`, and by going to `http://localhost:3000` and viewing the Node.js Express web app in your browser
- Kill and remove the running container by running `docker rm -f <container-id>` where \<container-id\> is the ID of the container you saw when you ran `docker ps`.  
Tip. You can enter the first 2 or 3 characters of the ID and Docker will match it.

### Deploy Azure Container Registry
We will now create a registry to store our image, as currently it only exists on our machine. For this will we use the [Azure Container Registry](https://azure.microsoft.com/en-gb/services/container-registry/) service. From the Azure portal:
- Click on the plus + symbol on the left hand side bar
- In the marketplace menu, go to *Containers* -> *Azure Container Registry*
  - Specify a unique name for your Azure Container Registry, this has to be globally & publicly unique, so use something like `myappreg<your initials>` (Note. hypens, spaces and underscores are not allowed)
  - For resource group either use the one created in the previous lab (e.g. `MyAppRG-Staging`) or create a new one, e.g. `MyAppRG-Containers`
  - Select **West Europe** for location
  - Make sure you **enable the admin user** account
  - Pick **Standard** as the SKU

Wait for the deployment to complete

### Push image up to Azure Container Registry
Click into your new registry resource in the Azure portal:
- Click on **Access Keys** on the blade
- Copy the first password

Back in VSCode:
- In the terminal window run `docker login <your-registry>.azurecr.io`
- When prompted enter **\<your-registry-name\>** as the username, and paste the password you copied from the portal. You should see 'Login succeeded'
- Now run `docker tag myapp-image <your-registry>.azurecr.io/lab/myapp-image` to tag the image you built with the registry name prefix. This tells Docker to store it in the remote registry (in Azure) and in a repository called 'lab'.  
Note. the repository name isn't important and the name 'lab' has no special significance 
- You can validate the last step, by running `docker images` you should see both your **myapp-image** and the one tagged with the registry, but they will have the same image ID, as they point to the same Docker image 
- Now run `docker push <your-registry>.azurecr.io/lab/myapp-image` and you should see Docker uploading and pushing the image from your local machine into the registry in Azure. You can validate this step by clicking on the **Repositories** blade in the Azure portal


### Deploy as container in Azure Container Instance
For this part of the lab, we will use the Azure CLI however you can achieve the same result from the portal and other methods.

If you don't have the Azure CLI installed on your machine an easy way to access it is from the **Cloud Shell** within the Azure Portal. 
- Start an Azure Cloud Shell session. Click [here](https://docs.microsoft.com/en-gb/azure/cloud-shell/quickstart) if you are unsure how
- We will deploy our app as a container using [Azure Container Instance](https://azure.microsoft.com/en-gb/services/container-instances/), which is a fast and simple way to create a running container. Run the following command; 
`az container create --n mycontainer -g <resource-group> --image <your-registry>.azurecr.io/lab/myapp-image --ip-address public --port 3000`  
As this is a lengthy command you might want to copy and paste it into an empty scratch file in VSCode and replace the placeholder values there. Use the same resource group as you used previously
- You will be prompted for a password, navigate to your container registry in the portal, and get the password as before from the **Access keys** blade. Copy and paste into the shell window. Tip. You will probably need to right click with the mouse as `Ctrl+V` may not work (browser dependant)
- You should see chunk of JSON returned as output, validate the container being created with `az container list -o table`. You should see your new container listed, wait until the status changes from 'Creating' to 'Succeeded', repeating the `list` command if necessary.
- In the `list` output will be the assigned public IP address of the new container, put this IP and the port (3000) into the browser e.g. `http://12.34.56.67:3000` and connect to the running Node.js app

---

Congratulations. You finished the lab! 

To summarise what we just did:

* Containerized a web application and ran it locally in Docker
* Created a container registry in Azure and pushed your image to it
* Deployed your app as a container running in Azure

# Follow-on Activities

1. There are many other Azure Services that can run containers, try getting your image running in one of them, Azure App Services would be a good place to start.

2. Investigate using Webhooks to re-deploy and refresh your running container

3. Add a CI/CD build process for your container using VSTS


