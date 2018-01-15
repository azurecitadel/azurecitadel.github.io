---
layout: article
title: IoT Hub Lab
categories: labs
date: 2018-01-06
tags: [azure, iothub, iot, iotdevice, lab, portal, resource, group]
comments: true
author: Mahesh_Balija
image:
  feature: 
  teaser: Education.jpg
  thumb: 
excerpt: An intro to IoT Hub, create a IoT Hub and simulate a device in your machine and push messages to cloud (IoT Hub).
---
{% include toc.html %}

## Introduction

The main Azure portal is <a href="https://portal.azure.com" target="portal">https://portal.azure.com</a>.

Login using the account for your Azure subscription.

## Create/Setup IoT Hub instance

IoT Hub is the cloud gateway, which is the entrypoint for your devices or field gateways to 
send messages to the Cloud.

- Click on **+ create a resource** in the top left corner of the portal
- Select on **Internet of Things** in the newly opened blade
- Select **IoT Hub**
- Give a unique name for your IoT hub for e.g., **iothubpractice** (you can give the name of your choice)
- Select the pricing tier, you can choose the **F1 Free tier**
- Under IoT Hub Units enter 1 as units which determines the number of messages in your daily quota
- For Device to Cloud partitions select 4 partitions - your messages will be divided into the configured number
or partitions in the IoT Hub
- Select your subscription, in my case it is **Microsoft Azure Internal Subscription** (Note: You might have a different subscription)
- Resource Group - A resource group is a logical grouping of the resources which helps to easily manage the related resources. You can use any existing resource group or create a new one for e.g., **iot_hub_labs_rg** 
- Select the location as **WEST EUROPE** and click on create button - this may take few minutes to initialize your IoT Instance
    - **You can navigate to the IoT Hub instance once created:**
    - Notification bell is on the top right corner which shows the status of the IoT Hub setup, once completed;
    - Click on notification bell and click on **Go to resource** button
- Congrats! you have now setup your IoT Hub instance  

![](/labs/iothub/images/iothub-creation-page.png)

## Documentation

Internet of Things industry case-studies, customer success stories and useful documentation links:

Link | Description
<a href="https://docs.microsoft.com/en-us/azure/iot-hub/" target="azuredocs">IoT Hub</a> | Overview of IoT Hub 
<a href="https://azure.microsoft.com/en-gb/case-studies/?term=Internet+of+Things" target="microsoft_case-studies">IoT Case Studies</a> | Industry case-studies on Internet of Things
<a href="http://customers.microsoft.com/en-us/search?sq=Internet%20of%20Things&ff=&p=0&so=story_publish_date%20desc" target="microsoft_customer_stories">IoT Customer Stories</a> | Azure customer success stories in Internet of Things 
<a href="https://azure.microsoft.com/en-us/services" target="azuredocs">Products</a> | Main page for Azure Products
<a href="https://azure.microsoft.com/en-us/pricing" target="azuredocs">Pricing</a> | Pricing and TCO Calculators, plus pricing page for each product
<a href="https://docs.microsoft.com/en-us/azure" target="azuredocs">Documentation</a> | Azure documentation, quickstarts, SDKs and APIs etc.
<a href="https://docs.microsoft.com/en-us/azure/index#pivot=architecture" target="azuredocs">Architecture</a> | Patterns and Reference Architecture 
<a href="https://azure.microsoft.com/en-us/documentation/learning-paths" target="azuredocs">Learning Paths</a> | Guided (and finite) paths for learning a new area  

------------------------------------------------------------------

## Setup a device identity

-   Access the IoT Hub instance through the portal
    - Click on **All Resources** - this will list all the resources under your subscription
    - Select the IoT Hub instance created in previous step for e.g., **iothubpractice**
-   Scroll through the options in the newly opened blade and select **IoT Devices**
-   Click on **+ Add** button
-   Give a unique device id say **iot-practice-dev**
-   Select authentication type as **Symmettric Key**
-   Check the Auto Generate Keys
-   Check the Enable under **Connect device to IoT Hub**
-   Click on save

## (Next Steps - Optional) Simulate a device on your machine and send messages to your IoT Hub instance

- Refer to below link for simulating a device and sending messages to IoT Hub in your preferred lanugage,
[Simulate Device and Send messages to IoT Hub](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-get-started-simulated)