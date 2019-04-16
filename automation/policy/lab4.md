---
title: "Creating custom policies and initiatives"
date: 2019-03-25
author: [ "Richard Cheney" ]
category:
comments: true
featured: false
hidden: false
published: true
tags: [ policy, initiative, compliance, governance ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "policy"
excerpt: Create your own custom Deny initiative
---

## Introduction

Policies and initiatives are great for introducing a layer of governance onto subscriptions, and experience has shown that there is a sensible approach to take.

1. **Create a Deny initiative for regions, names, resource provider types and SKUs**

    The aim of a Deny initiative is to prevent the incorrect creation of resources that would be painful to fix.

    Regions is an obvious one.  If deployments should only be allowed to a region or two, then use a deny policy.  It is difficult to move many resource types and many require deletion and recreation.

    Cost management is another reason.  You can avoid the creation of expensive resource types or SKUs by constraining the options.

    As you already know, the names of resource groups and resources form part of the resourceId within Azure.  Therefore you cannot rename them.  For resource groups you have to create a new one with the desired name and then move the resources. For resources it is an disruptive change, forcing a delete and recreate. Enforcing a naming convention with a deny policy can avoid that situation.

    Using a deny initiative is very effective for these.  For other types of policies then it can be overkill and cause friction.  For example, if you were to enforce tagging with a deny effect in your policy definition then you would prevent users from creating certain resources types within the Azure portal. (Only some resource types support tag definitions in the create screens.)

1. **Use the Audit effect for desired configurations and check compliancy within Azure Policy.**

    If you want a softer impact then use the audit policy and then you can use that to flag up those that don't meet the policy.

    Tagging is a great example for this and will be used later in the set of labs.  It is good practice to have a default set of tags created for each resource (and possibly resource group).  You can then slice and dice the billing using the tagging, find out who is the application owner, which resources are naturally related, or establish values which can then be used in automation around downtime, or switching on and off resources to get benefit from cloud's utility computing models.

    Using Audit means that those resources can still be deployed, and you can be nice in auto-creating tags, defaulting values etc., and then use the compliancy reporting in Azure Policy to correct non-compliant resources.  In certain circumstances (e.g. where resources are deployed purely through CI/CD) then you may want to switch from Audit to Deny.

1. **Leverage the DeployIfNotExists inbuilt initiatives**

    The new initiatives are perfect for ensuring that standard agents are auto-installed for both newly instantiated resources and for those that are migrated into the environment.

In this lab we will address the first area, and show how to create and then update an example Deny initiative.  We'll create it initially with constraints for geography and VM SKUs and assign it.  Then we'll create a simple custom policy for resource naming, add it to the initiative json and then update the initiative definition.

We will also start using management groups to get an understanding of where to define policies and initiatives, and where to assign them.

In later labs we will translate this deny initiative into both a subscription level ARM template and a Terraform module.

## Create a Custom Policy Initiative

1. Set your defaults

    We'll avoid lengthy commands by defaulting the `--resource-group` and `--location` switches.  We'll also be re-using the PolicyLab resource group.  )

    ```bash
    az configure --defaults group=PolicyLab location=uksouth
    az group create --name PolicyLab
    ```

    (Personally I always configure the CLI output to jsonc using `az configure`, but choose whichever you prefer. You can choose from the  default table or switch to the more detailed json or yaml outputs.  The tsv output is usually used in scripts, combined with the [JMESPATH](/prereqs/cli/cli-3-jmespath/) queries.)

1. Create a new subdirectory called policy

    ```bash
    mkdir -m 755 policies
    ```

