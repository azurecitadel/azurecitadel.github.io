---
layout: article
title: Azure Storage Explorer
date: 2018-02-28
tags: [Azure, Storage Explorer]
comments: true
author: Matt_Biggs
image:
  feature: 
  teaser: 
  thumb: 
---

#Azure Storage Explorer

The Azure Storage Explorer is a local application that allows you to connect to and browse Azure storage accounts, including CosmosDB. I find it very useful for development to check if data is being written to the cloud correctly, and it allows the inspection and deletion of session / state data.

If you have landed on the page from a web search, or not followed the Citadel Lab instructions to the letter, the URL to download the Storage Explorer is:
[https://azure.microsoft.com/en-us/features/storage-explorer/](https://azure.microsoft.com/en-us/features/storage-explorer/)   

When you open the Storage Explorer you will be presented with the **Connect to Azure Storage** window, if you do not have this, click the **Manage Accounts** icon on the left bar, click **Add an Account…**

There are two main methods to connect:

1.	Add the Azure Account
2.	Add a specific Storage Account

If you use option 1, this will expose all storage resources associated with the account you sign in with, this may be okay if you have a small number of accounts, or a large number that are well named, but otherwise it can become a little overwhelming. Instead I prefer to use option 2, add the specific storage account that I want to see, I find this far more manageable, but it really is personal preference. 

1.	Add the Azure Account
Select the **Add an Azure Account** radio button and select the environment from the drop down.  
Click **Sign in…**  
Follow the usual sign in process 
2.	Add a specific Storage Account
There are two methods that are very similar, **Use a connection string**… or **Use a storage account name and key** – select the one that you want to use and click **Next**.
In the Azure portal navigate to the storage account that you want to connect to, if this is one that has been created as part of a deployment process, eg, a Bot Service, the easiest method is to go to the Resource Group for that deployment and select the **Storage account**.  
![](/labs/bot/images/resourcegroup.PNG)   
From the menu select **Access keys**.  
![](/labs/bot/images/StorageKeys.PNG)   
Depending on the connection method selected above, copy across either the Connection string (I use the Storage account name as the label, but that can be anything you want) or Key and storage account name. 
Click **Next**.  
Check your workings, click **Connect**.  

Regardless of the method used, 1 or 2, if you click the icon on the left bar to Toggle Explorer you will not see a tree view of the storage, which you can navigate through.

