---
title: SAP Systems Journey to Azure
date: 2019-07-17
category: saponazure
tags: [azure-ad, identity, hybrid]
author: Pankaj Meshram
header:
  teaser: /images/teaser/saponazure.png
excerpt: Learn about SAP Systems journey to Azure & and how that unlocks Innovation by Integration with Azure Services.  

# ****SAP Systems Journey to Azure ****

SAP systems are one of the most complex systems in any customer’s landscape. In this blog I want to highlight the sequence of steps a typical customer would go through in their journey to Azure. 
There are different migration triggers for the customer when they decide to move to cloud for example datacentre contract come to an end, hardware or software refresh cycles but one of the major driver is SAP’s Deadline - SAP will stop supporting currently supported databases for example SAP on SQL/Oracle/DB2 etc. & will only support HANA as a database for SAP Business Suite 7 core applications. For example, SAP ECC on Oracle will have to move to S/4 HANA which is the next-generation business suite designed to Run Simple in a digital economy. This means the new generation ERP called S/4 HANA running on HANA database only. 


An extract from SAP’s last announcement - “In October 2014, SAP announced an extension of the mainstream maintenance for SAP Business Suite 7 core application releases including SAP ERP 6.0, SAP Customer Relationship Management 7.0, SAP Supply Chain Management 7.0, SAP Supplier Relationship Management 7.0 and corresponding enhancement packages, as well as SAP Business Suite powered by HANA 2013, from end of December 2020 to end of December 2025.”



The deadline provides an opportunity & interesting challenge to move SAP systems into Azure with different scenarios possible. A customer will typically convert, transform or take a greenfield approach to S/4 HANA.  The following diagram gives an overview about the different scenarios 


![sapjourney](\Users\pameshra\OneDrive - Microsoft\AZURE_TECHNOLOGIES\IP_Buildig\sap\images\sapjourney.jpg)


No matter at which stage the customer is with respect to their landscape, the eventual aim is S/4 Hana or BW/4HANA or C/4HANA depending on the landscape components. Outlined are the typical steps for a customer’s journey into Azure. Once might find overlapping scenarios between Step 1 and 2 depending on the path a customer wants to take for S/4HANA. Let’s explore each option


##STEP -1 Journey to Azure 

-**Scenario A** - The customer’s SAP landscape has got SAP ERP systems and other SAP systems running on any database other than SAP HANA. For example, SQL, ASE, Oracle etc. This is a pure Lift & shift opportunity. Cloud is the driver to reduce IT TCO. 

-**Scenario B** - The customers landscape has SAP ERP systems and other SAP systems running on non- HANA Databases, so this is exactly the same as option A but the customer could like to change the database to save cost on licensing. A regular example is to change from Oracle to SQL database. This requires migration of SAP systems from one database into another and is termed as “Database migration”.  The opportunity is “Lift and Migrate”. Once the systems are moved into Azure the customer can start the preparation for S/4 HANA. Cloud is the driver to reduce IT TCO along with cost savings from licensing of databases. 

-**Scenario C** - The customer could be running a combination of option A or B and would like to move to Cloud along with changing the database to SAP HANA. This is Lift and shift/Migration to cloud/Migrate part to SAP HANA. Example SAP ERP system running on Oracle or SQL will become SAP ERP running HANA. This is termed as ‘Suite on HANA’ aka ‘SoH’. This fits with the technology roadmap for the customers where in few years they are looking to change to S/4 HANA and with HANA  as underlying database they are best placed in their journey to S/4 HANA.

-**Scenario D** - The customer is looking to move directly to S/4 HANA. This could be via consolidation, selective Re-implementation or a complete greenfield approach. 

Based on the above scenarios & the industry segment one must think about some important factors. Some of them are listed below 

- Assessment of current landscape – Understand the versions for Operating systems, Database & SAP software. Understand the current hardware specifications i.e. Server, storage, network. It is important to asses these versions and upgrade them to the supported version on Azure.

- Database Requirements - Check the DB metrics available e.g. DB volume, IOPS etc & understand the Database specific requirements on Azure while designing the systems. The general guidance & DB specific ones can be found here  - https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/dbms_guide_general

- Availability needs – What are the uptime requirements, current SLAs, RTO & RPOs. This will help to design the right solution for High availability and Disaster recovery.  The general guidance can be found here - https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-high-availability-guide-start

- Backup/Archival- Understand the backup lifecycle for example how many backups for production in a week and the retention for them. Check if any archiving is in place & explore the possibility of reducing Database footprint. 

-	Sizing - Sizing of compute, storage and networking components in Azure. For SAP sizing of Azure VMs, consult SAP support note #1928533. The Oss note details about the supported SAP software components and all the VMs which are certified to run SAP systems.. The sizing of VMs can be based on current EWA reports & Quicksizer Outputs (SAP’s tool to calculate capacity requirements around CPU, Memory, Disks etc). The output from Quicksizer is shown as SAPS where 100 SAPS is equal to 2000 fully processed business line order items per hour. If the SAPS figures are available, one can easily compare and select the correct VM. The sizing for HANA database is based on memory and therefore the VM selection is based on the Memory of the VM. 