1. Create a new file within it called deny.initiative.json

    We'll start by using a couple of standard BuiltIn policies for restricting the regions and VM SKUs.

    ```json
    [
        {
            "comment": "Permitted regions",
            "parameters": {
                "regions": {
                    "value": [
                        "UK South",
                        "UK West"
                    ]
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
        },
        {
            "comment": "Permitted VM SKUs. Non-compliant SKUs will be denied.",
            "parameters": {
                "listOfAllowedSKUs": {
                    "value": [
                        "Standard_B1ms",
                        "Standard_B1s",
                        "Standard_B2ms",
                        "Standard_B2s",
                        "Standard_B4ms",
                        "Standard_D2_v3",
                        "Standard_D2s_v3"
                    ]
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"
        }
    ]
    ```

    This is a hardcoded initiative using two inbuilt policies. It is a simple array showing the definition IDs for the inbuilt policies as well as the parameter values required. The comment field will be ignored by the next command and is useful to describe the policy effect for that initiative element.

1. Create the initiative definition

    ```bash
    az policy set-definition create --name deny --display-name "Standard set of deny policies" --description "Limit regions and VM SKUs" --definitions policies/deny.initiative.definition.json --output jsonc
    ```

1. Assign to the resource group

    ```bash
    az policy assignment create --resource-group PolicyLab --name deny --display-name "Standard Deny Policies" --policy-set-definition deny
    ```

    The `--resource-group` switch is shown explicitly as it is the scope at which the policy is assigned.  Later we will assign it at a higher scope level once it has been tested successfully, and we will use the `--scope` switch instead.

1. List assignments

    List out the policy assignments solely at the resource group:

    ```bash
    az policy assignment list --resource-group PolicyLab
    ```

    And again, showing both those assigned at that scope and those inherited from higher in the hierarchy (i.e. any assignments at management group or subscription level):

    ```bash
    az policy assignment list --resource-group PolicyLab --disable-scope-strict-match
    ```

1. Test

    Create resources within the PolicyLab resource group that either meet or violate the criteria in the policy definitions to test whether they will be denied deployment.

    Confirm that the policy initiative is working as intended.

## Working with Management Groups

Note that your ability to work through this section will depend on your role within your subscription and within the associated tenancy.

