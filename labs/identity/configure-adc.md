---
layout: article
title: Configure Active Directory Connect
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

## Configure Active Directory Connect

We're almost ready to synchronize our identities, but first we'll create a new global admin (specifically for the new Azure AD Tenant) and use that account for AD Connect.

I will be creating a new Global Admin on my **wilde.company** Azure Active Directory Tenant and using that account in AD Connect to synchronize my on-premise users (**userX@wilde.company**).

1. In Azure Portal > **Azure Active Directory > Users and Groups > All Users > New User >** Set Name, User name and Global Administrator as the Directory Role **> Copy** the password.
	
*Noticed I have created a global administrator **tom.wilde@wilde.company***

![](../images/ExtendingIdentities_4.1.png)

2. Open up a private browsing/incognito session and log in as the global administrator you just created.

![](../images/ExtendingIdentities_4.2.png)

3. In the Active Directory virtual machine (adVM), download Azure Ad Connect from https://www.microsoft.com/en-us/download/details.aspx?id=47594 and run the installer (you may need to change your internet zone settings to download the file). **Agree > Continue > Customize >** select **Pass-through authentication** (this means all authentications are completed using the on-premise Active Directory), select **> Enable single sign-on** (this means users that use devices that are Active Directory domain joined will be automatically logged into cloud applications seamlessly - a great feature!)

![](../images/ExtendingIdentities_4.3.png)

4. Enter the Global Administrator details for the new Azure Active Directory Tenant **> Next**

*I have used my **tom.wilde@wilde.company** global admin*

![](../images/ExtendingIdentities_4.4.png)

5. Connect the Directories by allowing the AD Connect wizard to create an account for AD Connect to use. **Add Directory > Create new AD Account > Enter new Username and Password > OK**

*I created a user of **WILDECOMPANY.LOCAL\ADC** for AD Connect to use when syncronising*

![](../images/ExtendingIdentities_4.5.png)

6. The on-premise and cloud directories are now connected! **Next**
	
![](../images/ExtendingIdentities_4.6.png)

7. Notice the on-premise domain shows not added and the new Azure Active Directory public domain shows as verified.
**Next**

![](../images/ExtendingIdentities_4.7.png)

8. Choose what OU's you want to sync. 

*All my users are in the Users organizational unit but you may seperate them out to remote/cloud/departmental groups.*

![](../images/ExtendingIdentities_4.8.png)

9. Choose how you want to uniquely identify your users **> Next**
	
*I only have a single on-premise directory so the default options work but if you have multiple directory you need to choose what makes a user unique.*

![](../images/ExtendingIdentities_4.9.png)

10. **Next**

*Again, for this lab we can synchronize all users but you could apply some filtering to only sync the users that would use the cloud.*

![](../images/ExtendingIdentities_4.10.png)

11. **Password writeback > Next**

*I have selected password writeback (so any password changes in the cloud will replicate to on-premise) and have not selected password synchronization (so passwords are not actually stored in the cloud).*

![](../images/ExtendingIdentities_4.11.png)

12. **Enable Single Sign on >** authenticate with your local domain admin **> Next**

*If you add Windows 10 devices to the on-premise domain they can be authenticated automatically with cloud applications.*

![](../images/ExtendingIdentities_4.12.png)

13. Confirm you want to start synchronization after the installation is complete **> Install**

![](../images/ExtendingIdentities_4.13.png)

14. Notice the information displayed **> Exit**

![](../images/ExtendingIdentities_4.14.png)

15. Let's verify the connection, in the Azure portal **> Azure Active Directory > AD Connect**

*Notice my sync status, seamless single sign-on and pass-through authentication are all enabled for wilde company.*

![](../images/ExtendingIdentities_4.15.png)

16. **Users and Groups > All Users**

*Notice the new users and their usernames **x@wilde.company**, these have been synchronized from on-premise.*

![](../images/ExtendingIdentities_4.16.png)

17. Let's test logging into the cloud as user1 by logging into the Microsoft Access Panel Applications - https://myapps.microsoft.com. This is where all the cloud and on-premise applications would be once they've been assigned, such as Office 365, Salesforce, Box, Docusign, Concur, etc

![](../images/ExtendingIdentities_4.17.png)


*Example Access Panel Applications below*

![](../images/access-panel-example.png)


**Lab complete.** 

So to recap, we have created a new on-premise Windows Active Directory Domain (with a few users) > created a new Azure Active Directory Tenant > modified our on-premise users' UPN Suffix (so they have a matching login to on-premises and the cloud) > configured AD Connect and extended our identites to the cloud.

![](../images/Lab-finished.png)


Now we have connected our on-premise and cloud directories you can open up cloud functionality to those synchronized users! 

