---
layout: article
title: Newsletter 20th March 2017
date: 2017-03-20
comments: true
author: Adam_Bohle
image:
  feature: 
  teaser: Newsletter_Teaser.jpg
  thumb: 
---

{% include toc.html %}

## Azure Learning Resources
 

Useful information in the subject of learning new skills on Azure.
 
# Azure Learning Paths
 
This is a really useful and little known resource which we have in the Azure Documentation area, learning paths have been constructed to enable you to pick a subject area, such as Azure API Management, Azure Automation, Azure Backup, etc. Learning paths give you a workflow to follow with links to documentation material which you can use to walk through the solution in your own Azure subscription and learn the technology. Having the learn path to guide you ensures you do not miss vital information for learning a particular feature/solution in Azure. Please follow the link below to review the available learning paths

[Azure Learning Paths](https://azure.microsoft.com/en-us/documentation/learning-paths/)


# Upcoming Online Azure Training Events

Microsoft regularly hosts online learning events across a number of technology areas in the Azure portfolio, please see below for a list of upcoming webinar events which you may find useful;

[20th March 2017 What's new in Enterprise Mobility + Security](https://www.microsoftevents.com/profile/form/index.cfm?PKformID=0x12635770001)


[20 March 2017 Understanding Identity & Access with Azure](https://www.microsoftevents.com/profile/form/index.cfm?PKformID=0x14689670001)

[23 March 2017 Technical Deep Dive on Big Data on IoT Solutions with Data Factory and HDInsight] (https://www.microsoftevents.com/profile/form/index.cfm?PKformID=0x10930900001)

[29th March 2017  Use Azure Security Center and OMS to prevent, detect and respond to threats](http://note.microsoft.com/UK-PRM-WBNR-FY17-03Mar-29-Use-Azure-Security-Center-and-OMS-to-prevent-detect-and-respond-to-threats_310548_Registration.html)

[5th April 2017 Technical Deep Dive on App Service - Mobile App Notification Hubs](https://www.microsoftevents.com/profile/form/index.cfm?PKformID=0x10914750001)

[6th April 2017 Technical Deep Dive on Data Lake Analytics and Machine Learning for IoT solutions](https://www.microsoftevents.com/profile/form/index.cfm?PKformID=0x10948760001)


## Upcoming UK Events
 

Stay informed regarding Microsoft and partner hosted training events which will be useful in building your Azure Cloud Practice 
 
**London ISV Industry Insight Event – 6th April 2017**
 
On the 6th April our Enterprise Partner Group (EPG) will be hosting an event in London to bring customers and partners together with ISVs and share industry specific insights across a number of verticals from Media, Insurance, Banking, Manufacturing, etc. The event will include a keynote from Jason Zander, CVP Azure R&D. We plan to host 2-300 customers at this event with afternoon breakout sessions, please see the below registration link for full details.

[ISV Industry Insight Event Registration](https://www.microsoftevents.com/profile/form/index.cfm?PKformID=0x15482739b4f)


**EMEA GBB Cloud Infrastructure Partner LABS, Microsoft, 2 Kingdom Street, Paddington**

On the 27th and the 29th of March, Microsoft will be hosting interactive training and “hands on”  sessions, meant to bring clarity on the newest technologies in the Azure cloud and advanced workloads, such as IT Operations Insights & Analytics, Automation & Control, Hybrid Storage, Open Source, Networking and Security in the Cloud. Partner labs are setup in the format of end-to-end demo heavy sessions. In order to register for sessions, please follow the email links below;

**Agenda**
*	Lab 1: Insight & Analytics – Automation & Control 
*	Lab 2: Open Source 
*	Lab 3: Hybrid Storage
*	Lab 4: Networking & Security 
Detailed agenda for each day is provided in the attachment. 

**Audience**
*	Azure architects and engineers
*	We welcome two architects/ engineers per company at each lab

**Prepare for your workshop**
*	Consider and ensure you meet the pre-requisites for each lab   in the attachment. Some labs require Laptops & Azure               subscription.

*	Be ready to openly share your views and present current challenges in your projects (no worries, you don't need to share actual customer names or info).

To save your seat for Cloud Infrastructure advanced workloads workshop, please Register ASAP by clicking the relevant link in the left column of the invitation, and we’ll confirm your reservation by email.

[Insight & Analytics, 27th March (1 day)](mailto:elinaz@microsoft.com?subject=Cloud%20Infra%20Event:%20Register%20for%20INSIGHTS%20and%20ANALYTICS%20Partner%20LAB%20on%2027th%20of%20March)
[Open Source, 27th March (1 day)](mailto:elinaz@microsoft.com?subject=Cloud%20Infra%20Event:%20Register%20for%20OSS%20Partner%20LAB%20on%2027th%20of%20March)
[Hybrid Storage, 27th March (1 day)](mailto:elinaz@microsoft.com?subject=Cloud%20Infra%20Event:%20Register%20for%20HYBRID%20STORAGE%20Partner%20LAB%20on%2027th%20of%20March)
[Networking and Security, 29th March (1 day)](mailto:elinaz@microsoft.com?subject=Cloud%20Infra%20Event:%20Register%20for%20NETWORKING%20Partner%20LAB%20on%2029th%20of%20March)


## Technical Insights


In this section we will cover off useful learnings from the field which have arisen from working with multiple PDU partners on Cloud Infrastructure Management practice activities

**Correctly Power Off VMs**

The question of correctly powering off VMs in Azure has arisen on many occasions. Please be aware that powering off the VM from within the Guest OS will no “deallocate” the VM from the Azure infrastructure, so even though the VM is powered off, you will still be charged to your subscription as if the VM were still running. Chris Pietschmann over at buildazure.com wrote a recent article on this which is worth checking out;

<https://buildazure.com/2017/03/16/properly-shutdown-azure-vm-to-save-money/>