If you are Global Admin within a tenancy then you can elevate your permissions to gain access to the default Management Group, known as the Tenant Root Group. (Once the Global Admin has been elevated then they can assign individual users or group(s) the [Management Group Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#management-group-contributor) role at that scope.)  If the elevation succeeds then you can now manage Management Groups.  If not then you will have to continue working with the subscription and resource group levels and you are free to skip to the next [section](#updating-an-existing-policy-initiative).

1. Elevate the Global Admin

    Go into the [AAD Portal](https://aad.portal.azure.com), into the Azure Active Directory service and then Properties within the Manage section. Toggle the "Access management for Azure resources" to Yes.

1. List out your management groups

    ```bash
    az account management-group list --output jsonc
    ```

    Assuming you haven't created any new management groups then the output will be similar to this:

    ```json
    [
        {
            "displayName": "Tenant Root Group",
            "id": "/providers/Microsoft.Management/managementGroups/f246eeb7-b820-4971-a083-9e100e084ed0",
            "name": "f246eeb7-b820-4971-a083-9e100e084ed0",
            "tenantId": "f246eeb7-b820-4971-a083-9e100e084ed0",
            "type": "/providers/Microsoft.Management/managementGroups"
        }
    ]
    ```

    Note that the resourceId format deviates from the normal format as Management Groups sit outside of the individual subscriptions. One other difference is that there is a name and a displayName, so you can rename a Management Group. The name for the Tenant Root Group is the same as the tenantId.

1. Set tenantId and rootId

    Use these commands to set a couple of variables so we can refer to them later:

    ```bash
    tenantId=$(az account show --output tsv --query tenantId)
    rootId=$(az account management-group show --name $tenantId --output tsv --query id)
    rootId=/providers/Microsoft.Management/managementGroups/$tenantId
    ```

    The last two commands are interchangeable as they'll set rootId to the same value.

1. Create new management groups

    You can use either a GUID or a number for a management group's name.

    ```bash
    az account management-group --name 200 --display-name "Non-Prod"
    az account management-group --name 230 --display-name "Dev" --parent 200
    ```

    The `--parent` switch defaults to the Tenant Root Group. The resourceId for the Dev management group will be:

    ```text
    /providers/Microsoft.Management/managementgroups/230
    ```

1. See the current policy initiative definition level

    When you created the policy initiative, it was created at the default scope level, which is subscription.  Run the following command:

    ```bash
    az policy set-definition show --name deny --output tsv --query id
    ```

    The output should be similar to:

    ```text
    /subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62/providers/Microsoft.Authorization/policySetDefinitions/deny
    ```

    We then assigned the policy initiative to the resource group, which is within that subscription. You can only assign policies and initiatives which are defined either at that level or at a higher scope.

1. Delete the test versions of the policy initiative assignment and definition

    Remove the assignment at the resource group level, and then the definition

    ```bash
    az policy assignment delete --name deny
    az policy set-definition delete --name deny
    ```

1. Recreate the initiative at the Non-Prod level

    ```bash
    az policy set-definition create --name nonProdDeny --display-name "Standard set of deny policies" --description "Limit regions and VM SKUs" --definitions policies/deny.initiative.definition.json --management-group 200 --output jsonc
    ```

    The resourceId for the policy initiative definition will be very different to the previous one, as it is now based on the management group Id and the provider type:

    ```text
    /providers/Microsoft.Management/managementgroups/200/providers/Microsoft.Authorization/policySetDefinitions/nonProdDeny
    ```

    OK, we should now be able to assign it at any level from Non-Prod downwards.

1. Assign the initiative at the Non-Prod level

    ```bash
    devMg=/providers/Microsoft.Management/managementgroups/200
    policySetId=/providers/Microsoft.Management/managementgroups/200/providers/Microsoft.Authorization/policySetDefinitions/nonProdDeny
    az policy assignment create --name "nonProdDeny" --display-name "Standard deny for non-prod" --policy-set-definition $policySetId --scope $devMg
    ```

    > Remember that you can only assign policies and initiatives at the same level or lower than the scope at which the definition was created.

1. Move your subscription under the new management group

    > Note that you can always move it back to the root later

    ```bash
    subscriptionId=$(az account show --output tsv --query id)
    az account management-group subscription add --name 230 --subscription $subscriptionId
    ```

    The subscription will now inherit the policies within the initiative from the management groups.

    > Note that new subscriptions will be created within the Tenant Root Group.  As soon as you move a subscription under a management group then it will inherit any assigned policies from all of the levels above.

## Updating an existing policy initiative

OK, time to add custom policies to the initiative. We'll ensure that we have a standard naming convention enforced, as any resource named incorrectly would have to be deleted and recreated.

The creation of custom policy rules is currently a little bit of a dark art at the moment.  The product group is aware of this and is looking for ways to make the process simpler.

In the meantime, be familiar with the available logical operators, conditions and fields within the [Azure Policy definition structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#policy-rule).  You will also find some good examples of policies that others have defined, including the Microsoft GitHub repo for [Azure Policy samples](https://github.com/Azure/azure-policy/tree/master/samples), from or from individual contributors such as [Richard Green](https://github.com/richardjgreen/azure-resource-policy-templates).

For naming you can use either the **match** conditional, which will match against standard patterns.  You can use either *#* for a number or *?* for a letter.  Using **like** allows for the use of _\*_ wildcards.

Let's create a simple global naming format based on the [sample](https://docs.microsoft.com/en-us/azure/governance/policy/samples/enforce-like-pattern), allowing a simple parameter to be passed in.

1. Create policy/naming.global.rules.json:

    ```json
    {
        "if": {
            "not": {
                "field": "name",
                "like": "[parameters('namePattern')]"
            }
        },
        "then": {
            "effect": "deny"
        }
    }
    ```

1. And then a policy/naming.global.parameters.json

    ```json
    {
        "namePattern": {
        "type": "String",
        "metadata": {
            "description": "Pattern to use for names. Can include wildcard (*)."
            }
        }
    }
    ```

1. Create the policy definition at the Tenant Root Group level:

    ```bash
    az policy definition create --name 'global-naming-convention' --display-name 'Global naming convention' --description 'Ensure resource names meet the like condition for a pattern.' --rules policies/naming.global.rule.json --params policies/naming.global.parameters.json --mode All --management-group $tenantId --query id --output tsv

    ```

    The `--management-group` switch is really important here.  By default the command defines policies at the subscription level, i.e.:

    ```text
    /subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62/providers/Microsoft.Authorization/policyDefinitions/global-naming-convention
    ```

    With the `--management-group` switch then the policy will be defined at:

    ```text
    /providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/global-naming-convention
    ```

    Also note the use of the `--mode All` switch as this policy can apply to resources that do not have a region and/or do not have tags.

1. Add the following to the end of the array in your deny.initiative.definition.json:

    ```json
    {
        "comment": "Naming: uk[sw]-[dtup]-<resourcetype>-<resourcename>01, where [dtup] is dev/test/UAT/production, e.g. uks-p-vm-citadeldb01",
        "parameters": {
            "namePattern": {
                "value": "uk?-?-??-?*?##"
            }
        },
        "policyDefinitionId": "/subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62/providers/Microsoft.Authorization/policyDefinitions/global-naming-convention"
    }
    ```

    This is a simple naming convention and there is no real enforcement of the desired naming in the comment field.  Check out later labs for examples of using multiple policies within initiatives to strongly control naming.

1. Update the initiative

    ```bash
    az policy set-definition update --name nonProdDeny --definitions policies/deny.initiative.definition.json --management-group 200 --output jsonc
    ```

    The policy initiative will now be updated.  And importantly, every single policy assignment using that policy initiative will also be updated.  The subscription within the non-prod management group will now be subject to the new naming convention enforcement.

    Note that if you have created the global naming policy at the default subscription level then you would not be able to add it to the initiative, as that is defined at a higher management group level.  You would get this error message:

    ```text
    InvalidCreatePolicySetDefinitionRequest - The policy set definition 'nonProdDeny' request is invalid. Policy definitions should be specified only at or above the policy set definition's scope. The following policy definitions are invalid: 'global-naming-convention'.
    ```

    For this reason, our recommendation is to create the custom policies at the Tenant Root Group by default, and ensure that they are parameterised so they can be used flexibly by your initiatives.

## Recommendations

This is a useful lab to get an understanding of management groups and how the various scope points work for policy definitions, for policy initiative definitions and then for your policy assignments.

It also reinforces our recommendation to create policy definitions as high as possible in the hierarchy and then use initiative definitions against management groups.  This has two really key benefits:

* The policy initiative definitions are easy to understand, and easy to update or extend
* Updating the initiative definitions automatically feeds into the assignments

Therefore lifecycle management of your policies becomes simpler.  If you then add a new subscription to that tenant then it will automatically fall under the Tenant Root Group.  If you then move it under one of your existing management groups then it will automatically inherit the policy initiatives from the management group(s) above.

Looking at this from the partner perspective, I would also think of your custom policies as a shared library of subroutines.  Have a standard set that you deploy at the Tenant Root Group for your customers.  Later labs will have Terraform modules and example Bash scripts to get those defined programmatically.  Both will exist in GitHub. There will also be an example ARM subscription template, but as the name suggests these will only work at the subscription scope, and can not at this point define the custom policies at a management group level.

You can then make your initiatives configurable by customer. Allow different resources types, different SKUs, different regions, different naming conventions, different tagging requirements.  For most of these you can just use initiative definitions.

## What's up next

In the next lab we'll explore tagging, and looking at using multiple policies to get the desired effect.  We'll then look at incorporating initiative parameters to be used by multiple policies.

[◄ Lab 3: Initiatives](../lab3){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 5: Remediation ►](../lab5){: .btn .btn--primary}