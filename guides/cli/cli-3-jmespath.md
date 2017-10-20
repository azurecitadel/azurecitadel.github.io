---
layout: article
title: CLI 2.0 JMESPATH
date: 2017-10-04
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
previous: ./cli-2-firststeps
next: ./cli-4-scripting
---
WORK IN PROGRESS

{% include toc.html %}

## Introduction 

The ```--query``` switch is one of the "global" switches, i.e. it is available on every az command, and it enables you to query and filter the output of the command.  

It uses the industry standard JMESPATH query format that is used not only by the Azure CLI 2.0, but also the AWS CLI and other commands  that need to manipulate JSON. 

There is some excellent documentation on JMESPATH at the official site, and it covers the full range of what can be accomplished.  This guide will give you a shortcut into the commonly used functionality when querying Azure JSON output.  

## JSON Format

Here is some example JSON output from an ```az resource list --resource-group <resourceGroup> --output json``` command.  The example resource group (myAppRG-Staging) contains a single Web App in standard app service plan.

```
[
  {
    "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/serverFarms/MyAppServicePlan",
    "identity": null,
    "kind": "app",
    "location": "westeurope",
    "managedBy": null,
    "name": "MyAppServicePlan",
    "plan": null,
    "properties": null,
    "resourceGroup": "myAppRG-Staging",
    "sku": null,
    "tags": {
      "displayName": "myAppServicePlan"
    },
    "type": "Microsoft.Web/serverFarms"
  },
  {
    "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/sites/MyWebApp-richeney-Staging",
    "identity": null,
    "kind": "app",
    "location": "westeurope",
    "managedBy": null,
    "name": "MyWebApp-richeney-Staging",
    "plan": null,
    "properties": null,
    "resourceGroup": "myAppRG-Staging",
    "sku": null,
    "tags": {
      "displayName": "myWebApp",
      "hidden-related:/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/serverfarms/MyAppServicePlan": "Resource"
    },
    "type": "Microsoft.Web/sites"
  }
]
```

Whilst it may initially look complex, there are only keys, values, and objects.  The objects are split into two types:

1. Lists (or arrays), which are denoted by square brackets
   * Note that the resources output is a list, so the outer brackets are square
2. Key-value pairs    
