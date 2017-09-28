---
layout: article
title: Serverless IoT demo in Azure with IoT Hubs, Service Bus & Functions
date: 2017-07-04
categories: demos
author: Ben_Coleman
image:
  feature: 
  teaser: project.png
  thumb: 
comments: true
---
This is a demo of IoT capabilities in Azure using IoT Hubs, Service Bus and Azure Function Apps.
Messages received at the IoT hub are placed on a Service Bus queue, from the queue they are picked up by the Azure Function and placed into blob storage as CSV files and into a table. Node.js based IoT device simulator is included.

![overview](./images/iot-demo.png)

## [![link](/images/icons/link.svg) Link to demo guide and repo](https://github.com/benc-uk/azure-iot-demo) 