---
layout: article
title: Azure 101 Logic App Lab
categories: labs
date: 2017-10-05
tags: [azure, 101, paas, logic, app, twitter]
comments: true
author: Richard_Cheney
image:
  feature: 
  teaser: Education.jpg
  thumb:
excerpt: Create a Logic App with an http endpoint ready to receive a JSON payload containing feedback information.  Extend with conditional emails and loggint to Cosmos DB. 
---

{% include toc.html %}

## Introduction

Logic Apps are quick plug and play "if .. then ..." constructs to help developers and power users to quickly integrate systems.  They complement some of the other PaaS type offerings such as serverless Functions, Event Grid and other event based services.

In this logic app lab we will create an HTTP endpoint that will be used to receive user feedback.  This REST API could then be used by our fictional websites, mobile apps and custom applications.    

We will build up the Logic App in steps:
1. Create the basic REST API using a JSON schema, and test that it responds
2. Add on a conditional branch that emails us if the feedback rating is poor
3. Insert a logging mechanism to retain all of the feedback in the document database API for Cosmos DB

We will trigger the tests using the Postman application which is a standard way to test REST API interfaces.  The REST standard supports create, read, update and post (CRUD) actions, but we will only be using the POST action.

## Deploy Cosmos DB

We won't be using the Cosmos DB until the end of the lab, but we'll deploy it first as it will take a little while to be created.  You can either create the Cosmos DB via the portal, or deploy it via the CLI as infrastructure as code

#### Portal

* Click **Add** in the Azure101PaaS resource group
* Add Azure Cosmos DB
  * ID: **\<yourname>cosmosdb**
  * API: **SQL** (this is essentially DocumentDB, or NoSQL)
  * Resource Group: **Azure101PaaS**
  * Location: **West Europe**

#### CLI 2.0

You can use the CLI to deploy a template to build the Cosmos DB.  Don't forget to **change the name=\<yourname>cosmosdb parameter** before submitting.

```bash
template='http://azurecitadel.github.io/labs/logicapps/azuredeploy.json'
az group deployment create --parameters name=<yourname>cosmosdb --resource-group Azure101PaaS --template-uri $template --name job1  --no-wait  
```

Now open up the Azure portal in a new tab and continue with the following steps.   

## JSON payload

* Open the <a href="/labs/logicapps/feedback.json" target="payload">example JSON payload</a>.  This is the format that the various applications will use for feedback into our system.  
  * The ID is the number of UTC milliseconds
  * The rating is an integer score of 1 to 5 inclusive, i.e. based on the number of stars the fictitious user has rated it on
* Open the <a href="/labs/logicapps/schema.json" target="schema">JSON schema</a>.  The schema describes the expected format.  This has been created using the example payload via the excellent https://jsonschema.net website and then modified to customise the variable titles, descriptions, etc.
* Select the schema contents and copy them to the clipboard as we will use this later when defining the Logic App.

## Create the Logic App

Create an empty Logic App in the Azure101PaaS resource group:

<video video width="800" height="600" autoplay controls muted>
  <source type="video/mp4" src="/labs/logicapps/images/createLogicApp.mp4"></source>
  <p>Your browser does not support the video element.</p>
</video>

* Click on **New** or **Add** 
* Find _Logic App_ and click on **Create**
  * Name: **feedbackLogicApp**
  * Resource Group: **Azure101PaaS**
  * Location: **West Europe**
* Click into the new Logic App once deployed
* Select **Blank Logic App** in the Logic Apps Designer screen

## Define the REST API endpoint

We'll create a REST API point, and define the expected schema for the JSON.  Once a valid request has been received then we'll send back an HTTP response.

<video video width="800" height="600" autoplay controls muted>
  <source type="video/mp4" src="/labs/logicapps/images/workflow-1-httpEndpoint.mp4"></source>
  <p>Your browser does not support the video element.</p>
</video>

### Request

* Search for **http request** and select the trigger
* Paste in the JSON schema

Note that the JSON describes the keys in order to give them titles such as _feedbackEmail_. We will then be able to use as dynamic content later in the lab, much like a variable. 

### Response

* Select the corresponding **response**
* Use the default HTTP status code of 200
* Add a header, with **ID** as the key
* Click in the value field for the ID key and then select **_feedbackId_** from the selection of dynamic content
* Body: Set to **Feedback received from _feedbackEmail_**, again making use of the dynamic content 

![](/labs/logicapps/images/logicAppRequestResponse.png)

### Test the endpoint

<video video width="800" height="600" autoplay controls muted>
  <source type="video/mp4" src="/labs/logicapps/images/testHttpEndpoint.mp4"></source>
  <p>Your browser does not support the video element.</p>
</video>

* Click on the Logic App name at the top of the portal
* You will now be in the Logic App's Overview screen 
* Click on the copy icon on the right of the **Callback url [POST]** in the Trigger History pane.  This is the HTTP REST API endpoint.
* Open up the Postman app, skipping login
  * Change the action from **GET** to **POST** in the drop list 
  * Paste the HTTP REST API into the _Enter request URL_ field
  * On the Authorization tab, leave type as _No Auth_
  * On the Headers tab, add one key-value pair:
    * Key: **Content-Type**
    * Value: **application/json**

