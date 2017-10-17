---
layout: article
title: CLI 2.0 First Steps
date: 2017-10-04
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
previous: ./cli-1-setup
next: ./cli-3-jmespath
---
WORK IN PROGRESS

{% include toc.html %}

## Logging into Azure 

Log into Azure using ```az login```.  

You will be prompted to enter a code into the [http://aka.ms/devicelogin](http://aka.ms/devicelogin) and then authenticate the session.  The session tokens survive for a number of days so if you are using a shared machine then always issue ```az logout``` at the end of your session.

If you have multiple subscriptions linked to different IDs then browser cache and cookies can cause issues.  If that occurs then start an InPrivate or Incognito window and authenticate within that.

Note: Most terminals support copy (of selected text) and paste with either the right mouse button, or CTRL-INS / SHIFT-INS.  For instance, in the Windows Bash shell you can double click the code to select it then right click to copy.

## Orientation  

* ```az``` shows the main help and list of the commands
* ```az <command> --help``` shows help for that command
  * if there are subcommands then you can use the ```--help``` or ```-h``` at any level
  * the [CLI 2.0 reference](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) has a description of the available commands and parameters 
* ```az configure``` initiates an interactive session to configure defaults for your output format, logging of sessions, data collection.  
* ```az configure --default group=myRG location=westeurope```
  * enables the setting of default values for common command switches such as the Resource Group or Azure Region
  * uses space delimited key=value pairs
  * defaults may be unset by a blank string, e.g. ```group=''```
* the az CLI includes auto-complete

## Simple Commands

At this point I will assume that you have some resource groups, and that some of those contain virtual machines.

For the moment, use ```az configure``` to set your default output type as table.  Or you can ensure either ```--output table``` or ```-otable``` is included in the command.

**Command** | **Output**
```az group list``` | Lists all resource groups for the subscription
```az group list``` | As above


