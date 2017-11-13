---
layout: article
title: CLI 2.0 First Steps
date: 2017-10-04
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
previous:
  url: ../cli-1-setup
  title: Installing and maintaining CLI 2.0
next:
  url: ../cli-3-jmespath
  title: Using JMESPATH queries
---
{% include toc.html %}

## Logging into Azure 

Log into Azure using ```az login```.  (Note that this is not necessary in Cloud Shell.) 

You will be prompted to enter a code into  [http://aka.ms/devicelogin](http://aka.ms/devicelogin) and then authenticate the session.  

Note: Most terminals support copy and paste with either the right mouse button, or CTRL-INS / SHIFT-INS.  For instance, in the Windows Bash shell you can double click the code to select it then right click to copy.

The session tokens survive for a number of days so if you are using a shared machine then always issue ```az logout``` at the end of your session.

See below if you have multiple Azure IDs and/or subscriptions.

## Help  

* ```az``` shows the main help and list of the commands
* ```az <command> --help``` shows help for that command
  * if there are subcommands then you can use the ```--help``` or ```-h``` at any level
* ```az find -q <str>``` will search the index for commands containing ```<str>```
  * e.g. ```az find -q image``` 
* the [CLI 2.0 reference](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) has a description of the available commands and parameters 
* most of the [Azure documentation](https://docs.microsoft.com/en-us/azure/#pivot=products&panel=all) sections have examples and tutorials for CLI 2.0 alongside the Portal and PowerShell

## Configure  

* ```az configure``` initiates an interactive session to configure defaults for your output format, logging of sessions, data collection.  
* ```az configure --default group=myRG location=westeurope```
  * enables the setting of default values for common command switches such as the Resource Group or Azure Region
  * uses space delimited key=value pairs
  * defaults may be unset by a blank string, e.g. ```group=''```

## Output Formats

At this point I will assume that you have some resource groups, and that some of those contain virtual machines.

The following command lists out your resource groups, each demonstrating the output formats available

**Command** | **Output**
```az group list --output json``` | JSON output (default)
```az group list --output table``` | Human readable table
```az group list --output jsonc``` | Coloured JSON output (includes control characters)
```az group list --output tsv``` | Tab seperated values

Any scripting should *always* specify the output format as CLI 2.0 users can use the ```az configure``` command to set their preferred default output format. 

A couple of points of note
* The JSON output contains the most information about the resources
* The table output shows a header.  The columns (and the header name) can be customised using JMESPATH queries.  More on those later.
* The tsv output has more information than the table, but no headers. As it does not include quotes around the values, it makes it a good way of reading values into Bash variables, working well with the cut command in a pipeline.  Again, for scripting I would highly recommend using the ``--query`` to specify the columns.

## Multiple Subscriptions

If you have multiple subscriptions then the CLI 2.0 will work in the context of the active subscription.

**Command** | **Output**
```az account list ``` | LIst the available subscriptions
```az account show ``` | Show the active subscription
```az account set --subscription <subscriptionName> ``` | Switch to the named subscription

CLI 2.0 includes tab auto-complete for both switches and values, which is very useful for auto-completing resource groups, resource names and long subscription descriptions.

If you have multiple subscriptions linked to different IDs then browser cache and cookies can cause issues.  If that occurs then start an InPrivate or Incognito window and authenticate within that.

