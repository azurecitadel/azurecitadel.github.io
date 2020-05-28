---
title: "Creating custom RBAC role definitions using ARM Templates"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, RBAC, custom, ARM  ]
toc_depth: 3
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: Follow this guide if you need to create a custom RBAC role in Azure at the tenant level using an ARM Templates.
---

## Introduction

This guide will take the example role defined in the [CLI](../customRoleCLI) and deploy it using an ARM template deployed at the tenant level.

The custom role is called Resource Policy Operator, and it is a variant of the Resource Policy Contributor

* Full read/write/delete access to policy assignments
* Read only access to policy definitions
* Read and write access (no delete) for policy initiative definitions

It is assumed that you are already familiar with ARM templates.

## Background reading

* [RBAC](../rbac) overview
* [Custom role creation via CLI](../customRoleCLI)
* Deep dive into provider [operations](..operations)

These pages will help in understanding the construction of the custom permissions used in the template.

## Scope Deployments

You are unlikely to define a custom role at a resource group level. You will usually want to use one of the scoped deployment types for role definitions.

* [Tenant](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-to-tenant)
* [Management Group](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-to-management-group)
* [Subscription](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-to-subscription)

This page will create a custom role within the tenant so that it can be assigned at any management group, subscription or resource group scope.

### Additional deployment access

Deployments to higher scope points may have additional pre-requirements. For instance, for role definitions at tenant level deployments then you need to have an assignee with Owner role at root.

```bash
myObjectId=$(az ad signed-in-user show --query objectId --output tsv)
az role assignment create --assignee $myObjectId --scope "/" --role "Owner"
```

> You may need to [elevate](https://docs.microsoft.com/azure/role-based-access-control/elevate-access-global-admin) a Global A Administrator role to run the commands above. Also, allow the  role assignments time to propogate and refresh your credentials by logging off and back on again.

### Example tenant template

1. Create a file called ResourcePolicyOperator.azuredeploy.json

    ```json
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "variables": {
        "tenantId": "ce508eb3-7354-4fb6-9101-03b4b81f8c54",
        "roleName": "Resource Policy Operator",
        "description": "Allows the assignment of policies. Also the creation of policy initiatives.",
        "permissions": [
              {
                "actions": [
                  "*/read",
                  "Microsoft.Authorization/policyassignments/*",
                  "Microsoft.Authorization/policySetDefinitions/read",
                  "Microsoft.Authorization/policySetDefinitions/write",
                  "Microsoft.Authorization/policyDefinitions/read",
                  "Microsoft.PolicyInsights/*",
                  "Microsoft.Support/*"
                ]
              }
            ]
      },
      "resources": [
        {
          "comments": "Deploy using `az deployment tenant create --template-file <template.json>`",
          "name": "[guid(variables('tenantId'),variables('roleName'))]",
          "type": "Microsoft.Authorization/roleDefinitions",
          "apiVersion": "2018-01-01-preview",
          "properties": {
            "roleName": "[variables('roleName')]",
            "description": "[variables('description')]",
            "type": "CustomRole",
            "permissions": "[variables('permissions')]",
            "assignableScopes": [
              "[concat('/providers/Microsoft.Management/managementGroups/', variables('tenantId'))]"
            ]
          }
        }
      ]
    }
    ```

1. Customise the tenantId value to your tenantId (`az account show --query tenantId --output tsv`)

> You cannot use the `subscription().tenantId` function with tenant level deployments. There is no equivalent `tenant().id` function.

### Deploy the template

Deploying at the tenant root group is a different CLI command.

```bash
az deployment tenant create --template-file ResourcePolicyOperator.azuredeploy.json --location westeurope
```

Refer to the [Deploy To Tenant](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-to-tenant) page for information on other ways to deploy such as PowerShell or REST.

## Display the definition

1. List the role definition

    ```bash
    tenantId=$(az account show --output tsv --query tenantId)
    az role definition list --name "Resource Policy Operator" --scope /providers/Microsoft.Management/managementGroups/$tenantId
    ```

    Example output

    ```json
    [
      {
        "assignableScopes": [
          "/providers/Microsoft.Management/managementGroups/ce508eb3-7354-4fb6-9101-03b4b81f8c54"
        ],
        "description": "Allows the assignment of policies. Also the creation of policy initiatives.",
        "id": "/providers/Microsoft.Authorization/roleDefinitions/17fbb800-205f-5a1a-80cf-557faaf694a4",
        "name": "17fbb800-205f-5a1a-80cf-557faaf694a4",
        "permissions": [
          {
            "actions": [
              "*/read",
              "Microsoft.Authorization/policyassignments/*",
              "Microsoft.Authorization/policySetDefinitions/read",
              "Microsoft.Authorization/policySetDefinitions/write",
              "Microsoft.Authorization/policyDefinitions/read",
              "Microsoft.PolicyInsights/*",
              "Microsoft.Support/*"
            ],
            "dataActions": [],
            "notActions": [],
            "notDataActions": []
          }
        ],
        "roleName": "Resource Policy Operator",
        "roleType": "CustomRole",
        "type": "Microsoft.Authorization/roleDefinitions"
      }
    ]
    ```

> Note that the GUID used for the role definitions name and resourceId uses the `guid()` function with fixed seeds, and so the template should be idempotent. Using `newGuid()` as a parameter default would result in a new GUID being created if the template was redployed.

## Deleting the role

1. Delete the role using the CLI

    ```bash
    tenantId=$(az account show --output tsv --query tenantId)
    az role definition delete --name "Resource Policy Operator" --scope /providers/Microsoft.Management/managementGroups/$tenantId
    ```

## Navigation

[◄ RBAC](../rbac){: .btn .btn--inverse} [◄ Custom Role (CLI)](../customRoleCLI){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--primary} [Custom Roles (Terraform) ►](../customRoleTerraform){: .btn .btn--inverse}
