---
layout: article
title: IoT Hub File Upload
categories: labs
date: 2018-03-21
tags: [azure, iothub, iot, iotdevice, lab, portal, resource, group, IoT File Upload]
comments: true
author: Mahesh_Balija
image:
  feature: 
  teaser: Education.jpg
  thumb: 
excerpt: Upload file from devices to an existing IoT Hub and persist to Azure Storage.
---
{% include toc.html %}

## Introduction

The main Azure portal is <a href="https://portal.azure.com" target="portal">https://portal.azure.com</a>.

Login using the account for your Azure subscription.

## Pre-Requisites
You should have the IoT Hub instance, if not please follow instructions in below link;
<a href="https://azurecitadel.github.io/labs/iothub/" target="IoT Hub Lab">IoT Hub Lab</a>  
This document assumes you have a working connected Raspberry PI and that you are running Raspbian OS on it and have installed Python on the RaspberryPI.

## Create Azure Storage

- Click on **+ create a resource** in the top left corner of the portal
- Select **Storage** in the newly opened blade
- Select **Storage Account - blob,file,table,queue**
- Give a unique name for your Storage account for e.g., **iotstorage** (you can give the name of your choice)
- Under deployment model choose the **Resource Manager** Option
- Under Account Kind select **StorageV2 (general purpose v2)**
- Select **standard** performance
- under replication select **Locally-Redundant Storage (LRS)**
- Access Tier (default) select **Hot** tier
- Disable Secure transfer requied - In production depending on your use-case select Enabled
- Select your subscription
- Use your existing resource group created as part of the IoT Hub
- Select the same Location as your IoT Hub - in my case I have choosen **West Europe**
- Select **Virtual Networks** as **Disabled** for the purpose of this labs
- Click create

## Configure the Azure Storage in IoT Hub
- Goto the Azure portal home page
- Click on **All Resources** from the left navigation menu
- Select previously created IoT Hub instance for e.g., in my case **iothubpractice** 
- Scroll down to **messaging** section and select **File Upload**
- Give a unique name for your Storage account for e.g., **iotstorage** (you can give the name of your choice)
- Select **Azure Storage Container** and select the previously created azure storage and create a new container with name say **iothubfilecontainer**

## Upload the files to IoT Hub from device using File Uploader class

IoT Hub is the cloud gateway, which is the entrypoint for your devices to send messages to the Cloud. 
IoT Hub also accepts files from the devices.

Devices with intermittent connections can collect and save data locally in files and use File Upload functionality to send the data into Cloud. 
**This Lab assumes that You have a working and connected RaspberryPI or any edge device with linux os and python pre-installed on it**

- Login to your IoT device say (RaspberryPI) 
- Install the Azure IoT client sdks 
 `pip install azure-iothub-device-client`
- Create the file **file-uploader.py**
 `vi file-uploader.py`

```
import time
import sys
import iothub_client
import os
from iothub_client import IoTHubClient, IoTHubClientError, IoTHubTransportProvider, IoTHubClientResult, IoTHubError

CONNECTION_STRING = "{deviceConnectionString}"
PROTOCOL = IoTHubTransportProvider.HTTP

FILENAME = 'sample.txt'

def blob_upload_conf_callback(result, user_context):
    if str(result) == 'OK':
        print ( "...file uploaded successfully." )
    else:
        print ( "...file upload callback returned: " + str(result) )

def iothub_file_upload_sample_run():
    try:
        print ( "IoT Hub file upload sample, press Ctrl-C to exit" )

        client = IoTHubClient(CONNECTION_STRING, PROTOCOL)

        client.upload_blob_async(FILENAME, FILENAME, os.path.getsize(FILENAME), blob_upload_conf_callback, 0)

        print ( "" )
        print ( "File upload initiated..." )

        while True:
            time.sleep(30)

    except IoTHubError as iothub_error:
        print ( "Unexpected error %s from IoTHub" % iothub_error )
        return
    except KeyboardInterrupt:
        print ( "IoTHubClient sample stopped" )
    except:
        print ( "generic error" )

if __name__ == '__main__':
    print ( "Simulating a file upload using the Azure IoT Hub Device SDK for Python" )
    print ( "    Protocol %s" % PROTOCOL )
    print ( "    Connection string=%s" % CONNECTION_STRING )

    iothub_file_upload_sample_run()
```
- Save the above file
- Replace the connection string above with your IoT Device connection string
- Goto your IoT Hub instance, under **Explorers** select **Devices** select **your device id** and copy the **Connection String - Primary Key** to your connection string in the code above 
- Create a sample text file parallel to your file-uploader.py script with some text in it and name it as **sample.txt**
- Run below command
`python file-uploader.py`
- If you see below message
**File upload initiated...** followed by **...file uploaded successfully.** 
- The file upload to IoT Hub is successful, Congrats! 

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

## (Next Steps - Optional) 

- TBD