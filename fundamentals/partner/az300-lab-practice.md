---
title: "AZ-300 Lab Practice"
date: 2019-08-28
author: [ "Richard Cheney", "Ben Coleman" ]
category: automation
comments: true
featured: false
hidden: true
published: true
tags: []
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
excerpt: Work through these exercises to prepare for the labs in the AZ-300.
---

## Introduction

Practising with these examples will help to prepare you for the kind of tasks that you will find in the two AZ-300 lab sections.

> ***IMPORTANT!!*** Note that there are no longer exams in the AZ-300. This page will be retained in case they return, and also so that you can test your own knowledge and get broader portal experience if you find any gaps.

There are two lab sections in the exam:

1. IaaS
1. PaaS

These examples are a little more complicated than those you’ll find in the exams.

Most of the exam lab work is completed in the portal, but you may be asked to achieve something in the Cloud Shell. The question will stipulate either Azure CLI or PowerShell.

## Tips

Provision services in the portal to understand the available options. Combine your architectural knowledge whilst reading the docs to determine why certain options would be selected.

Put yourself in the position of an examiner.  What knowledge could you test for? How would you test for it? And therefore what do you need to remember?

As a student then be effective with your time. Aim for the minimum effort to achieve the objectives.  Don’t over-engineer!

Configuration is programmatically assessed after each section. Order of completion is not important, but make sure all tasks are completed before clicking on done.

Don’t configure the Cloud Shell before being asked to do so. There will be specific instructions and you cannot reconfigure.

There have been some technical issues with the labs which are under continual improvement. If something happens during your test then speak with the proctor. They can normally resume the session in a new tab with little loss of time.  However, you should ask for additional time to be added if the host server needs to be rebooted.

## Azure CLI

1. Start Cloud Shell in Bash mode for the Azure CLI
1. Type `az` to show the first level
1. Type `az network --help` to see what is available at the second level
1. Type `az disk create --help` to see full command help and examples
1. Type `az find subnet` to show common commands that include the string “subnet”

You won’t be asked to do anything too complex such as JMESPATH queries or integrating with scripting via the different output types.

## PowerShell

1. Switch the Cloud Shell to PowerShell mode
1. Note that the cmdlets have been updated from AzureRM to Az
1. Type `help`
1. Type `help disk` to show all cmdlets that include disk in the cmdlet name or description
1. Type `help New-AzDisk` to see full cmdlet help and example

Again, the questions will only ask for simple one line cmdlet execution, so no scripting, objects, etc.

## Getting started

### Notes

* We will be working exclusively in West Europe unless otherwise stated
* All resources will be created in the “practice” resource group unless otherwise stated
* Skip the AAD and RBAC steps if you have insufficient access

### Tasks

1. Verify that there is an AAD group called Exam Practice
    1. If not then create one if you have permissions
    1. Become an owner for the group

1. Provision a resource group called “practice”
    1. Add tags for
        1. Owner: _\<your name\>_
        1. Environment: training

1. Allow any members of the “Exam Practice” group to start, stop or reboot virtual machines that are in the “practice” resource group
    1. Use a built in role
    1. Use principle of least privilege

## IaaS Networking

### Notes

* All vNets are named vNetX, where X is a number, and are /16
* The second octet in the address space for the vNets will match the vNet number X
* Subnets are named subnetY  (where Y is a number)
* Third octet in the address prefix for a subnet will be Y
* Subnets will have a subnet mask of 255.255.255.0
* Note that you won’t be completing the connections to (the imaginary) on premise devices in these labs

### Tasks

1. Provision a vNet called vnet0, with namespace 10.0.0.0/16
    1. this will be your hub vNet in a hub and spoke config
    1. we’ll create a VPN gateway later; so create a suitable subnet with address prefix of 10.0.0.0/24
    1. create an Azure Firewall called “firewall” (10.0.10.0/24)

1. Deploy a VPN Gateway called vpngw (don’t wait for it to finish)
    1. the customer does not yet understand their traffic requirements
    1. there are two on premise VPN devices, requiring IKEv2
    1. they use BGP, and have requested you specify AS number 65515
    1. the customer is concerned about Azure datacentre failure and minimising any downtime

1. Add two spoke vNets, called vnet1 and vnet2
    1. vNet1 needs one subnets, subnet1
    1. vNet2 needs two subnets, subnet2 and subnet3

1. vNet peer both spokes vNets to the hub vNet
    1. resources in vnet1 should not be able to talk to resource in vnet2, and vice versa
    1. the spoke vNets will use the hub for on prem traffic
    1. note that you won’t be able to configure this until the VPN Gateway has been successfully deployed

1. Create static route table called “spoke”
    1. Via the VPN gateway to reach on prem address space 10.76.0.0/16
    1. Via the firewall for default traffic
    1. Use in both spoke vNets

1. Add a “mgmt” vNet (172.16.0.0/24) that can access the spoke vNets
    1. VMs in the mgmt vNet should not be accessible from the spokes

## Iaas VMs

### Assumptions