-	Design to be architecture – Based on the above input, design To Be architecture. The design of architecture could be different on Azure based on different technologies available. For Example, Windows HA for ASCS cluster can be achieved using SIOS or SOFS. It is important to understand what the different options are available on Azure

Our engineering team has released a deployment checklist which covers all the steps and can be found here 
https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-deployment-checklist

##STEP -2 – Journey to S/4 HANA 

>Once the customer has moved their SAP Landscape into Azure, they will embark on their journey to S/4 HANA. This could be achieved uses the three different routes. 
Let us look at these 3 options 

1. **New Implementation** - A new implementation of SAP S/4HANA (also called a “greenfield”
approach) enables complete reengineering and process simplification, lets you predefine
migration objects and best practices, lowers time to value and TCO, and facilitates faster
adoption of new innovations.

2. **Landscape Transformation** - This route is for you if you’re looking to consolidate your
landscape, while selectively transforming data in a phased approach that focuses on the
parts of your business with the highest ROI and lowest TCI. The most commonly used example is S/4 HANA central finance system where multiple SAP systems replicate financial data real-time to a CFIN S/4 HANA system. 
![s/4hana][C:\Users\pameshra\OneDrive - Microsoft\AZURE_TECHNOLOGIES\IP_Buildig\sap\images\s4hana.jpg]

3. **System Conversion** – This route, also called a “brownfield” approach, enables migration
to SAP S/4HANA without re-implementation and without disruption to existing business
processes. At the same time, it enables re-evaluation of customization and existing process flows.

No Matter which option a customer chooses, they could use the advantages of Azure like Flexibility, Agility, Performant, Security, Automation, Insights & Geographic Reach. Using this one can build extremely quick POCs for S/4 HANA projects, test the requirements and based on results proceed for the production systems. 

##**Step 3 - Convert Data into Intelligence/Innovation  ** 

One of the major benefits of moving into Azure is that the customers can leverage the power of Intelligent Cloud. There are various tools and services available within azure using which you can integrate SAP systems & extract data into Azure. Once the data is available further analytics & reporting can be performed. These tools help the customers to harness SAP data or non-SAP data, combine it & convert that data into Intelligence. Azure has a rich set of services which we collectively call as Cortana Intelligence Suite providing gallery of services used for this scenario. You can use services such as HDInsight or Data Bricks for Big Data, Power BI for visualizing, and Azure ML for analyzing and building predictive models. Once you have meaningful insight, you can drive projects to act on Azure where you can build apps, bots and so on. 


![adf][C:\Users\pameshra\OneDrive - Microsoft\AZURE_TECHNOLOGIES\IP_Buildig\sap\images\adf.png]


![missioncritical][images\missioncritical.jpg]

Some of the listed connectors or integration scenarios are 

-  Integration with Azure AD - One of the most common use cases is the Integration with Azure Active directory to serve customer’s identity & access management needs. Whether the requirement is to integrate with SAP’s SaaS products like SAP Cloud Platform or with Standard product like SAP NetWeaver, the customers can leverage the power of Azure AD along with features like SSO with MFA etc. To explore further, please see the link - https://docs.microsoft.com/en-us/azure/active-directory/saas-apps/sap-customer-cloud-tutorial?toc=%2fazure%2fvirtual-machines%2fworkloads%2fsap%2ftoc.json

-	Azure Data Factory Connectors – If you have integration requirements for SAP HANA, SAP BW, SAP ECC or SAP Cloud for Customer, there are different connectors available to extract data. For example, SAP ECC connector or SAP HANA connector 

-	PowerBI Connector – The connector is available for Sap HANA and SAP BW 

-	Logic Apps Connector - supports message or data integration to and from SAP NetWeaver-based systems through Intermediate Document (IDoc) or Business Application Programming Interface (BAPI) or Remote Function Call (RFC).

-	Office 365 and SAP - Make SAP Data available in Office tools like Microsoft Word or Microsoft Excel

-	Azure IOT and SAP – Iot hub collects data from devices. Based on ML trained model damaged status is set and the information can be sent to SAP for reordering the device

A lot of customers especially large-scale enterprises can provide unique challenges for data extraction in terms of SAP’s Security, GDPR and integration with non-SAP data. Here one can explore and leverage our partner eco-system who have extensive experience in data extraction from SAP. Enlisted are some of the major ones in this space. 

-	Simplement Data Liberator - https://www.simplement.us/
-	Kagool Velocity - https://www.kagool.com/product-velocity
-	Theobald Software XtractIS - https://theobald-software.com/en/
-	Attunity Replicate for SAP ECC  - https://www.attunity.com/


To summarize the customers can move SAP systems into azure using various options, transform to S/4 HANA leveraging the flexibility and agility of Azure and use Azure Services for insights that can help them to innovate faster and transform business processes. #