![](/labs/logicapps/images/postmanHeaders.png)  

  * On the Body tab, toggle the body type to raw
  * Open the <a href="/labs/logicapps/feedback.json" target="payload">example JSON payload</a> we saw earlier, and copy the contents to the clipboard 
  * Paste the JSON payload into Postman
  * Click on the blue **Send** button
  * The HTTP response from the Logic App should show in the bottom pane:

![](/labs/logicapps/images/postmanBody.png)

  * The headers of the response also include the id number  

### Checking the Logic App run

* Go to the Overview area of the Logic App
* Check that there is a new entry in the Trigger History
* Click on the new **Runs History** entry to view the details
  * Open up the individual steps to view the inputs and outputs

![](/labs/logicapps/images/logicAppRun.png)

## Send an email if feedback rating is poor

We will now add a conditional action that will only email us if the feedback rating is less than three.

### Create the conditional action

* Click on **+New Step** and then **Add a condition**
  * Value:  **_feedbackRating_**
  * Operator: **is less than**
  * Value: **3**
* In the "If true" branch, add an action
* Search for "_email_" and choose a platform.  The steps below are for Office 365 Outlook.
  * Click on the **Send an Email** action
  * Sign in to create the connection
  * To: **yourEmailAddress**
  * Subject: **Feedback from _feedbackName_**
  * Body: Add in all of the useful information from the JSON payload to create the body of the email.  The screenshot below gives an example.

![](/labs/logicapps/images/logicAppEmail.png)

* Click on **Save**

### Retest the Logic App

* Go back into the Postman app, skipping login
* Modify some of the values for the raw JSON (optional)
* Ensure that the value for the rating is either 1 or 2
* Click on **Send**
* Now go to the Overview area of the Logic App
* Check the details of the new **Runs History** entry
* Check your inbox and verify that the feedback email has been received

![](/labs/logicapps/images/logicAppEmailTest.png)

## Adding a permanent record into Cosmos DB

We will now insert a step to retain the submitted feedback JSON documents, and store them.  Cosmos DB is a globally distributed multi-model database, and the model type selected earlier in the lab was SQL (Document DB), which is perfect for storing JSON documents.

We'll now add a collection called production into our feedback database, and we'll partition it based on the source.  Then we'll add the step into the Logic App to add the document to the database.   

### Define the collection

* Go into the Cosmos DB resource
* Click on **Add Collection** in the Overview
  * Database id: **main**
  * Collection Id: **feedback**
  * Storage Capacity: **Fixed (10GB)**
  * Initial Throughput Capacity (RU/s): **400**

![Cosmos DB Connection](/labs/logicapps/images/workflow-3-cosmosDbCollection.png)

* In the Cosmos DB Overview area, copy the URI
  * The URI is in the form **https://_\<ID>_.documents.azure.com:443/**

### Add the Create Document step and connect to Cosmos DB

* Open up a new tab and go back into your Logic App
* Click on **Edit** to re-open the Logic App Designer
* Add a new action between Response and the Condition
  * Hover the mouse over the arrow under Response and a **+** sign will appear
  * Click on it and then select 'Add an action'
* Search on 'Cosmos DB' and select _Create or update document_
* Paste in the connection string `https://<yourname>cosmosdb.documents.azure.com:443/`
* Select the Cosmos DB and click on Create

![Cosmos DB Connection](/labs/logicapps/images/workflow-3-cosmosDbConnection.png)

### Define the document format and placement

Set the parameters for the _Create or update document_ action:

* **Database ID**: Select _main_ from the drop down
* **Collection ID**: Select _feedback_ from the drop down
* **Document**: Enter the following, replacing `feedbackVarname` with the relevant dynamic content:

```
{
  "email": "feedbackEmail",
  "feedback": "feedbackText",
  "id": "feedbackId",
  "name": "feedbackName",
  "source": "feedbackSource",
  "rating": "feedbackRating"
}
```
  
* Set **IsUpsert** to _Yes_, which allows both updates and inserts
* Do not set up a partition ley.  These are only used for the unlimited size Cosmos DBs where the partition key is import for sharding.

Below is an example of the _Create or update document_ logic

![Cosmos DB Connection](/labs/logicapps/images/workflow-3-cosmosDbDocument.png)

* Save

### Test the whole Logic App workflow

* Retest a feedback submission by going into Postman, changing the body of the JSON (choose a new name, email address and feedback message) and then clicking **Send**
* Check the Run History and view the outputs
* Go into Cosmos DB and use the Data Explorer to verify that the feedback is beeing collected successfully

![](/labs/logicapps/images/cosmosDbDocumentTest.png)  

## Final notes

* Note that the logic app also allows drag and drop reordering of steps
  * Prove this by moving the Cosmos DB document step above the HTTP Response
* It is also possible to cosmetically rename the steps
* If you have time then explore the other inbuilt connectors offered by Logic Apps
  * Note that Functions can also be integrated into Logic Apps for full flexibility