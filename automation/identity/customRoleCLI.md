---
title: "Creating custom RBAC role definitions using the CLI"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, RBAC, custom, CLI ]
toc_depth: 3
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: Follow this guide if you need to create a custom RBAC role in Azure.
---

## Introduction

There are well over 150 [built in RBAC roles](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles) in Azure that cover the most requested role requirements. You can also assign multiple role assignments to your security principals as RBAC uses an additive model for the permissions.

For the vast majority of Azure users the built in roles are more than sufficient for everyday use, and there will have no need to create any custom RBAC role.

If, however, your business requirements demand a very surgical role that does not exist then you can create your own.

This guide will go through an example role creation using the CLI.

## Background reading

Please read the [RBAC](../rbac) guide before running through this.

We will also make use of some commands to list out the operators. As optional reading you can look at the [operations](..operations) page which goes into greater detail.

## Scenario

In the scenario there is a central team, with an AAD group called Cloud Architects. Part of their role is to define cloud standards, including the creation and testing of custom policies and default policy initiatives for use by the rest of the business. They use the [Resource Policy Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#resource-policy-contributor) role to assign those permissions.

Another AAD group, Cloud Operators, will need to be able to assign policy initiatives.

They will also be allowed to add policy initiatives, but can only include existing custom policies or built in policies. They should not be able to create new custom policies themselves. And they will not be allowed to delete any policies or initiatives.

They will have a number of other built in roles assigned to them, but need a custom role purely for the policy initiatives and policy assignments.

## Listing out existing roles

1. List out the role definition for Resource Policy Contributor:

    ```bash
    az role definition list --name "Resource Policy Contributor" --output jsonc
    ```

    Output:

    ```json
    [
      {
        "assignableScopes": [
          "/"
        ],
        "description": "Users with rights to create/modify resource policy, create support ticket and read resources/hierarchy.",
        "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/providers/Microsoft.Authorization/roleDefinitions/36243c78-bf99-498c-9df9-86d9f8d28608",
        "name": "36243c78-bf99-498c-9df9-86d9f8d28608",
        "permissions": [
          {
            "actions": [
              "*/read",
              "Microsoft.Authorization/policyassignments/*",
              "Microsoft.Authorization/policydefinitions/*",
              "Microsoft.Authorization/policysetdefinitions/*",
              "Microsoft.PolicyInsights/*",
              "Microsoft.Support/*"
            ],
            "dataActions": [],
            "notActions": [],
            "notDataActions": []
          }
        ],
        "roleName": "Resource Policy Contributor",
        "roleType": "BuiltInRole",
        "type": "Microsoft.Authorization/roleDefinitions"
      }
    ]
    ```

> Note that policy sets were the original names for policy initiatives.

## Listing the operations for a namespace

1. Create a table of the available Microsoft.Authorization actions, showing the actions and dataActions

    ```bash
    az provider operation show --namespace Microsoft.Authorization --query 'resourceTypes[].operations[]|[].{dataAction:isDataAction, action:name}' --output table
    ```

    Output:

    ```text
    DataAction    Action
    ------------  --------------------------------------------------------------------
    False         Microsoft.Authorization/classicAdministrators/read
    False         Microsoft.Authorization/classicAdministrators/write
    False         Microsoft.Authorization/classicAdministrators/delete
    False         Microsoft.Authorization/roleAssignments/read
    False         Microsoft.Authorization/roleAssignments/write
    False         Microsoft.Authorization/roleAssignments/delete
    False         Microsoft.Authorization/permissions/read
    False         Microsoft.Authorization/locks/read
    False         Microsoft.Authorization/locks/write
    False         Microsoft.Authorization/locks/delete
    False         Microsoft.Authorization/roleDefinitions/read
    False         Microsoft.Authorization/roleDefinitions/write
    False         Microsoft.Authorization/roleDefinitions/delete
    False         Microsoft.Authorization/providerOperations/read
    False         Microsoft.Authorization/policySetDefinitions/read
    False         Microsoft.Authorization/policySetDefinitions/write
    False         Microsoft.Authorization/policySetDefinitions/delete
    False         Microsoft.Authorization/policyDefinitions/read
    False         Microsoft.Authorization/policyDefinitions/write
    False         Microsoft.Authorization/policyDefinitions/delete
    False         Microsoft.Authorization/policyAssignments/read
    False         Microsoft.Authorization/policyAssignments/write
    False         Microsoft.Authorization/policyAssignments/delete
    False         Microsoft.Authorization/operations/read
    False         Microsoft.Authorization/classicAdministrators/operationstatuses/read
    False         Microsoft.Authorization/denyAssignments/read
    False         Microsoft.Authorization/denyAssignments/write
    False         Microsoft.Authorization/denyAssignments/delete
    False         Microsoft.Authorization/policies/audit/action
    False         Microsoft.Authorization/policies/auditIfNotExists/action
    False         Microsoft.Authorization/policies/deny/action
    False         Microsoft.Authorization/policies/deployIfNotExists/action
    ```

1. List the names for those actions that contain policy in the name

    ```bash
    az provider operation show --namespace Microsoft.Authorization --query 'resourceTypes[?contains(name, `policy`)].operations[]|[? !isDataAction].name' --output json
    ```

    Output:

    ```text
    [
      "Microsoft.Authorization/policySetDefinitions/read",
      "Microsoft.Authorization/policySetDefinitions/write",
      "Microsoft.Authorization/policySetDefinitions/delete",
      "Microsoft.Authorization/policyDefinitions/read",
      "Microsoft.Authorization/policyDefinitions/write",
      "Microsoft.Authorization/policyDefinitions/delete",
      "Microsoft.Authorization/policyAssignments/read",
      "Microsoft.Authorization/policyAssignments/write",
      "Microsoft.Authorization/policyAssignments/delete"
    ]
    ```

> If you want to go a little deeper with the various operations within a particular provider namespace then see the [operations](../operations) page. It covers actions and notActions as well as the split between the management plane and the data plane operations.

## Creating the custom role definition JSON

1. Open Visual Studio Code
    * If vscode opens an existing folder then use File -> Close Folder (or the `CTRL`+`K`, `F` chord)
1. Paste the following template into the untitled file

    ```json
    {
        "Name":  "My Custom Role",
        "IsCustom":  true,
        "Description":  "Description for the role.",
        "Actions":  [],
        "NotActions":  [],
        "DataActions": [],
        "NotDataActions": [],
        "AssignableScopes":  [
          "/providers/Microsoft.Management/managementGroups/myTenantId"
        ]
    }
    ```

1. Save as ResourcePolicyOperator.json
    * Once saved then the syntax highlighting for JSON files should begin automatically
    * You can also use `SHIFT`+`ALT`+`F` to auto format
1. Customise the name and the description
1. Customise the assignable scopes to include your tenantId
    * Display your tenantId using `az account show --query tenantId --output tsv`

1. Add the actions from the Resource Policy Contributor role
1. Remove the policy definition and policy set definition actions containing the wildcards
    * These need to be more specific to meet the requirements
1. Add the possible individual operations for definitions
    * Copy the individual policy definition operations from the Microsoft.Authorization namespace
    * Most terminals support `ALT` and mouse click and drag to highlight text in column mode
    * Paste into the actions array
1. Delete the actions that should not be assigned
1. Use `CTRL`+`SHIFT`+`M` to show any syntactical errors
1. Auto-format
1. Save the file (`CTRL`+`S`)

Your file should look similar to this one: [ResourcePolicyOperator.json](/automation/identity/ResourcePolicyOperator.json).

> You don't need the `Microsoft.Authorization/policyDefinitions/read` action as this is covered by the `*/read` action, but it doesn't hurt to include it for clarity.

## Create the custom role definition

1. Create the role

    ```bash
    az role definition create --role-definition ResourcePolicyOperator.json
    ```

    Output:

    ```json
    {
      "assignableScopes": [
        "/providers/Microsoft.Management/managementGroups/ce508eb3-7354-4fb6-9101-03b4b81f8c54"
      ],
      "description": "Allows the assignment of policies. Also the creation of policy initiatives.",
      "id": "/providers/Microsoft.Authorization/roleDefinitions/ceb6e086-fc70-4b05-a6bf-823d0b53ba5f",
      "name": "ceb6e086-fc70-4b05-a6bf-823d0b53ba5f",
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
    ```

    Note the name and the ID as you can use these in your RBAC role assignments.

    The scope in the assignable scope defines the role at the Root Tenant Group so that it can be used in all of the subscriptions.

    The assignable scopes can include any management group or subscription scope. If you do not have writes to create roles at management group level then you can test the creation at a subscription scope, i.e. `/subscriptions/{subscriptionId}`.

## Remove the custom role

1. Delete the role

    ```bash
    scope="/providers/Microsoft.Management/managementGroups/$(az account show --output tsv --query tenantId)"
    az role definition delete --scope $scope --name "Resource Policy Operator"
    ```

## Additional pages

If you want to know how to deploy the example role at the root tenant group using infrastructure as code then refer to the following:

* [Custom RBAC Role via Terraform](../customRoleTerraform)
* [Custom RBAC Role via ARM Template](../customRoleArmTemplate)

## Finishing Up

You can now create custom role definitions to meet requirements that cannot be satisfied by using combinations of the built in roles.

It can be tempting to create composite roles that includes the additive actions from a number of built in roles, or to effectively add a few additional actions to another role.

I would personally take advantage of the additive nature of multiple role assignments, and keep them separate. Create specific roles that are well defined and well described. Assign those custom roles in addition to standard built in roles.

As services are added and evolve then the built in roles will be updated, and so this approach is more supportable over the long term.

[◄ RBAC](../rbac){: .btn .btn--inverse} [◄ Service Principals](../servicePrincipals){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--primary}
