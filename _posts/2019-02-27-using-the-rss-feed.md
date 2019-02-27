---
title: "Adding the RSS atom feeds for Azure Citadel and Azure Blogs"
author: "Richard Cheney"
published: true
---

# RSS Feeds

## Introduction

RSS feeds are not exactly new technology, but are still one of the most useful ways to keep on top of new announcements.

I subscribe to a few atom feeds and thought it would be useful to run through the process. The feeds for Azure Blogs and for this site are:

* **Azure Blogs**: <https://azurecomcdn.azureedge.net/en-us/blog/feed/>
* **Azure Citadel**: <https://azurecitadel.com/feed.xml>

Both feeds are shown on their respective landing pages.

I think it is fair to say that the Azure Blogs one is the more active of the two!

We will use the Azure Citadel feed to announce new content and also anything else that we think may be of interest to the UK partner community.

## Dedicated Mobile Readers

Many people use dedicated readers on their phone. Many of these apps will take the aggregated feeds from [Feedly](https://feedly.com) rather than going direct.

Most apps make it easy to swipe between posts and keep a record of which you have read. The Feedly site also gives you quick access to popular feeds for topics that you are interested in.

## RSS feeds in Outlook

Many of you will be Office 365 users (or the standalone Office software). Here is one way to add these RSS feeds directly into Outlook.  This is so useful as you quickly see when new posts are out, and you can also use the standard Outlook search tools:

![Searching for Python blogs](/images/posts/2019-02-27-python.png)

## Adding a feed into Outlook

OK, let's do that for the Azure Citadel feed. Once it is done then the posts will go straight into your Inbox.

1. Right click on Inbox, create a New Folder called "Azure Citadel
1. Click on File --> Account Settings
1. Select the RSS Feeds tab
1. Click on New
1. Paste in `https://azurecitadel.com/feed.xml` and click on Add
1. Click on Close

![Adding Azure Citadel atom feed](/images/posts/2019-02-27-atom.png)

(Alternatively, you can try right clicking on the RSS Subscriptions in your Outlook folders pane and Add A New RSS Feed from the context menu, but this does depend on your version of Outlook.)

## Adding a rule

Personally I then create a sub-folder called Azure Citadel underneath Inbox and then have a client side rule to move the posts into there.

![Rule to move](/images/posts/2019-02-27-rule.png)