---
layout: article
title: Docker
date: 2018-01-23
tags: [pre-requisites, pre-reqs, prereqs, hackathon, lab, template]
comments: true
author: John_Duckmanton
image:
  feature: 
  teaser: cloud-builder.png
  thumb: 
---
Install Docker for Windows or Docker for Mac

## Download & Install the Docker software

#### Windows

* Navigate to the Docker download page [Docker for Windows](https://www.docker.com/docker-windows)
* Select **Download from Docker store**
* Click **Get Docker CE for Windows (stable)**
  * Accept all defaults on install

  You may be prompted to log out and back in. 
  You may be prompted to enable Hyper-V:
  
  ![Hyper-V Message](./docker/images/hyper-v-message.png)

  in which case, click **OK** and your system will reboot.

#### Mac

* Navigate to the Docker download page [Docker for Mac](https://www.docker.com/docker-mac)

* Select **Download from Docker store**
* Select **Get Docker**

## Verify the Installation

You should have a Docker "whale" icon in the systray and see a popup saying “Docker is running”.

> You might want to stop Docker auto-starting on your workstation at boot:
> * Right-click on *whale* icon 
> * Select **Settings > General**
> * Untick **Start Docker when you log in**