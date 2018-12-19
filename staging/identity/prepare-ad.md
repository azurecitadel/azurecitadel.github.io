---
layout: article
title: Prepare Windows Azure Active Directory
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

## Prepare Windows Active Directory
Now we need to configure our on premise domain to match the newly created and verified domain (if you own it) and configure our on premise identities to match. 
I will edit my on premise domain **wildecompany.local** then my users so they no longer log in as **user@wildecompany.local**, instead now log into **user@wilde.company** so they match!

![](./prepare-ad.png)

1. Connect to Domain Controller as a domain administrator, from server manager **Tools > Active Directory Domains and Trusts >** right click on **Active Directory Domains and Trusts > Properties**

![](../images/ExtendingIdentities_3.1.png)

2. Enter your verified domain name > **Add**. 

*I have added wilde.company*

![](../images/ExtendingIdentities_3.2.png)

3. 	In Active Directory users and computers change the UPN suffix, open user **> Account >** Select newly added UPN suffix **> OK**

*Notice the original and new UPN suffix we've just created, I have changed my user1 from @wildecomany.local to @wilde.company.* 

![](../images/ExtendingIdentities_3.3.png)

4. 	Completing this task manually will work fine but let's try using a script to save time, run Windows PowerShell ISE as an administrator on the domain controller and paste both of the lines below:

```$LocalUsers = Get-ADUser -Filter {UserPrincipalName -like "*originaluserprincipalname"} -Properties userPrincipalName -ResultSetSize $null```

```$LocalUsers | foreach {$newUpn = $_.UserPrincipalName.Replace("originaluserprincipalname","newuserprinciplname"); $_ | Set-ADUser -UserPrincipalName $newUpn}```


*Replace all of originaluserprincipalname and newuserprincipalname and Run*

*Here are my settings:*
* *originaluserprincipalname = wildecompany.local*
* *newuserprincipalname = wilde.company*

```$LocalUsers = Get-ADUser -Filter {UserPrincipalName -like "*wildecompany.local"} -Properties userPrincipalName -ResultSetSize $null```

```$LocalUsers | foreach {$newUpn = $_.UserPrincipalName.Replace("wildecompany.local","wilde.company"); $_ | Set-ADUser -UserPrincipalName $newUpn}```

![](../images/ExtendingIdentities_3.4.png)

5. 	Verify in Active Directory Users and Computers the script has worked by opening up another user > **Account**

*Notice my user3 logon name is user3@wilde.company*

![](../images/ExtendingIdentities_3.5.png)


My **@wildecompany.local** users are now **@wilde.company**. Now we have matched our on premise users our public domain they can have a consistent experience regardless of whether they're logging in to on premise or cloud apps. This is a fundamental step when migrating identities to the cloud. 

Move onto the next lab [Configure AD Connect.](./configure-adc.md)


