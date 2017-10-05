---
layout: article
title: Create Windows Active Directory Forest
date: 2017-09-19
tags: [aad, identity, hybrid]
comments: true
author: Tom_Wilde
image:
  feature: 
  teaser: Education.jpg
  thumb: 
---
Extending Identities to the Cloud.

{% include toc.html %}

## Create Windows Active Directory Forest
First we need to create a new Windows Active Directory Forest and Domain to use during this lab and we'll utilise an ARM template to do all the hard work.

I will be creating a new on-premise Windows Active Directory domain called **wildecompany.local**. It's common that an on-premise Windows Active Directory domain doesn't always exactly match your public domain so in a future lab I will show an easy work around. *e.g. Company.local for Windows Active Directory and Company.org for public domain can work together*

![](../images/create-ad.png)

1. In the Azure Portal, search for and open **Deploy a custom template**

![](../images/ExtendingIdentities_1.1.png)

2. Type in **Active-directory-new-domain > Select Template**

![](../images/ExtendingIdentities_1.2.png)

3. Fill in the parameters requested > **Purchase** 

*My settings are below but you can customise it relevant to you:*
* *Admin Username - domainadmin (in a production deployment it's recommended to make this difficult to guess)*
* *Resource Group - WildeCompany*
* *Location - West Europe*
* *Domain Name - wildecompany.local (the domain name requires a full stop)*
* *Dns Prefix - wildecompany* 

*Please note - The template can take up to 30minutes to deploy completely.*

![](../images/ExtendingIdentities_1.3.png)

4. Log into the virtual machine created by the template **Resource Groups >  WildeCompany > adVM > Connect**

![](../images/ExtendingIdentities_1.4.png)

5. In Server Manager **Tools > Active Directory Users and Computers >** right click on **Users > New > Users >** create a few dummy users. 

*I have created user1, user2, user3*

![](../images/ExtendingIdentities_1.5.png)


We've now created an Active Directory Forest with a single Domain and multiple users.

Move onto the next lab [Create Azure Active Directory.](./create-ad.md)

