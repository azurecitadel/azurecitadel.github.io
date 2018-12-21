---
title: Demo Web Apps
date: 2017-09-12
category: web
tags: [nodejs, python, dotnet, angular]
author: Ben Coleman
header:
  teaser: /images/teaser/blueprint.png
---

# Overview

This is a range of demo apps, all of which are aimed at for deployment to Azure and Docker containers. These are designed for demos and hands on lab exercises, to be used with Azure and DevOps CI & CD scenarios, where you need "something" to deploy and push through the pipeline or to demonstrate another Azure service.  

Most of the apps are small simple web applications but they are designed for ease of deployment, showcasing use of open source in Azure and running within containers, rather than complete rigid examples of a fully functioning architecture.  

Note. There is no requirement to deploy these to Azure they can be run locally, in a VM or other supporting platform 

All apps can be deployed to:
- Run locally 
- Run as Docker container
- Run in Azure App Service
- Run in Azure Web App for Containers 
- Run in Azure Container Instance
- Run in Kubernetes

ARM templates are provided for Azure deployment along with "quick deploy to Azure" buttons

---

# Vue.js & Go
This is a simple web application with a Go server/backend and a Vue.js SPA (Single Page Application) frontend. Designed for running in Azure & containers for demos.

- The SPA component was created using the Vue CLI and uses Bootstrap-Vue and Font Awesome. In addition Gauge.js is used for the dials in the monitoring view
- The Go component is a vanilla Go HTTP server using gopsutils for monitoring metrics, and Mux for routing

[https://github.com/benc-uk/vuego-demoapp](https://github.com/benc-uk/vuego-demoapp){: .btn .btn--primary .btn--large}

<img src="https://user-images.githubusercontent.com/14982936/38804618-e1a5c1bc-416a-11e8-9cf3-c64689faf6cb.png" width="600">

---

# Node.js Express
This is a simple Node.js web app using the Express framework and EJS templates. It has been designed with cloud demos in mind, to show things like auto scaling in Azure and Application Insights monitoring

The app has four basic pages accessed from the top navigation menu:
 - **INFO** - Will show some system & runtime information, and will also display if the app is running from within a Docker container.  
 - **WEATHER** - Gets the location of the client page (with HTML5 Geolocation). The resulting location is used to fetch a weather forecast from the [Dark Sky](http://darksky.net) weather API. The results are show using animated [Skycons](https://darkskyapp.github.io/skycons/). The has the added bonus of allowing you to see dependency calls (out to external APIs) when monitored by App Insights. Dark Sky API key needs to be provided, see configuration below
 - **CPU LOAD** - Simply runs a lot of maths calcs in a loop to max the CPU, can be used to trigger auto-scaling rules and other monitoring scenarios
 - **TODO** - This is a small todo/task-list app which uses MongoDB as a database. Enable this when demo'ing App Insights to show a more complete and real application. *Note.* this view only appears when configured, see configuration below

[https://github.com/benc-uk/nodejs-demoapp](https://github.com/benc-uk/nodejs-demoapp){: .btn .btn--primary .btn--large}

<img src="https://user-images.githubusercontent.com/14982936/43461431-674d705e-94cb-11e8-9633-00331d17c953.png" width="600">

---

# .NET Core
Based on the standard .NET Core 2.0 template (dotnet new), but further modified and jazzed up a little. The app was recently updated to use Razor Pages rather than MVC, which fits the simple demo app use case better.

Features added on top of the standard template:

- The 'About' page displays some system basic information (OS, platform, CPUs, IP address etc) and should detect if the app is running as a container or not.
- The 'Stress' page will generate CPU load, useful for testing autoscaling.
- The 'DepCall' page will let you make a server side HTTP call, useful to demonstrate dependency calls in Application Insights
- The App Insights SDK has been included, so if configured with an instrumentation key, monitoring data can be gathered and sent to Application Insights

[https://github.com/benc-uk/dotnet-demoapp](https://github.com/benc-uk/dotnet-demoapp){: .btn .btn--primary .btn--large}

<img src="https://user-images.githubusercontent.com/14982936/29657856-e82f4440-88b0-11e7-8575-dbbdf3edede5.png" width="600">

---

# Angular & Node
This is a demo application written in Angular 4 using Material Components. The backend API and server is written in Node.js, the persistent database is Azure table storage

The app is based on the 'Tour of Heroes' tutorial but has been modified and further developed. The default app shows a collection of old 8-bit and 16-bit computers which can be viewed, voted on (liked), and a set of standard CRUD operations performed. The code was designed to be as generic as possible so the base model and services operate on "things", making it easy to change the collection to something else should you wish

[https://github.com/benc-uk/angular-demoapp](https://github.com/benc-uk/angular-demoapp){: .btn .btn--primary .btn--large}

<img src="https://user-images.githubusercontent.com/14982936/29248453-69f0f34c-8010-11e7-85bc-00357a80cd80.png" width="600">

---

# Python Flask
Web application written in Python using the [Flask](http://flask.pocoo.org/) framework. The app provides system information and a realtime monitoring screen with dials showing CPU, memory, IO and process information.

[https://github.com/benc-uk/python-demoapp](https://github.com/benc-uk/python-demoapp){: .btn .btn--primary .btn--large}

<img src="https://user-images.githubusercontent.com/14982936/30533171-db17fccc-9c4f-11e7-8862-eb8c148fedea.png" width="600">

