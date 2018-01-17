---
layout: article
title: Shakespeare! Data Lake Analytics and Cognitive Services.
categories: videos
date: 2018-01-10
tags: [azure, cognitive services, ai, data, data lake,data lake analytcs, lab, portal, resource, group]
comments: true
author: Phil_Harvey
image:
  teaser: cloud-lab.png
excerpt: A walk through video of how to use the Text Analytics Cognitive Service in Data Lake Analytics using Shakespeare as an example.
---
![Header Image](/videos/datalakeanalytics-cogser/images/Header.png "Header Image")

{% include toc.html %}

## Introduction
Watch Phil Harvey and Azure Dan work through analysing the Plays of Shakespeare using the <a href="https://azure.microsoft.com/en-gb/services/cognitive-services/" target="_blank">Cognitive Services</a> <a href="https://azure.microsoft.com/en-gb/services/cognitive-services/text-analytics/" target="_blank">Text Analytics</a> integration with Azure <a href="https://azure.microsoft.com/en-gb/services/data-lake-analytics/" target="_blank">Data Lake Analytics</a>.

In this video you will learn how:
 - to plan out your solution
 - we processed the plays of Shakespeare as data
 - decided on your method of data ingest
 - to provision Data Lake Store in the Azure Portal
 - to provision Data Lake Analytics in the Azure Portal
 - to install the Cognitive Services into Data Lake Analytics
 - to run text sentiment against your data
 - to link PowerBI to Data Lake Store
 - to visualise sentiment data 
 - ... maybe a bit about Shakespeare?

## The Video
----------

<iframe width="560" height="315" src="https://www.youtube.com/embed/bfn9KrfHvQI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

----------

Follow Phil Harvey on Twitter: @codebeard

Follow Azure Dan on Twitter: @azuredan

## Resources

In the video there are few resources called out.

### The Complete Works of Shakespeare

This can be found on the <a href="https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/t8.shakespeare.txt" target="_blank">MIT Open Courseware</a> site.

Please read the licence carefully when using this data.

### Data Ingest Options Flow Chart (Whitepaper)

The original white paper mentioned in the video is here (V2) [Azure Data Platform Ingest Options V2.pdf](./AzureDataPlatformIngestOptionsV2.pdf) to download and read. The main flowchart will take you through the choices you will need to make. This document contains a large number of considerations about where the data will go after ingest that might be useful.

As the world of cloud is ever changing to bring great new features to everyone the original paper will likely need updating on an ongoing basis. For example [Data Ingest Flowchart V3 Draft.pdf](./DataIngestFlowchartV3Draft.pdf) is the current iteration of the flow chart. 

Because of this I will be converting the document to a Citadel page so it is easier to keep up to date.

### Regular Expression Documentation

In the video we mention the Regular Expressions documentation available on docs.microsoft.com and they're are <a href="https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expressions" target="_blank">a great starting point</a> to learn and refer back to. Regular expressions, like any skill, need to be practiced to develop comfort and ability. Extracting the plays of Shakespeare would make good practice indeed!

### F\# Scripts

There are 2 script files in [scripts.zip](./scripts.zip) that are presented for learning purposes. They are presented without warranty or guarantee. As commented on in the video they are not examples of good code. They do work on my machine though.

* getPlay.fsx is used to extract one play from the complete works file
* process2.fsx is used to turn the extracted play into the data files provided below

Once processed each line of the output files should conform to the schema given in the next sections and to this regular expression: `([^\|]+?\|){8}[\w\s,&]+?\|[^\|]+$`. If they don't conform to this regular expression the U-SQL script will throw and error.

### Plays 

As discussed we are uploading 5 processed plays here for you to use with the U-SQL Script below.
These are:

[Hamlet](./hamlet_processed4.txt)

[Comedy of Errors](./comedyoferrors_processed4.txt)

[Macbeth](./macbeth_processed4.txt)

[Romeo and Juliet](./romeo_processed4.txt)

[Midsummer Nights Dream](./midsummer_processed4.txt)

The schema of these files is
`play line number|play progress %|act line number|act progress %|scene line number|scene progress %|act|scene|character|line`

### U-SQL Script

The script used in the video is [Analysis3.usql](./Analysis3.usql) and can be used with the files in the section above.

[This](https://docs.microsoft.com/en-us/azure/data-lake-analytics/data-lake-analytics-u-sql-cognitive) is a great place to start understanding the cognitive capabilities of Data Lake Analytics.

### Power BI
Please sign up for [PowerBI](https://powerbi.microsoft.com/en-us/) to be able to use this service and/or download the desktop application.

To load data from Azure Data Lake store [this](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-power-bi) guide will help you get started.


### The Results
Here are some examples of the results in Power BI.
Do they fit what you remember of the plays?

[![Macbeth](/videos/datalakeanalytics-cogser/images/Macbeth.png "Macbeth Results")](/videos/datalakeanalytics-cogser/images/Macbeth.png)

[![Romeo And Juliet](/videos/datalakeanalytics-cogser/images/RomeoAndJuliet.png "Romeo and Juliet Results")](/videos/datalakeanalytics-cogser/images/RomeoAndJuliet.png)

Using various charts you can explore the interactions of certain characters.
For example Helena and Hermia in 'A Midsummer Nights Dream' and their love confusion.

[![Helena And Hermia](/videos/datalakeanalytics-cogser/images/HelenaAndHermia.png "Helena And Hermia Results")](/videos/datalakeanalytics-cogser/images/HelenaAndHermia.png)
