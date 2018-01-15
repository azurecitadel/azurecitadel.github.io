---
layout: article
title: IoT Central Lab
categories: labs
date: 2018-01-07
tags: [azure, IoT, IoT Central, IoT Hub, IoT Edge, EventHub, lab]
comments: true
author: Mahesh_Balija
image:
  feature: 
  teaser: Education.jpg
  thumb: 
excerpt: Introduction to IoT Central, create and monitor a sample IoT Central application.
---
{% include toc.html %}

## Pre-Requisites

- An active Azure subscription
- Access to Azure Portal
- Azure Active Directory - An azure active directory contains user identities, credentials and other organizational information.    

## Introduction

Access the IoT Central SaaS portal <a href="https://www.microsoft.com/en-us/iot-central/" target="IoT Central">https://www.microsoft.com/en-us/iot-central/</a>.

Login using the account for your Azure subscription.

## Create Azure IoT Central Application

IoT Central is a Azure SaaS based IoT offering which enables the organizations to create and start the IoT applications in minutes. With zero coding efforts users of IoT Central only need to define the rules in self-managed drag and drop UI. 

- Click on **Start Now** button on the portal - This will take you to IoT Central Create page
- Give the application name for e.g., **IoTCentralSaaSPractice** in the newly opened page
- You can leave the URL same as the name of the application **IoTCentralSaaSPractice**
- Under Directory - Select your existing Azure Active Directory (AAD) tenant, if you do not see any Azure Active Directory in the drop down list you must create a new AAD Tenant under your subscription.
- Resource Group - A resource group is a logical grouping of the resources which helps to easily manage the related resources. You can use any existing resource group or create a new one for e.g., **iot-central-labs-rg** 
- Select the region as **WEST EUROPE**
- Under **Application Templates** you will find three options 
    - **Custom Application** - Use this for creating an IoT Central application from scratch in which you need to configure the devices and apply rules, define actions on your input datasets
    - **Sample Contoso** - This is a hosted application and is good for doing labs (**Select this option, for this lab**)
    - **Sample Devkits** - If you have a device in hand you can use this to configure your device and streaming the data
- Select Free 30 day trail application (Make sure that you clear all the resources from your Azure subscription once you have completed the labs)
- Congratulations! now you have setup your first IoT Central application

## Documentation

IoT Central overview and azure documentation: 

Link | Description
<a href="https://docs.microsoft.com/en-gb/microsoft-iot-central/" target="azuredocs">IoT Central</a> | Overview of IoT Central
<a href="https://azure.microsoft.com/en-us/services" target="azuredocs">Products</a> | Main page for Azure Products
<a href="https://azure.microsoft.com/en-us/pricing" target="azuredocs">Pricing</a> | Pricing and TCO Calculators, plus pricing page for each product
<a href="https://docs.microsoft.com/en-us/azure" target="azuredocs">Documentation</a> | Azure documentation, quickstarts, SDKs and APIs etc.
<a href="https://azure.microsoft.com/en-us/documentation/learning-paths" target="azuredocs">Learning Paths</a> | Guided (and finite) paths for learning a new area  

------------------------------------------------------------------

## Monitor and define rules on the device telemetry

- Click on **View all your devices** - This will display all the simulated devices for this application
- Click on any of the devices (for e.g., Refrigirator 1) - This will display the telemetry captured for this device for e.g., humidity, temperature, pressure etc.
- Select the **Settings** tab - you can view and update the configruations on the device for e.g., Fan Speed initial setting to 0, you can change the value to say 5 and click on Update button. - This will synchronize the configurations on the device.
- Select the **properties** tab, you will find the below information
    - Manufacturing date
    - Customer Info
    - Operational parameters
- Select **Rules** tab,
    - Click on **edit** symbol
    - Click on **New Rule** 
    - Under **select Rule** click on Telemetry - this is used to configure rules on the measurements read from your devices
    - Specify the rule name as **High Pressure Alert** 
    - Under **Enable Rule for All devices of this template** select **on**
    - Under **Conditions** 
        - In the **Telemetry measurement or property** dropdown list select **pressure**
        - Under **Select an Operator** select **is greater than**
        - Under **Enter a value** select say 30
    - Click on add **Actions** 
        - You can select appropriate action for e.g., send an email, sms, webhook, external systems integration like SAP, Logic Apps, Azure functions
        - Select **email** action
        - In To box: give your email ID
        - Under notes you can add the alert message "Presssure have reached the configured threshold"
        - Click on **Save**
- Select the **Dashboard** tab - this will display the embedded Power BI pre-configured dashboard with most of the commonly used metrics, graphs etc.

## (Next Steps) - TBD