---
title: Azure Databricks Level-400 Workshop
category: data-ai
date: 2019-01-04
tags: [azure-databricks, etl, ml, streaming]
author: Mahesh Balija
header:
  overlay_image: images/header/az-db-logo.jpg
  teaser: images/teaser/education.png
excerpt: Azure Databricks Level-400 Workshop, this landing page defines the structure, content, targeted audience for the Azure Databricks workshop.   
---
# Azure Databricks Level-400 Workshop - Agenda

## Targeted Audience and Scenarios

Azure-Databricks Level-400 Workshop is aimed to upskill various audiences 

* Data Engineers
* Data Scientists
* SQL Developers
* Developers
* Solution Architects
* Data Architects

This workshop content is useful in various scenarios,

* POCs / AI Hacks - Developers can understand connecting to Blob Storage, Submitting the jobs, persisting/loading ML models etc. This can be very useful material to expedite the development at early POC stages
* Self-learning through code samples
* Best-Practices for Databricks Clusters (Interactive, Job, High-Concurrency) 
* Best practices for ADLA to Databricks Migration

## Spark, Azure-Databricks overview

A brief introduction to Spark framework and the history of Big Data technologies. Why Spark framework have been widely adopted across the industries. An Overview on of Spark Modules including Spark Core (Map-Reduce), Datastructures, Streaming, SQL, GraphX. 
Databricks introduction and the Key differentiors of Databricks Spark in terms of Performance, Collabarative and Interactive features.
Azure-Databricks benefits, deep integration of Azure-Databricks into Azure Data platform, Security, BI services.

## Azure-Databricks Architecture

A detailed discussion around the Spark architecture followed by Azure Databricks Components.

## Databricks Workspace, Developer Tools overview

An overview of Azure Databricks collaborative workspace and its components. Azure Databricks Developer tools discussion,

* Databricks CLI
* Filesystem utilities
* Notebook workflow utilities
* Widget, Secret, Library utilities

Azure Databricks CLI Lab

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-00-devtools-01-dbcli" target="azuredocs">Azure Databricks - Developer Tools</a>

Azure Databricks Lab for DBUtils such as Widgets, Notebooks, Library etc

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-00-devtools-02-dbutils" target="azuredocs">Azure Databricks - DB Utils</a>

Reading data from Azure Blob Storage in the databricks jobs  

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-01-azdataintegration-01-blobstore" target="azuredocs">Azure Databricks - Azure Blob Storage</a>

Reading data from Azure Data Lake Storage Gen2 in the databricks jobs

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-01-azdataintegration-02-dlsgen2" target="azuredocs">Azure Databricks - Azure Data Lake Storage Gen2</a>

Read data from Azure Cosmos DB in the databricks jobs

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-01-azdataintegration-03-cosmosdb" target="azuredocs">Azure Databricks - Cosmos DB</a>

## Databricks Cluster Types and Best Practices

Azure-Databricks have various cluster types like Interactive Clusters, Job Clusters and High-Concurrency Clusters (formarly known as Serverless-pools). This section talks about selecting right cluster type depeding upon the scenario.

Submit databricks jobs using CLI and UI

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-02-jobsubmit-01-cli-ui" target="azuredocs">Azure Databricks - Job Submission Lab 1</a>

Create and submit Workflow Pipeline in Azure Data Factory V2 to Azure Databricks

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-02-jobsubmit-02-adfv2" target="azuredocs">Azure Databricks - Azure Datafactory V2 Job Pipline submission</a>

## Databricks Performance

In this section we will learn discuss about the performance improvements made by Azure Databricks.

## Spark-SQL Overview

In this section we will discuss about ways to work with Structured data within Azure Databricks. We will learn the nuances of Managed, Un-managed tables and how to integrate external metastores like Hive.

Create a managed table and work with Spark SQL

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-03-sql-01-localtables" target="azuredocs">Azure Databricks - Managed Tables</a>

## Machine Learning with Azure Databricks

An overview of Spark MLLib package and introduction to Statistical modeling also understand how to run Deep Learning models using Tensorflow on Azure Databricks.

Spark MLLib for Anomaly detection using Random Forests classification technique

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-04-ml-01-anomalydetection" target="azuredocs">Azure Databricks - Anomaly Detection</a>

Implement batch predictions within Azure Databricks. You will also understand how to persist and load the model from Blob Storage within your Spark Jobs

<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-04-ml-02-batchpredict" target="azuredocs">Azure Databricks - Batch Predictions</a>

## Documentation

Azure Databricks Documentation

| Link    | Description    | 
| ------------- |:-------------:|  
| <a href="https://docs.microsoft.com/en-us/azure/azure-databricks/" target="azuredocs">Azure Databricks - Microsoft</a>   | Azure Databricks Microsoft Documentation   |  
| <a href="https://docs.azuredatabricks.net/" target="Databricks">Databricks Official Documentation</a>   | Azure Databricks official documentation from Databricks   |    
| <a href="https://github.com/mabalija/azure-databricks-labs" target="Databricks Labs GitHub Repo, Mahesh Balija">Azure Databricks Sample Labs</a>    | Sample Labs in GitHub repository from Mahesh Balija    | 
  
-----------------------------------------------------------------