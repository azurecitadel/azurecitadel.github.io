---
title: Docker For Beginners
category: cloud-native
date: 2020-01-07
tags: [docker]

header:
  teaser: images/teaser/containers-new.png
  overlay_image: images/teaser/containers-new.png
author: Ben Coleman
excerpt: This hands on lab covers the very basics of Docker, building and running images, what a Dockerfile is etc. We also explore some Azure container services, such as Container Registry and Container Instances
---

This is a simple, guided step-by-step lab, intended for people that have never used Docker and want to get hands on with some of the fundamentals of running containers, using the docker client and building images.

We will use '[Docker Machine](https://github.com/docker/machine)' to build and deploy Docker on a VM in Azure. This isn't a very common way of working with Docker, normally you'd have it installed locally, use an Azure service or an orchestrator such as Kubernetes. However Docker Machine does provide a very convenient way to deploy & securely access a full Docker system without the need to install anything locally. This keeps the lab very clean and simple. For real world and production use, Docker Machine should generally not be used.

## Pre-requisites
- Azure subscription
- A basic working knowledge of Azure
- Suggested reading - [Containers Tech Primer](https://aka.ms/docker-primer)

## Access Cloud Shell
We will use the Azure Cloud shell for everything in this lab, login to the shell here  
<a href="https://shell.azure.com" target="_blank" class="btn btn--primary btn--large">💻 shell.azure.com</a>

If you've not accessed the cloud shell before, you will be prompted to setting it up (with an Azure storage account)


## Setup Steps
Once in the cloud shell, make a directory to work out of:
```bash
mkdir dockerlab
cd dockerlab
```

Download the docker-machine binary from GitHub to your cloudshell
```bash
curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` > ./docker-machine
chmod +x ./docker-machine
```

Set some common bash variables, change resource group name & location as required
```bash
resGrp="temp.docker"
region="westeurope"
subId=$(az account show --query id -o tsv)
```
> Note. If you logout or get disconnected from your cloud shell, you may need to re-run these commands

Create a resource group in Azure
```bash
az group create -n $resGrp -l $region
```

## Deploy Docker VM
We will use the `docker-machine create` command to build a VM in Azure, deploy Docker onto it. We will call this machine **dockerhost** which will be both the name of the VM in Azure, but also the name by which the `docker-machine` command will reference it.

This is all done with a single command:
```bash
./docker-machine create \
--driver azure \
--azure-resource-group $resGrp \
--azure-location $region \
--azure-subscription-id $subId \
--azure-size Standard_D2s_v3 \
--azure-open-port 80 \
--azure-open-port 8000 \
dockerhost
```

This will take about 3~5 minutes to complete, once it finishes, check everything is ok with:
```bash
./docker-machine ls
```

You should see something like 
```
NAME         ACTIVE   DRIVER   STATE     URL                       SWARM   DOCKER     ERRORS
dockerhost   -        azure    Running   tcp://52.137.33.94:2376           v19.03.5
```
**IMPORTANT**. Make a note of the IP address (which will be different from what is shown above) and copy/paste it somewhere, you'll need it later.


## Connect & Validate
To allow the local docker client (inside your cloud shell session) to connect to remote VM we run another command. This is simply setting four `DOCKER_` environment vars, which "points" the local docker client at our new remote host.
```bash
eval $(./docker-machine env dockerhost --shell bash)
```
> Note 1. If you logout or reconnect your cloud shell, you will need to re-run this command

> Note 2. If you're curious what these environment vars are, run  
> `printenv | grep DOCKER` to take a look at them

Now the docker client is ready to go, check we're connected OK by running
```bash
docker info
```


## Run A Container from a Public Image
We'll run the standard NGINX webserver as a container, and expose HTTP port 80 so we can connect to it. NGINX is available as an [image on the public Docker registry](https://hub.docker.com/_/nginx) (aka Dockerhub)

We can run it with the following basic `docker run` command, which starts a running container from an image:

```bash
docker run -p 80:80 nginx
```
The `-p 80:80` part of the command tells docker to map a port from inside the container to outside (port 80 in both cases).  

The last parameter is the image name, there's numerous ways that you can specify these to Docker. An extremely simplified summary of what happens 
- Docker will look in the local image cache for an image called "nginx", which will **not** be present, this will trigger an *image pull*.
- Docker will try to *pull* from Dockerhub (the default public Docker registry)
- The image will be pulled down and now reside in the local image cache
- Docker starts the container from the local image

Now go to http://**{public-ip}**/ in your browser to see the "Welcome to nginx!" NGINX holding page served from the container.  

Hit `ctrl+c` in the cloud shell when done to exit the container.  

## Explore Container Basics
The `docker run` command we ran, [can take **many** parameters](https://docs.docker.com/engine/reference/run/), try running `docker run --help` to see them all.

Here we'll explore some of the basic and commonly used parameters you need to know, as well as some other common docker commands. If you wish you can skip to the [Build & Run Custom Image](#build--run-custom-image) section

### Run detached
You noticed how the previous command "locked up" your shell session until you pressed `ctrl+c`? That's going to a problem when you want to run multiple containers or logout. The solution is to add the `-d` or `--detach` parameter, which will run the container in the background

Try running:
```bash
docker run -d -p 80:80 nginx
```
You will see a very long container ID, and be returned to your shell prompt. You should be able to goto http://**{public-ip}**/ in your browser again and see the same NGINX landing page

### List containers
When you run a container detached, how can you find out what containers Docker has running in the background? You can do this with `docker ps`, this lists running containers. It's more common to run `docker ps -a` which will list **all** containers, regardless of their status.

Run:
```bash
docker ps -a
```

### Removing containers
When you ran `docker ps -a` you should have seen two containers, one exited and one "up" or running. The exited one, is from the previous docker run command you ran and pressed `ctrl-c` to terminate. Docker leaves the container in an exited (or stopped) state, incase you want to restart it.

To remove the exited/stopped container, use `docker rm` followed by the id of the container
```bash
docker rm {{container-id}}
```

**TOP-TIP 🚩** When referring to a container by id, you actually only need to supply the first 2 or 3 characters, and Docker will find the matching id for you.

**TOP-TIP 🚩** It's easy for the system to get cluttered up with exited containers, and restarting a container is generally rather uncommon. To prevent this clutter, you can add the `--rm` parameter when starting the container, e.g. `docker run --rm -d -p 80:80 nginx`

### Killing containers
To exit/stop the other container (the one we started running in detached mode), two commands can be used

Stop container (can be restarted later, will need manual removal):
```bash
docker kill {{container-id}}
```

Stop container and remove:
```bash
docker rm -f {{container-id}}
```

Use the later command to stop & remove the other container you have running

### Naming containers
Referring to containers by id can be a little tedious, Docker allows you to name a container when starting it with the `--name` parameter. You will have noticed when running `docker ps` that Docker automatically assigns a random name if you don't specify one

Start the NGINX container again, in detached mode, this time naming it `web`
```bash
docker run -d -p 80:80 --name web nginx
```

Running `docker ps` you should see the container running again with the name you gave it.

> Note. It's possible to muddle container names and image names, container names are used at runtime only

### Interacting with containers
Although it's very common for containers to launch some sort of process and act as a network service (like the NGINX container ran as a web server), they can also be run in both "batch" and "interactive" modes.

Depending on how the container image has been built (more later) running an interactive shell in a container can be done a number of ways. For interactive processes such as a shell, you must use the `-i` `-t` parameters together in order to allocate a tty and open STDIN. This is nearly always combined into `-it`

Start an Alpine Linux container (from the Dockerhub public image) and shell into it with:
```bash
docker run --rm -it alpine
```

From this shell session, you can run a range of bash and standard Linux commands inside the container, e.g. `ls`, `ps`, `top`, `ping`, `wget` etc. Try exploring "inside" the container. When done, type `exit` to exit the shell and terminate the container.

To run a single command and exit the container, you pass the command to the end of the `docker run` command after the image name. This command itself can take parameters which are passed after it

To run the `ls` command and run a long listing of the `/var` directory you can run a Alpine container as follows:
```
docker run --rm -it alpine ls -l /var
```

You can also run a shell in a container which doesn't normally start one:
```bash
docker run --rm -it nginx bash
```
Here we've run a container from the NGINX image as before, but rather than the nginx daemon starting and it serve HTTP traffic (which is the default for this image) we start the bash interactive shell. Note, we didn't supply the `-p 80:80` as it would be redundant 

**TOP-TIP 🚩** It's common practice when running any container in non-detached (foreground) mode to always add `-it` to the command, as often the container will not receive a `ctrl-c` message without it.


## Build & Run Custom Image
So far we've run pre-built images, now we'll look into building our own image to "containerize" some application code.

The application code we'll use has already been written. It's an extremely basic Python application that uses the Flask web microframework to serve a single page.

Clone the git repo from GitHub
```bash
git clone https://github.com/benc-uk/dockerdemo.git
```

To build an image, docker needs a special file called a *Dockerfile* which is effectively a set of build steps and instructions. This file is normally called just `Dockerfile` (without any extension).

Dockerfiles are fundamental to the process of building images, so writing them is a considerable topic to address, therefor this guide will not cover them in depth. [The Docker documentation is a good place to start to learn more](https://docs.docker.com/engine/reference/builder/)

To understand what is going to be built, have a look at the `Dockerfile` but **DON'T change anything!**
```bash
code dockerdemo/Dockerfile
```

Next run the image build, and tag it as `mydemoapp`
```bash
cd dockerdemo
docker build . -f Dockerfile -t mydemoapp
```
Some comments on the parameters of this command:
- The `.` is the "build context" i.e. the directory docker will use for any file operations (COPY, ADD etc). It's common to pass the current working directory with a dot
- `-f Dockerfile` specifies the input *Dockerfile* to use, in this case this parameter could have been removed, as docker looks for a file called `Dockerfile` by default. However it's been specified here for clarity.
- `-t mydemoapp` tags the image as "mydemoapp", for now you can think of this as simply naming the image

You should see the build process kick off, which broadly will be:
- Pull `python:3.6-alpine` image from Dockerhub
- Installs some Python modules with pip
- Copies application code files into the image
- Specifies some configuration
- Specifies what happens when a container starts from this image (with `ENTRYPOINT`)

Once it has built, list all images in the Docker local image cache:
```
docker images
```

You'll see your newly built "mydemoapp" image, as well as the alpine and nginx images which were pulled down and run earlier.

Now start a container from the "mydemoapp" image, it listens on port 8000 (which you can see if you check the `EXPOSE` line in the Dockerfile), so we expose that with `-p` as before, but using 8000 rather than 80
```
docker run -rm -p 8000:8000 mydemoapp
```

Go to **http://{publicip}:8000/** in your browser to view the app (it consists of a single page).   
Hit ctrl+c when done to exit the container. 

### Runtime config
[Modern applications generally use environment variables](https://12factor.net/config) as a way to accept config, rather than files or other means. Docker allows you to pass environment variables to a container at start-up with the `-e` or `--env` parameter. *Note*. How and if these variables are used is always entirely application specific

The demo app we built, will look for and use a variable called `PICTURE_OF` in order to configure what picture to show on the page

Run the container again, but this time pass in `PICTURE_OF` and set it to `cats`
```bash
docker run --rm -p 8000:8000 --env PICTURE_OF="cats" mydemoapp
```

Go to **http://{publicip}:8000/** in your browser to view the app (it consists of a single page). The image shown should change to that of a cat.  
Hit ctrl+c when done to exit the container.
 
### Trouble shooting containers
We'll now look at two common methods for debugging a running container.

Run the container again, but in detached mode, and give it a name "lab1"
```bash
docker run --rm -d -p 8000:8000 --name lab1 mydemoapp
```
The container should start in the background (check with `docker ps`)

In order to get the logs (i.e. anything written to STDOUT or STDERR) run:
```bash
docker logs lab1 
```
You should see any the messages the container has logged. If you run the commands again with `-f` you can follow the logs as they are written, e.g. `docker logs lab1 -f` and hit the page to generate access log messages, which you'll see in the shell. Press `ctrl+c` to exit following the logs

In order to run a command against a running container you can use `docker exec`. Using this we can "shell into" our running container by starting a shell (`sh`) and the `-it` parameters.

```bash
docker exec -it lab1 sh
```

If you run `ps -ef` you should see the python process running inside the container. Type `exit` to exit the container shell and return to the cloud shell. The container will continue to run in the background


## Azure Container Registry
Our image is only available locally, if we wanted to run it on another machine, in Azure or an orchestrator like Kubernetes it needs to be pushed to an external registry. For this we'll use [Azure Container Registry](https://docs.microsoft.com/en-in/azure/container-registry/) (ACR)

Create an ACR instance, You **must** change `acrName` to something globally unique
```bash
acrName=changeme
az acr create -n $acrName -g $resGrp -l $region --sku Standard --admin-enabled true
```

Get the admin password from ACR, this will have been generated for you much like a API/account key
```bash
acrPwd=`az acr credential show -n $acrName --query "passwords[0].value" -o tsv`
```
(Note. The command will not output anything)

Docker needs to authenticate against your registry, this is done with `docker login` and the password. The username is always the same as the ACR instance name, the ACR server hostname is suffixed `.azurecr.io`

Run the following to login
```bash
docker login -p $acrPwd -u $acrName ${acrName}.azurecr.io
```

When it comes to images, Docker relies on convention over configuration, meaning that the name you give an image is actually made up of several parts each of which can modify how Docker behaves. This takes the general form of `{registry-address}/{repository}:{tag}`. If tag is omitted then a tag of "latest" is assumed, if registry-address is omitted then Dockerhub will be used as the default registry. The term "repository" can also be thought of as the name of the image

If order to put the image we built into our Azure Container Registry, it first needs to be tagged correctly.

Re-tag the "mydemoapp" image you just created, adding the ACR prefix of the fully qualified hostname, and tag it `v1`
```bash
docker tag mydemoapp ${acrName}.azurecr.io/mydemoapp:v1
```

Run `docker images` again and you'll see it listed (Note. it will have the same image-id as the un-prefixed "mydemoapp" it's just a named pointer in essence)

Now the image has the correct registry prefix, it can be pushed. This command "uploads" the local image to the registry in Azure:
```bash
docker push ${acrName}.azurecr.io/mydemoapp:v1
```

*Optional.* If you want to see what has happened in Azure, you can (explore your Container Registry via the Azure Portal)[https://portal.azure.com/#blade/HubsExtension/BrowseResourceBlade/resourceType/Microsoft.ContainerRegistry%2Fregistries]. Click into the 'Repositories' blade to see the image you just pushed.

## Run Container in Azure
Now we can run our image in Azure and elsewhere, one of the simplest ways to do this is via Azure's containers-as-a-service offering; Azure Container Instances. 
> Note. Obviously we could continue to run our images in the VM we built, but this isn't a scalable or very robust solution, and at some point you're going to need to move onto something like Kubernetes, so it's best to put this VM out of mind going forward. 

Create the container instance using the Azure CLI, with the following command:
```bash
az container create \
 --name lab1 \
 --image ${acrName}.azurecr.io/mydemoapp:v1 \
 --resource-group $resGrp \
 --ip-address public \
 --ports 8000 \
 --registry-username $acrName \
 --registry-password $acrPwd \
 -o table
```

It should take about a 30~60 seconds to deploy. In the output you will see a public IP and port, you can go to this in your browser to view the application served from the container as before.

## Conclusion
We've covered a lot of the basics of Docker, from using the docker CLI client, running images, troubleshooting through to building custom images & container registries. If you are ready to go further with your learning, some suggested links & reading:
- [Containers learning modules on Microsoft Learn](https://docs.microsoft.com/en-us/learn/browse/?term=containers)
- [Kubernetes Learning Path v2.0](https://aka.ms/kubelab)
- [Kubernetes: Hands On With Microservices](https://aka.ms/kubelab)
- [AKS Workshop](https://aksworkshop.io/)

## Cleanup
The dockerhost VM will be incurring normal Azure VM compute costs, which can quickly add up, it's suggested you either stop (deallocate) or delete this as soon as you are done with the lab, the same goes for the container instance.

To remove the Azure resources and the docker-machine reference from your cloud shell, run:
```bash
~/dockerlab/docker-machine rm dockerhost
```
This will remove the VM and associated resources *but will leave the container registry and container instance.*

To remove all resources, just delete the resource group from Azure

```bash
az group delete -g $resGrp --no-wait
```

You may wish to remove the `dockerlab` directory from your cloud shell with `rm -rf ~/dockerlab`
