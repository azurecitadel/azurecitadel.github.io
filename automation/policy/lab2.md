---
title: "Using Audit"
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
excerpt: Specify allowed VM SKU sizes using Azure CLI.
---
## Introduction

Most organizations want to give users freedom to create resources within Azure, but want to avoid users creating certain types of resources as some can be very expensive. In this lab we'll specify which virtual machines a user is allowed to create and we'll use Azure CLI to do so.

## Registering the Policy provider

1. As we're working in Azure CLI, we first we need to check that the policy resource provider is registered:

    ```bash
    az provider show --namespace Microsoft.PolicyInsights --query registrationState --output tsv
    ```

    If not then register:

    ```bash
    az provider register --namespace Microsoft.PolicyInsights
    ```

## Viewing policy definitions and assignments

1. Let's have a look at the current assignments through cli. We should be able to see the work we did in the previous lab.

    View current assignments

    ```bash
    az policy assignment list -o jsonc
    ```

    No results? The default scope on the above command is on the subscription you're logged into, so you cannot see the assignments with scopes of management groups or resource groups without specifying it. To see all assignments you must disable the scope match

    ```bash
    az policy assignment list --disable-scope-strict-match -o jsonc
    ```

1. Let's see if there are any built in definitions to restrict which VM SKUs can be used:

    To view all definitions:

    ```bash
    az policy definition list -o table
    ```

    Or to search for an existing definition containing "virtual machine":

    ```bash
    az policy definition list --query "[?contains(displayName, 'virtual machine')]" -o table
    ```

    Notice the name column is a GUID (and remains the same across all tenants), and we can use the GUID in the next query to view the json of this policy definition.

    ```bash
    az policy definition show -n cccc23c7-8427-4f53-ad12-b6a63eb452b3 -o jsonc
    ```

    ```json
      {
      "description": "This policy enables you to specify a set of virtual machine SKUs that your organization can deploy.",
      "displayName": "Allowed virtual machine SKUs",
      "id": "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3",
      "metadata": {
        "category": "Compute"
      },
      "mode": "Indexed",
      "name": "cccc23c7-8427-4f53-ad12-b6a63eb452b3",
      "parameters": {
        "listOfAllowedSKUs": {
          "metadata": {
            "description": "The list of SKUs that can be specified for virtual machines.",
            "displayName": "Allowed SKUs",
            "strongType": "VMSKUs"
          },
          "type": "Array"
        }
      },
      "policyRule": {
        "if": {
          "allOf": [
            {
              "equals": "Microsoft.Compute/virtualMachines",
              "field": "type"
            },
            {
              "not": {
                "field": "Microsoft.Compute/virtualMachines/sku.name",
                "in": "[parameters('listOfAllowedSKUs')]"
              }
            }
          ]
        },
        "then": {
          "effect": "Deny"
        }
      },
      "policyType": "BuiltIn",
      "type": "Microsoft.Authorization/policyDefinitions"
    }
    ```

## Assign an inbuilt policy

1. Now we know the policy name, what it does, what it needs so we can assign it.

    ```bash
    # Set the definition
    definition=cccc23c7-8427-4f53-ad12-b6a63eb452b3

    # Set the scope to the PolicyLab resource group used in Lab1
    scope=$(az group show --name 'PolicyLab' --output tsv --query id)

    # Set the Policy Parameter (JSON format)
    policyparam='{ "listOfAllowedSKUs": { "value": ["Standard_D2s_v3", "Standard_D4s_v3", "Standard_DS1_v2", "Standard_DS2_v2"]}}'

    # Create the Policy Assignment
    az policy assignment create --name 'Allowed Virtual Machine SKUs' --display-name 'Allowed Virtual Machine SKUs' --scope $scope --policy $definition --params "$policyparam" --output jsonc
    ```

## Test the policy

1. Now let's test

    Using a Standard_B1s should fail

    ```bash
    az vm create -n Lab2VM -g PolicyLab --image UbuntuLTS --admin-username policyuser --size Standard_B1s
    ```

    Using a Standard_D2s_v3 should succeed

    ```bash
    az vm create -n Lab2VM -g PolicyLab --image UbuntuLTS --admin-username policyuser --size Standard_D2s_v3
    ```

    ![Policy Definition](/automation/policy/images/lab2-policytest.png)
**Figure 1:** Policy Test

## Finishing up

That concludes this lab, where we've learnt about applying an inbuilt policy using the Azure CLI. The resources you've created will be used in the next lab so don't delete them yet.

Next we'll group policies together using an initiative and use automatic remediation.

[◄ Lab 1: Deny](../lab1){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 3: Initiatives ►](../lab3){: .btn .btn--primary}