---
title: "Edge extensions to download Azure icons and mask sensitive data"
author: "Richard Cheney"
published: true
excerpt: Cool extensions to allow you to download SVGs of the Azure Portal icons or mask sensitive in screenshots
---

## Introduction

We are big fans of the work done by the Edge team with the new Chromium based browser. We've been using it from Canary to Dev to Beta versions, and it quickly became our default browser within the team.

One thing that makes it all the more useful is the extensibility.  There are a couple of useful extensions that we use regularly, and we thought it only right to share them now that Edge has gone GA. (If you prefer Chrome then they'll work there too.)

Both extensions are community contributions from Microsoft and Pluralsight employees specifically designed to enhance your use of the Azure Portal. Both have been asked not to use the name "Azure" in their titles due to trademark infringement.  This has made them a little more difficult to find so here is a quick post to help their work reach a slightly wider audience.

## Amazing Icon Downloader

This is a great little extension that lights up whenever you are in the portal, and makes if very easy to scrape out any of the icons as SVG files. As SVG files are vector based then they scale beautifully, with no jagged edges regardless of the size, and they are natively supported in Visio, PowerPoint and the other office apps. You just drag them straight in. So no more excuses for using any of the old icons in your presentations or architectural diagrams!

Here is an example screenshot:

![Amazing Icon Downloader](/images/posts/2020-02-24-amazing-icon-downloader.png)

### Enable Chrome Store

If you are in Chrome then you can go straight to the [next step](#install-the-extension).

In Edge, enable the Chrome Store in the [extensions](edge://extensions/) screen:

* Click on the ellipsis at the top right (**...**)
* Click on **Extensions**
    * If the menu on the left is not visible then click on the hamburger to open it up
* Toggle the "Allow extensions from other stores" button

![Enable Chrome Store](/images/posts/2020-02-24-enable-chrome-store.png)

### Install the extension

Go to the [Amazing Icon Downloader](https://chrome.google.com/webstore/detail/amazing-icon-downloader/kllljifcjfleikiipbkdcgllbllahaob) page in the Chrome Store.

Enjoy Matt's Overview description, and then click on that big blue "Add to Chrome" button.

It is up to you whether you keep it visible or move it to the menu via the right click.

## Azure Mask

This is another favourite as it allows you to safely take screenshots whilst blurring out most of the sensitive data such as emails, the GUIDs for your subscription IDs, service principal secrets, storage keys, etc. It runs in Chrome, Firefox and Edge.

This one is a bit trickier to install as it is in an approval limbo land at the moment, but is well worth the effort for those of you creating blogs or technical documentation.

Here is an example screenshot of it in action:

![AzMask](/images/posts/2020-02-24-masked.png)

You can find instructions for Chrome and Firefox in the [repo](https://github.com/clarkio/azure-mask). Below are the instructions for Edge:

### Enable developer mode

* Go back into the [extensions](edge://extensions/) screen.
* Enable developer mode

### Install from package zip

* Go to [Releases](https://github.com/clarkio/azure-mask/releases) and download the latest .zip file (e.g. az-mask-1.1.5.zip )
* Extract the zip into a folder
* Click on the **Load unpacked** icon
* Navigate to the folder with the zip's contents and click on **Select Folder**

![installed](/images/posts/2020-02-24-azmask-installed.png)

Click on **Details** if you want to have the extension only apply to certain sites, such as https://azure.portal.com.

There shouldn't be any need to enable the extension for InPrivate Browsing; just make use of additional profiles if you want to managed multiple cloud identities and take screenshots.

## Kudos

A big thanks to [Matt LeGrandeur](http://mattlag.com/about/) and [Brian Clark](https://www.clarkio.com/about/) for their great work in creating these extensions.
