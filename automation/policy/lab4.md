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

    Using a deny initiative is very effective for these.  For other types of policies then  it can be overkill and cause friction.  For example enforcing tagging with a deny effect in your policy definition can prevent users from creating certain resources within the portal GUI.  Which is a nice segue into using the Audit effect...

2. **Use the Audit effect for desired configurations and check compliancy within Azure Policy.**

    Tagging is a great example for this and will be used later in the set of labs.  It is good practice to have a default set of tags created for each resource (and possibly resource group).  You can then slice and dice the billing using the tagging, find out who is the application owner, which resources are naturally related, or establish values which can then be used in automation around downtime, or switching on and off resources to get benefit from cloud's utility computing models.

    Using Audit means that those resources can still be deployed, and you can be nice in auto-creating tags, defaulting values etc., and then use the compliancy reporting in Azure Policy to correct non-compliant resources.  In certain circumstances (e.g. where resources are deployed purely through CI/CD) then you may want to switch from Audit to Deny.

3. **Leverage the DeployIfNotExists inbuilt initiatives**

    The new initiatives are perfect for ensuring that standard agents are auto-installed for both newly instantiated resources and for those that are migrated into the environment.

In this lab we will address the first area, and show how to create and then update an example Deny initiative.  We'll create it initially with constraints for geography and VM SKUs and assign it.  Then we'll create a custom policies for resource group and resource naming and then update the initiative.

In later labs we will translate this into both a subscription level ARM template and a Terraform module.

## Create a Custom Policy Initiative

1. Set your defaults

    We'll avoid lengthy commands by defaulting the `--resource-group` and `--location` switches.  We'll also be re-using the PolicyLab resource group.  )

    ```bash
    az configure --defaults group=PolicyLab location=uksouth
    az group create --name PolicyLab
    ```

    (Personally I always configure the CLI output to jsonc using `az configure`, but you can choose from the various options, from the default table to the more detailed json or yaml outputs.  The tsv output is usually used in combination with [JMESPATH](/prereqs/cli/cli-3-jmespath/) queries in scripting.)

1. Create a new subdirectory called policy

    ```bash
    mkdir -m 755 policy
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

    The `--parent` switch defaults to the Tenant Root Group.

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

    The resourceId for the policy initiative definition will be new, based on the management group Id and the provider type.  For example:

    ```text
    /providers/Microsoft.Management/managementgroups/200/providers/Microsoft.Authorization/policySetDefinitions/nonProdDeny
    ```

    OK, we should now be able to assign it at any level from Non-Prod downwards.

1. Assign the initiative at the Dev level

    ```bash
    policySetId=$(az policy set-definition show --name nonProdDeny --output tsv --query id)


1. Move your subscription under the new management group

    > Note that you can always move it back to the root later

    ```bash
    subscriptionId=$(az account show --output tsv --query id)
    az account management-group subscription add --name 230 --subscription $subscriptionId
    ```



In this section we will allocate the policy initiative definition at the highest point possible, which is the Tenant Root Group. This is auto-created within every Azure Active Directory tenancy, and all subscriptions for that AAD tenancy are under this management group.



1/



## Updating an existing policy initiative

[◄ Lab 3: Initiatives](../lab3){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 5: Remediation ►](../lab5){: .btn .btn--primary}