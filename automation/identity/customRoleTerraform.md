---
title: "Creating custom RBAC role definitions using Terraform"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, RBAC, custom, Terraform ]
toc_depth: 3
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: Follow this guide if you need to create a custom RBAC role in Azure.
---

## Introduction

This guide will take the example role defined in the [CLI](../customRoleCLI) and deploy it using an ARM template deployed at the tenant level.

The custom role is called Resource Policy Operator, and it is a variant of the Resource Policy Contributor

* Full read/write/delete access to policy assignments
* Read only access to policy definitions
* Read and write access (no delete) for policy initiative definitions

It is assumed that you are already familiar with using Terraform on Azure.

## Background reading

* [RBAC](../rbac) overview
* [Custom role creation via CLI](../customRoleCLI)
* Deep dive into provider [operations](..operations)

These pages will help in understanding the construction of the custom permissions used in the template.

## Terraform

Here is some example HCL for configuring the Resource Policy Operator custom role as per the [azurerm_role_definition](https://www.terraform.io/docs/providers/azurerm/r/role_definition.html) docs.

```terraform
data "azurerm_subscription" "custom_role" {}

resource "azurerm_role_definition" "resource_policy_operator" {
  name        = "Resource Policy Operator"
  scope       = "/providers/Microsoft.Authorization/roleDefinitions/${data.azurerm_subscription.custom_role.tenant_id}"
  description = "Allows the assignment of policies. Also the creation of policy initiatives."

  permissions {
    actions     = [
      "*/read",
      "Microsoft.Authorization/policyassignments/*",
      "Microsoft.Authorization/policySetDefinitions/read",
      "Microsoft.Authorization/policySetDefinitions/write",
      "Microsoft.Authorization/policyDefinitions/read",
      "Microsoft.PolicyInsights/*",
      "Microsoft.Support/*"
    ]
  }

  assignable_scopes = [
    "/providers/Microsoft.Management/managementGroups/${data.azurerm_subscription.primary.tenant_id}"
  ]
}
```

> Note that Terraform currently creates the role definition within the current subscription rather than at the Tenant Root Group, but it does not seem to affect where is can be assigned.

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

[◄ RBAC](../rbac){: .btn .btn--inverse} [◄ Custom Role (CLI)](../customRoleCLI){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--primary} [Custom Roles (ARM Template) ►](../customRoleArmTemplate){: .btn .btn--inverse}