* Ubuntu 18.04 latest is the default image, B1s is the default VM size
* The customer application is architected to scale over multiple VMs
* IOPS and throughput requirements are low unless stated otherwise
* No public IPs, NSGs or data disks during VM creation unless specified
* Use admin username “practice” and password “Pi=3.1415927”

### Tasks

1. Deploy a single VM called ‘vm’
    1. Requires a 99.9% availability SLA
    1. Attach to subnet1 in vnet1
    1. Allow TCP port 22 if coming from within the vNet
    1. Block all other incoming traffic except on port 8443

## Iaas Storage

### Assumptions

* None

### Tasks

1. Create a storage account, name starts with sa1
    1. Needs to support file, blob and table storage
    1. General purpose, accessed by multiple servers and applications

1. Create a storage account, name starts with sa2
    1. Longer term storage area with large blobs
    1. Cost sensitive
    1. Infrequent reads
    1. Data must be accessible in North Europe upon regional application failover

1. Create a storage account, name starts with sa3
    1. Support file storage
    1. High performance required
    1. Low latency reads required

## PaaS Web Apps

### Assumptions

* Your subscription may not have Microsoft.Insights registered as a provider. If that is the case then find  Subscriptions in the search bar, filter to fine Microsoft.Insights and then register.  It will take a few minutes. (In the labs all of the required providers should be pre-registered for you.)

### Tasks

1. Create a Linux web app
    1. Running a NodeJS 10.14 based website
    1. Needs to be able to scale the underlying instances up and down based on site demand
    1. Application is CPU bound and a server starts to slow down when CPU is over 85% for more than 5 minutes. Anything under 40% is considered candidate for scaling down
    1. Customer has registered a domain to use for the site; it won’t be configured in this lab but select a SKU that can support that configuration
    1. All http URLs should redirect to https

### Notes

A few things to remember for Web Apps:

* A single “App Service Plan” can host multiple Web Apps also called “App Services” or sites
* App Service Plans have pricing tiers (also called SKUs) that define both compute resources and features available
* Scaling is at the App Service Level not the web app, either Scale Up (pricing plan) or Scale Out (number of instances)
* Auto scaling is only possible on certain levels of pricing tiers
* Consumption is a special type/tier of App Service Plan only used by Functions

Compare Web App features: <https://azure.microsoft.com/en-gb/pricing/details/app-service/plans/>

* Windows App Service
    * Bring your code (FTP, git, Bitbucket, zipdeploy)
    * App is run inside Windows IIS sandbox
    * .NET Classic, .NET Core, Node.js, PHP  (Python & Java supported but NOT recommended)
* Linux App Service – Publish Code
    * Bring your code (FTP, git, Bitbucket, zipdeploy)
    * App is run Linux Container running a predefined “stack”
    * .NET Core, Node.js, PHP, Java, Python, Ruby
* Linux App Service – Publish Container
    * Bring your own prebuilt Docker Linux container image
    * Support anything that runs in a container with HTTP/S traffic
* Windows App Service – Publish Container (PREVIEW)
    * As Linux but runs Windows containers, only use if Windows Containers is a requirement for your app

## PaaS Functions

### Notes

* Your function names will need to be globally unique
* Configure storage to use your sa1 storage account

### Tasks

1. Create a .Windows function app
    1. Running 64 bit .NET Core code
    1. Needs to be “warm” for good user experience on a high profile application
    1. Ensure FTP deployments are secure and HTTP is v2.0

1. Create a Linux function app
    1. Running Python code
    1. Low cost
    1. Infrequently triggered

## PaaS DNS

### Assumptions

* None

### Tasks

1. The customer wishes to host private DNS records in Azure without running a domain controller
    1. Specify a globally unique test domain suffix i.e. `az300mynamepractice.com`
    1. Create a record for lb.practice.com for the load balancer’s public IP address
    1. It is important that the public IP address does not change

## PaaS Container Instances

### Assumptions

* Basic knowledge of Docker <https://azurecitadel.com/cloud-native/tech-primer-containers/>

### Tasks

The team wants to test that their new application runs in a container.

1. Create an Azure Container Registry to store the application container image
1. Use Azure Cloud Shell to build example app image from <https://github.com/benc-uk/dockerdemo> and push to ACR
    * Tip: The Azure CLI az acr build command lets you build directly from a Git URL and pushes it into the ACR
1. Deploy ACI instance of the newly built image, make sure it has a public IP
    * Tip: It runs on port 8000
1. Access the app in your browser to validate it has deployed and started

## Additional Resources

Make use of these resource to help address any gaps in your knowledge of the AZ-300 topics.

* [AZ-300 Exam](https://aka.ms/az-300)
    * [Pixel Robots](https://pixelrobots.co.uk/2018/09/study-resources-for-the-az-300/)
* [Microsoft Learn](https://azure.com/learn)
    * [Learning Paths for Solution Architects](https://docs.microsoft.com/en-us/learn/browse/?products=azure&resource_type=learning%20path&roles=solution-architect)
    * [Hands On Labs](https://aka.ms/hol)
    * [Pluralsight for Azure Architects](https://www.pluralsight.com/role-iq/microsoft-azure-solution-architect)
* [Azure Citadel](https://azurecitadel.com/)
