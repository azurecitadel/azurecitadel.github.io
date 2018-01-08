---
layout: article
title: Streaming Analytics Lab
categories: labs
date: 2018-01-07
tags: [azure, Streaming, Analytics, CEP, ComplexEventProcessing, StreamingAnalytics, IoT, IoTHub, EventHub, lab]
comments: true
author: Mahesh_Balija
image:
  feature: 
  teaser: Education.jpg
  thumb: 
excerpt: Introduction to Streaming Analytics, create a Streaming Analytics Job and perform simple aggregations on the events from files or IoT Hub or Event Hubs.
---
{% include toc.html %}

## Introduction

The main Azure portal is <a href="https://portal.azure.com" target="portal">https://portal.azure.com</a>.

Login using the account for your Azure subscription.

## Create Azure Streaming Analytics Job

Streaming Analytics is a managed event stream processing engine which can be used to perform realtime analytics on the streaming data.

- Click on **+ create a resource** in the top left corner of the portal
- Select on **Internet of Things** in the newly opened blade
- Select **Stream Analytics Job**
- Give a unique name for your Streaming analytics job for e.g., **streaming-event-agg-test-job** (you can give the name of your choice)
- Select your subscription, in my case it is **Microsoft Azure Internal Subscription** (Note: You might have a different subscription)
- Resource Group - A resource group is a logical grouping of the resources which helps to easily manage the related resources. You can use any existing resource group or create a new one for e.g., **stream_analytics_labs_rg** 
- Select the location as **WEST EUROPE**
- Select appropriate hosting environment either Cloud or Edge. For this labs choose **Cloud** as hosting environment as we will be running this streaming job on the cloud. Note: If you want to deploy the streaming job on an IoT edge device then you can select Edge 
- Click **create**, this will start initializing your streaming analytics job
    - **You can navigate to the streaming analytics job once created:**
    - Notification bell is on the top right corner which shows the status of the Streaming analytics job setup, once completed;
    - Click on notification bell and click on **Go to resource** button
- Congrats! you have now setup your Streaming Analytics job  

![](/labs/streaming-analytics/images/streaming-analytics-job-creation-page.png)

## Documentation

Streaming Analytics Job general overview, use-cases, integration, Storm with IoT or Event Hubs: 

Link | Description
<a href="https://azure.microsoft.com/en-us/services/stream-analytics/" target="azuredocs">Streaming Analytics</a> | Overview of Streaming Analytics 
<a href="https://docs.microsoft.com/en-us/azure/stream-analytics/" target="azuredocs">Streaming Analytics Reference</a> | Streaming analytics reference documentation
<a href="https://docs.azuredatabricks.net/" target="azuredocs">Azure DataBricks Spark</a> | DataBricks Spark Streaming for streaming analytics
<a href="https://docs.microsoft.com/en-us/azure/hdinsight/storm/apache-storm-overview" target="microsoft_customer_stories">HDInsight Apache Storm</a> | Overview of HDInsight Apache Storm cluster for Complex Event Processing CEP engine 
<a href="https://azure.microsoft.com/en-us/services" target="azuredocs">Products</a> | Main page for Azure Products
<a href="https://azure.microsoft.com/en-us/pricing" target="azuredocs">Pricing</a> | Pricing and TCO Calculators, plus pricing page for each product
<a href="https://docs.microsoft.com/en-us/azure" target="azuredocs">Documentation</a> | Azure documentation, quickstarts, SDKs and APIs etc.
<a href="https://azure.microsoft.com/en-us/documentation/learning-paths" target="azuredocs">Learning Paths</a> | Guided (and finite) paths for learning a new area  

------------------------------------------------------------------

## Create an Azure Stream Analytics query

-   Access the Streaming Analytics Job through the portal
    - Click on **All Resources** - this will list all the resources under your subscription
    - Select the Streaming Analytics Job created in previous step for e.g., **streaming-event-agg-test-job**
-   Under the **Job Topology** section select **Query**
-   Download the sample sensor data file in JSON format [here](/labs/streaming-analytics/SampleSensorData.json)
-   Under the Inputs, next to **yourinputalias** select the three dots ... and click **upload sample data from file** 
-   Upload the sensor data file 
-   Click on the gear button on the top area - this will display the contents of the file uploaded 
-   You can filter, aggregate, join the dimensional data etc for e.g., change the Query as below

```
SELECT
    System.timestamp as OutputTime,
    dspl as sensorname,
    avg(TEMP) as avgtemperature
INTO
    [YourOutputAlias]
FROM
    [YourInputAlias]
GROUP BY TumblingWindow(SECOND, 30), dspl
HAVING AVG(TEMP) > 70;
```
-   Click on save

## (Optional) Configure IoT Hub, Event Hubs as the inputs for Streaming Analytics Job

-   Pre-Requisites: (TBD)