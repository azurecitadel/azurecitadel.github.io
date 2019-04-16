---
title: "Use a simple policy to stipulate the permitted regions"
date: 2019-03-25
author: [ "Tom Wilde" ]
category:
comments: true
featured: false
hidden: true
published: true
tags: [ policy, initiative, compliance, governance ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "policy"
excerpt: Use a simple policy to stipulate the permitted regions
---

## Introduction

Most organizations don't want users creating Azure resources in any region. In this lab we'll specify that resources can only be created in the UK.

## Using Policy from the portal

1. Open the [Azure Portal](https://portal.azure.com) and create a resource group called PolicyLab

1. Launch Azure Policy

    You may also want to favourite it by selecting All Services, searching for Policy and clicking the star

1. Select Definitions on the left side of the Azure Policy page

    Definitions are effectively the restriction you want to impose. You can use the built in policies, duplicate and edit them, or create your own from various templates like those on [GitHub](https://github.com/Azure/azure-policy)

1. In the search text box, type "location" and open up the "Allowed Locations" definition

    ![Policy Definition](/automation/policy/images/lab1-policydefinition.png)
**Figure 1:** Policy Definition

    You can see the definition is a JSON file that needs a list of allowed locations and will cause a deny. You could duplicate this definition and add more checks if needed but we'll just assign it.

1. Clicking Assign

    ![Policy Definition-Allowed Locations](/automation/policy/images/lab1-policydefinition-allowedlocations.png)
**Figure 2:** Policy Definition - Allowed Locations

    For more details on the policy definition structure see [here](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure).

1. When assigning a policy, we first have to choose the scope, at either:

    - [Management Group](https://docs.microsoft.com/en-us/azure/governance/management-groups/)
    - Subscription
    - Resource Group

    You can think of management groups as a folder hierarchy where subscriptions can be organised.

    ![Management Groups example](/automation/policy/images/lab1-managementgroups.png)
**Figure 3:** Management Group

    The scope chosen will take effect on all child resources below it, but you can add exclusions if needed.

1. In the Basics section you can change the assignment name and add a description

    Description are definitely recommended when you have a lot of policies.

1. In the Parameters section choose the allowed locations of UK South and UK West

    As this is a Deny policy there is no need for Managed Identity and we'll get in to that in a later lab.

1. Click Assign.

    ![Policy Definition-Allowed Locations](/automation/policy/images/lab1-policydefinition-allowedlocations-assign.png)
**Figure 4:** Assigning Allowed Locations Definition

## Testing the Deny policy

1. Now test creating a resource in the PolicyLab resource group with a location outside the UK

    ![Policy Test-Portal](/automation/policy/images/lab1-policytest-portal.png)
**Figure 5:** VM deployment failure to non-UK location

1. Now test creating a resource in the PolicyLab resource group with a location inside the UK and the resource should be deployed as normal

    ![Policy Test-Portal](/automation/policy/images/lab1-policytest-portal-success.png)
**Figure 7:** VM deployment success to UK location

## Finishing up

That concludes this lab, where we've learnt about applying a policy from the Azure portal. The resources you've created will be used in the next lab so don't delete them yet.

Next we'll tackle another common requirement, specifying which VM SKUs are allowed to be deployed. We’ll start to automate policy creation too.

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: Audit ►](../lab2){: .btn .btn--primary}
