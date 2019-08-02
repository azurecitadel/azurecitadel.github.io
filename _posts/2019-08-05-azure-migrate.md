---
title: "Azure Migrate"
author: "Richard Cheney"
published: true
excerpt: Major release with flexible assess and migrate framework for VMware, Hyper-V and physical servers, with options for 1st and 3rd party tools
---

## Introduction

Another significant announcement from Inspire 2019 for partners was the major update to Azure Migrate.  We have been waiting for this release for some time and it should really help accelerate migration of workloads onto Azure.

* Integrated experience for Discovery, Assessment, and Migration with end-to-end progress tracking for servers and databases
* Server Assessment and Server Migration for VMware, Hyper-V, and physical server migrations
* Database Assessment and Database Migration across various database targets

Note that physical server assessment is expected in the next quarter, but as with all dates that is subject to change.  Migration for physical servers is already there.  Note that when we talk about physical servers this really covers physical and virtual servers that we need to talk to directly with an agent rather than via vCenter or Hyper-V Manager, and therefore covers other scenarios such as virtual machines running on Xen etc., or in other clouds such as AWS and GCP.

## Background

Migrating existing workloads from on premises into the platform is the default first step for most customers, before they move on to exploring the exciting options in the cloud to modernise their applications.

Azure is a great destination for the OSS workloads that this site focuses on and Microsoft has proven to be a good open source citizen and guardian of GitHub. Having said that, there is no denying that this year we will be playing on our strengths with Windows Server and SQL Server.  From assessment to migration to running the workloads we have a fantastic user experience, and naturally offer more options for SQL on Azure than you will find on competing platforms.  This includes exciting options such as Managed Instance, Hyperscale and Serverless.

From a commercial perspective we are unbeatable with all of the following bringing the Azure pricing down:

1. Reserved Instances
1. Hybrid Benefit (using Software Assurance to remove OS/SQL licence costs for VM pricing)
1. Free security updates for three years for Windows Server 2008 (R2) and Windows SQL 2008 (R2)

The last one is key as the end of life dates for 2008 and 2008 R2 have become a natural trigger for latent cloud migration projects. When compared to the alternatives, Azure is proving more cost effective, simpler to migrate to and reduces business risk. Azure is therefore the natural platform of choice for many organisations.

## Links

So these upgrades to Azure Migrate are very timely!  Read about the new enhancements with these links:

### Updates

* [Update] [Azure Migrate is now a central hub to start, execute and track your migration journey](https://azure.microsoft.com/updates/azure-migrate-enhancements/)
* [Blog Post] [Introducing the new Azure Migrate: A hub for your migration needs](https://azure.microsoft.com/blog/introducing-the-new-azure-migrate-a-hub-for-your-migration-needs/)

### New Videos

* [Get Started with Azure Migrate](https://www.youtube.com/watch?v=wFfq3YPxYHE)
* [How to discover, assess, and migrate VMware VMs to Azure](https://www.youtube.com/watch?v=gO89GtTaFas)
* [How to discover, assess, and migrate Hyper-V VMs to Azure](https://www.youtube.com/watch?v=lrccmB01D_s)

### Product Page

* <https://aka.ms/AzureMigrate>

### Docs

* <https://docs.microsoft.com/azure/migrate/migrate-services-overview>

## Credit

Thanks again to Taygan Rifat for another useful set of links.
