---
layout: article
title: Newsletter 19th June 2017
date: 2017-06-21
author: Adam_Bohle
image:
  feature: 
  teaser: Newsletter_Teaser.jpg
  thumb: 
comments: true
---

{% include toc.html %}

## Azure Roadmap Site
 

One thing we in the Solution Architects team at Microsoft get asked for a lot is the Azure Roadmap. Communicating roadmaps to partners and customers when working for a software vendor can usually be tricky, very often you are presenting material which is often subject to change and usually comes with a lot of disclaimers. One of the great things about Microsoft Azure is that you as the end user have good insight into what services are going to be coming down the road into General Availability by seeing what is currently in Public Preview via the preview portal <https://preview.portal.azure.com>. To build on this we now have the Azure Roadmap site which you can go to and view the current state of new features in the Azure Platform. If you are looking stay informed about new services in Azure so that you can keep your customers up to date on the platform

[Azure Roadmap Site](https://azure.microsoft.com/en-gb/roadmap)



## Azure Cloud Shell
 

 One feature that’s been in private preview for a while is the Azure Cloud Shell which has recently gone into Public Preview. This is a really nice little tool which allows you to run a terminal session with Azure CLI installed directly in the Azure web portal. Essentially this tool is run in a Docker container for the duration of the session. This is great if you want quick access to the platform agnostic CLI tool to run commands against your Azure tenant. When you fire up the CLI you are automatically logged in with your web session credentials. Please follow the below link to take a look at the tool and view instructions on how to use it.   

[Azure Cloud Shell Documentation Overview](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)



## Azure Portal Mobile App
 

Being able to access your Azure environment and perform admin tasks on the move can be extremely useful especially when traveling. I for one have made use of the new Azure App to shut down a lab environment while in a train station from my phone, very handy when you are looking to not run up your Azure bill. Please check the App out in the app stores, please follow links below for your platform of choice

[Azure App (Google Play Store)](https://play.google.com/store/apps/details?id=com.microsoft.azure)

[Azure App (Apple ITunes Store)](https://itunes.apple.com/us/app/microsoft-azure/id1219013620?mt=8)



## Partner Next
 

In the Practice Development Unit at Microsoft we spend a lot of our time talking to new and existing partners about how they can transform their business to take advantage of the Cloud. Essentially how can they become the Partner of the future in the cloud paradigm as customers choose to adopt Cloud over incumbent on premise solutions. For many Microsoft Partners this can be a daunting task. However at Microsoft we are committed to our Partner ecosystem, we appreciate how important our partners our in the success of the Azure Cloud platform and want to help as much as we can in smoothing this transition for our partners. With this in mind we have developed the Partner Next platform to help provide our Partners with the information they need to attain success in the Cloud first world.

[Microsoft UK Partner Next](https://www.microsoft.com/uk/partner/next/)



## Azure Infrastructure – Hub and Spoke vDC Best Practice
 

Microsoft Azure has a huge number of services which you as partners can leverage to deliver huge business benefits to your customers. All of that is for nought if the fundamental foundations of the Infrastructure design are not considered correctly. Very often we, as technical professionals can get swept up in the desire to implement the “cool tech”. However we need to ensure that we are implementing these new solutions on a scalable and future proof foundation. For Azure networking Microsoft have developed a set of reference architectures to show you how to implement a Hub and Spoke network architecture with your customers to ensure you start with and continue to develop a scalable solution as your customers adopt more and more cloud services and move more and more of their IT requirements to the Azure platform. Please see the following links for details regarding Hub and Spoke topologies as well as the concept of the Azure vDC.

<https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke>

<https://docs.microsoft.com/en-us/azure/networking/networking-virtual-datacenter>



## Microsoft UK GDPR Hub 
 

At the moment it feels like you can’t go from one customer meeting to the next without mention of the looming implications of GDPR. It’s certainly not the first time it’s been raised in this newsletter and I’m sure it won’t be the last. GDPR is going to be a huge change in the way we think about data privacy in the European union. Microsoft is at the forefront of keeping our customers and partners up to date with all the possible resources which we can provide to ensure our customers are compliant with this new set of requirements. The Microsoft UK team recently announced the UK GDPR Portal. This is a great jump of location for information regarding how Azure can help with being GDPR compliant, Microsoft commitment to GDPR and how you can get started with your GDPR compliance journey as everyone comes up to speed with this new set of laws around Data.

[Microsoft UK GDPR Hub Site](https://enterprise.microsoft.com/en-gb/trends/understanding-the-gdpr/)



## Azure to Azure Site Recovery (A2A) 
 

Azure site recovery has long been used to both protect and migrate workloads from on-prem locations. However we have never officially supported protecting or migrating workloads from one Azure region to another. In Preview at the moment, we have available, Azure to Azure Site Recovery. This feature will allow you to protect Azure IaaS services with source and target locations designated as Azure regions. This new feature will allow you to offer your customers complete BC/DR solutions within the Azure IaaS platform. Ensuring minimal downtime should the worst come to the worst.

[Azure to Azure Site Recovery (A2A) Roadmap Information](https://azure.microsoft.com/en-gb/roadmap/azure-site-recovery-between-azure-regions/)

