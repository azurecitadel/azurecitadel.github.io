---
title: Anomaly Detection with Azure Databricks
category: data-ai
date: 2018-12-30
tags: [anomaly-detection, databricks, ml, ai]
author: Mahesh Balija
header:
  teaser: images/teaser/education.png
excerpt: A step-by-step guide to detect Anomalies in the large-scale data with Azure Databricks MLLib module. In this tutorial we will learn various Noval Techniques used for detecting Anomalies and will leverage on Random Forests to build a classification model to predict anomalies within the dataset.   
---
# Design
![](images/batch_predictions_workflow.jpg)

# Build Anomaly detection model to detect Network Intrusions (i.e., Bad network connections or attacks) using KDDCup Synthetic Network Logs Dataset 

Anomaly Detection is the ability to detect abnormal behavior in the given data like un-expected logs, events etc (or) in simple terms finding the odd-one-out from the given dataset. 

Anomaly Detection have various applications like,

* Network Intrusion Detection
* Fraud Detection
* Patient Monitoring
* Application Monitoring etc

If implemented correctly Anomaly Detection can help users to take pro-active actions to avoid any catastropic losses in various domains. There are various techniques proposed to implement an Anomaly Detection as below,

* Supervised Anomaly Detection with Decision Trees, SVMs - Support Vector Machines, DNNs - Deep Neural Networks etc
* Semi-Supervised Anomaly Detection with One-class classification models like one-class SVMs
* Unsupervised Anomaly Detection with Clustering techniques like K-NN - K-Nearest Neighbours etc

This is the step-by-step guide to detect Anomalies in the large-scale data with Azure Databricks MLLib module.  
In this tutorial we will use the Supervised Anomaly Detection technique using Decision Trees (in our case Random Forests in Spark MLLib) for detecting Anomalies within the KDD Cup Network Log Synthetic data and will detect the network intrusions.

## Azure-Databricks Labs for building ML Models  
  
This tutorial mainly focuses on how to use Azure Databricks for Machine Learning workloads, saving and loading the Spark MLLib Model pipelines to Azure Storage. This tutorial in no means claim that this is the best approach for Anomaly detection, rather focuses on the approach to create, persist and load the Model pipelines in Azure Databricks.

## Create an Azure Blob Storage account and upload the Network logs - Synthetic data

1. **Login to Azure portal:**   
The main Azure portal is <a href="https://portal.azure.com" target="portal">https://portal.azure.com</a>.  
2. Click **+ Create a Resource** button
3. Select **Storage** and click **Storage account - blob, file, table, queue**
4. Select a valid subscription, resource group, account name, nearest location, select standard
5. For **Account Kind** select **Blob Storage**
6. Leave **Replication** as **RA-GRS** and **Access Tier** as **Hot**
7. Hit **Review + Create** and **Create**
8. Once the deployment is successful, goto the storage account through the notification bell and clicking **Go to resource** button
9. Under **Settings** select **Access Keys** and make a note of **Key1** (or) **Key2**
10. Download the file **kddcup.data_10_percent.gz** from below link  
<a href="http://kdd.ics.uci.edu/databases/kddcup99/kddcup99.html" target="portal">http://kdd.ics.uci.edu/databases/kddcup99/kddcup99.html</a> | KDD Cup Datasets
 
NOTE: Only use the 10 percent dataset from this link for the scope of this labs. You can use the whole dataset for your learning in your personal time :)
11. Extract the gzip file, you will get **kddcup.data_10_percent_corrected**
12. Open **Microsoft Azure Storage Explorer** from your desktop and connect to your Azure subscription  
NOTE: Follow the instructions in the **dlsgen2** labs to download and install the storage explorer in your desktop, if it is not availble in your desktop or VM
13. Under the **Storage accounts**, open the newly created blob storage account
14. Expand **Blob Containers**, right click and select **create blob container** and give a valid name, in my case I gave **root** as the container name 
15. Click on **+ New Folder** and give a folder name as say **network-logs**
16. Upload the file **kddcup.data_10_percent_corrected** from where you have extracted into the newly created folder **network-logs** in the blob container **root**
17. Wait until the file is uploaded successfully!
 
## Import the Anomaly Detection notebook .dbc file into your workspace, execute the ML Model and review the output

1. Login to Azure portal
2. Launch the Azure databricks workspace
3. Click on **Workspace** icon from the left navigation pane 
4. Click on the **down arrow icon** next to workspace
5. Hit **Import**
6. Upload the **anomaly_detection_v1.dbc** file from below GitHub repository into this workspace   
<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-04-ml-01-anomalydetection" target="portal">Databricks Labs GitHub Repo</a>
  
7. Click on **Home** icon from the left navigation pane
8. Goto to the **intrusion_detection_v1** notebook under the **Recents** section
9. In the **Cmd 1** replace all of the following,
    * Replace **<Azure Storage KEY - You can copy this from your Azure Portal>** with your Blob Storage Key which you have copied from above instructions
    * Replace **<STORAGE_ACCOUNT_NAME>** with your Storage Account name, this can be found from the overview page of the Storage resource in Azure portal
    * Replace **<BLOB_CONTAINER>** with the newly created contianer name above (in my case **root**)
    * Replace **<STORAGE_ACCOUNT_NAME>** with your Storage Account name, this can be found from the overview page of the Storage resource in Azure portal
    * Repace **<YOUR_FOLDER>** with the folder name created above (in my case **network-logs**)
10. Review each command and run one by one and monitor the results of each command

*Congrats! you are now been able to learn how easy-it-is to create an ML model using Azure Databricks Notebooks :)*

## Implement Batch Predictions: Save and Load the ML Model Pipeline from Azure Storage

*The detailed steps are listed in the GitHub Repository created by Mahesh Balija please refer to below link :)*
<a href="https://github.com/mabalija/azure-databricks-labs/tree/master/db-labs-04-ml-02-batchpredict" target="portal">Azure Databricks - Batch Predictions Lab</a>  

## Documentation

Azure Databricks Documentation

Link | Description
<a href="https://docs.microsoft.com/en-us/azure/azure-databricks/" target="azuredocs">Azure Databricks - Microsoft</a> | Azure Databricks Microsoft Documentation 
<a href="https://docs.azuredatabricks.net/" target="Databricks">Databricks Official Documentation</a> | Azure Databricks official documentation from Databricks
<a href="https://github.com/mabalija/azure-databricks-labs" target="Databricks Labs GitHub Repo, Mahesh Balija">Azure Databricks Sample Labs</a> | Sample Labs in GitHub repository from Mahesh Balija  
------------------------------------------------------------------