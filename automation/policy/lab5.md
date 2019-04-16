---
title: "Policies and Tagging"
date: 2019-03-25
author: [ "Richard Cheney" ]
category: automation
comments: true
featured: false
hidden: false
published: false
tags: [ policy, initiative, compliance, governance, tagging, tags ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "policy"
excerpt: Create an audit policy initiative to control tagging.
---

## Introduction

Tagging is important in a governed environment. In this lab we will create an initiative that uses audit against the following desired tags:

* Owner
* Department (from a list of allowed values)
* Application
* Environment (enforced to a specific value)
* Downtime (defaulting to Tuesday, 04:00-04:30)
* Costcode (must match a six digit format)

If a resource does not have any of these tags then we will create them.

Owner and application will get an empty value.  (We will also audit that they have a non-empty value so they get flagged up as non-compliant.) For the Costcode we'll be more precise and pattern match.

For Department we will have a specified list, and a default value that fails compliancy, forcing it to be changed to one of the others.

Environment will be enforced to a parameterised value that exists in the list of allowed values.

Downtime will get auto-created with a specified default value that may be overridden. This value could then be used by automation jobs.

## Inbuilt policies

We have the following BuiltIn policies to leverage.  You can browse the definitions in the Azure Portal, see the logic and copy out the GUID:

**GUID** | **Descriptions**
2a0e14a6-b0a6-4fab-991a-187a4f81c498 | Append a tag with a default value if it does not exist
1e30110a-5ceb-460c-a204-c1c3969c6d62 | Enforces that a tag has a specific value (uses deny)

You can also view a definition using `az policy definition show --name <GUID>`.

The resourceId for a BuiltIn policy is `/providers/Microsoft.Authorization/policyDefinitions/<GUID>`.

## Custom policies

There are more BuiltIn policies, but they use the deny effect.  We'll create a couple of Custom policies that use audit instead.

1. Create

[◄ Lab 4: Deploy](../lab4){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 6: Tagging ►](../lab6){: .btn .btn--primary}