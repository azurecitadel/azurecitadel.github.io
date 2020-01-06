---
title: "Tagging Policies"
date: 2019-05-21
author: [ "Richard Cheney" ]
category:
comments: true
featured: false
hidden: true
published: true
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

There are more BuiltIn policies, but they use the deny effect.  We'll create some Custom policies that use audit instead. I have created a few example policies using the format seen in ARM templates:

* <https://github.com/richeney/arm/blob/master/policies/auditemptytag.json>
* <https://github.com/richeney/arm/blob/master/policies/audittagvalues.json>
* <https://github.com/richeney/arm/blob/master/policies/audittagvaluepattern.json>

Note how the files contain both the rule and the parameters, as well as the values we have been specifying using the CLI switches. (We will cover the creation of custom policies declaratively (using both ARM and Terraform) in a later lab.)

You know how to create policies manually via the CLI, but let's use a utility script called addpolicy.sh to speed things up. You will need to have the correct RBAC permissions to create policies at the Root Tenant Group.

1. Download the addpolicy.sh script and show the usage

    ```bash
    curl -sSL https://raw.githubusercontent.com/richeney/arm/master/scripts/addpolicy.sh --output addpolicy.sh && chmod 755 addpolicy.sh
    ./addpolicy -h
    ```

> If you do not have the `Microsoft.Authorization/policyassignments/*` RBAC permission fpr the Root Tenant Group then delete the `--management-group $tenantId \` line from the multi-line `az policy definition create` command.  The custom policies will be created at the subscription scope instead.

1. Add the two custom policies

    ```bash
    export URIBASE=https://raw.githubusercontent.com/richeney/arm/master/policies
    ./addpolicy.sh auditemptytag audittagvalues audittagvaluepattern
    ```

The script will output the IDs of the resulting policies. Example IDs for the auditemptytag policy:

**Scope** | **resourceId**
Root Tenant Group | /providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditEmptyTagValue
Subscription | /subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/providers/Microsoft.Authorization/policyDefinitions/auditEmptyTagValue

1. List out the custom policies at the Tenant Root Group

    In case you need to find out the resourceIds for your custom policies:

    ```bash
    tenantId=$(az account show --query tenantId --output tsv)
    az policy definition list --management-group $tenantId --query "[? policyType == 'Custom'].id"
    ```

    This should return something similar to:

    ```json
    [
      "/providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditEmptyTagValue",
      "/providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditTagValuePattern",
      "/providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditTagValues"
    ]
    ```

## Custom Policy Initiative

Now, remember that policy initiatives can only use either the BuiltIn policies, or those Custom policies that have been created at the same scope point or higher. It is therefore our recommendation to maintain your own library of parameterised custom policies, and to define those at the highest scope point possible.  You can then customise your policy initiatives per management group or subscription, either through different definitions or via policy initiative parameters.

Now that we have our list of BuiltIn and Custom policies, let's define a policy initiative for tagging that uses a parameter. Once it has been defined then we'll assign it to a lower management group level, specifying the correct Environment value for that scope point.

## Policy initiative definition

1. Create a new subdirectory called initiatives

    ```bash
    mkdir -m 755 initiatives
    cd initiatives
    ```

1. Copy in the following JSON into a new file in the initiatives folder called **tags.definition.json**:

    ```json
    [
        {
            "comment": "Create Owner tag if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Owner"
                },
                "tagValue": {
                    "value": ""
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
        },
        {
            "comment": "Audit Owner tag if it is empty",
            "parameters": {
                "tagName": {
                    "value": "Owner"
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditEmptyTagValue"
        },
        {
            "comment": "Create Department tag if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Department"
                },
                "tagValue": {
                    "value": ""
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
        },
        {
            "comment": "Check if Department is in the defined list",
            "parameters": {
                "tagName": {
                    "value": "Department"
                },
                "tagValues": {
                    "value": [
                        "Finance",
                        "Human Resources",
                        "Logistics",
                        "Sales",
                        "IT"
                    ]
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditTagValues"
        },
        {
            "comment": "Create Application tag if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Application"
                },
                "tagValue": {
                    "value": ""
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
        },
        {
            "comment": "Audit Application tag if it is empty",
            "parameters": {
                "tagName": {
                    "value": "Application"
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditEmptyTagValue"
        },
        {
            "comment": "Create Environment tag with parameters value if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Environment"
                },
                "tagValue": {
                    "value": "[parameters('Environment')]"
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
        },
        {
            "comment": "Deny Environment tag if it isn't set to the parameter",
            "parameters": {
                "tagName": {
                    "value": "Environment"
                },
                "tagValue": {
                    "value": "[parameters('Environment')]"
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
        },
        {
            "comment": "Create Downtime tag if it does not exist, with default value",
            "parameters": {
                "tagName": {
                    "value": "Downtime"
                },
                "tagValue": {
                    "value": "Tuesday, 04:00-04:30"
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
        },
        {
            "comment": "Audit Downtime tag if it is empty",
            "parameters": {
                "tagName": {
                    "value": "Downtime"
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditEmptyTagValue"
        },
        {
            "comment": "Create Costcode tag if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Costcode"
                },
                "tagValue": {
                    "value": ""
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
        },
        {
            "comment": "Check that Costcode tag value is a six digit number",
            "parameters": {
                "tagName": {
                    "value": "Costcode"
                },
                "tagValuePattern": {
                    "value": "######"
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policyDefinitions/auditTagValuePattern"
        }
    ]
    ```

    You can see that it is simple to understand, if you know which policyDefinitionIds you are using. Don;t forget to include comments as these will be discarded by the CLI when defining the policy initiative.

    The initiative will force the Environment value to be a specific value, and this has been parameterised. So we need a parameters file for it

1. Create the a **tags.parameters.json** files in the initiatives folder

    ```json
    {
        "Environment": {
            "type": "string",
            "metadata": {
                "description": "Environment, from permitted list",
                "displayName": "Environment"
            },
            "defaultValue": "Prod",
            "allowedValues": [
                "Prod",
                "UAT",
                "Test",
                "Dev"
            ]
        }
    }
    ```

    Note that if you are using an allowedValues list that your defaultValue must be from that list or the definition will not create.

1. Go back up to the parent directory

    ```bash
    cd ..
    ```

1. Create the policy initiative definition

    ```bash
    az policy set-definition create --name tags --display-name "Standard Tags" --description "Tags: Owner, Department, Application, Environment, Downtime, Costcode" --management-group $tenantId --definitions initiatives/tags.definition.json --params initiatives/tags.parameters.json
    ```

    > If you cannot create policy initiative definitions as the Tenant Root Group level then change the scope to another management group, or to the subscription level using the `--subscription` switch. (Note that all of the CLI commands support the `--help` switch, e.g. `az policy set-definition create --help`.)

    Your initiative should be defined with a resourceId similar to the following format:

    ```text
    /providers/Microsoft.Management/managementgroups/f246eeb7-b820-4971-a083-9e100e084ed0/providers/Microsoft.Authorization/policySetDefinitions/tags
    ```

    And you can list out your custom initiatives at the Tenant Root Group using a command similar to the custom policy ine we used earlier in the lab:

    ```bash
    az policy set-definition list --management-group $tenantId --query "[? policyType == 'Custom'].id"
    ```

## Testing the tagging initiative

The initiative has now been defined at the Tenant Root Group. You should still have the Dev management group that you created in lab 4, which had an ID of 230.  We'll eventually assign the initiative there and specify the value of Environment.

But first, let's test it out at a safer resource group level. (It is assumed that you still have a default location set using `az configure --defaults location=westeurope`.)

1. Create the resource group

    ```bash
    az group create --name tagInitiativeTest
    ```

1. Assign the initiative

    ```bash
    initiativeId=/providers/Microsoft.Management/managementgroups/${tenantId}/providers/Microsoft.Authorization/policySetDefinitions/tags
    az policy assignment create --name tags --display-name "Standard Tags" --policy-set-definition $initiativeId --params '{"Environment":{"value": "Dev"}}' --resource-group tagInitiativeTest
    ```

1. Create a test resource

    ```bash
    az disk create --resource-group tagInitiativeTest -n DeleteMe --size-gb 10 --output jsonc
    ```

    The tags in the command output should look like this:

    ```jsonc
      "tags": {
        "Application": "",
        "Costcode": "",
        "Department": "",
        "Downtime": "Tuesday, 04:00-04:30",
        "Environment": "Dev",
        "Owner": ""
      }
    ```

    All of the tags have been created for us.  This is normally preferable to stopping deployment if they are not defined at that point. Downtime is set to the initiative's default value, and Environment is hardcoded to Dev.

1. Check compliancy

    After a period of time, the compliancy with Azure Policy should show the managed disk resource as being out of compliance. Set the scope level to be the tagInitiativeTest resource group within your subscription:

    ![Non Compliant](/automation/policy/images/lab5-noncompliant.png)

    You can also use CLI commands to interrogate the state:

    ```bash
    az policy state list --resource-group tagInitiativeTest --policy-assignment tags --query "[?! isCompliant ].{resourceId:resourceId, policy:policyDefinitionName}" --output table
    ```

1. Update the tags

    Manually update the tags to make the resource compliant for the next compliancy poll

    ![Updated Tags](/automation/policy/images/lab5-updatedtags.png)

1. Use REST API call to trigger evaluation

    The Azure docs have information on the standard [evaluation triggers](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data#evaluation-triggers), but I'm going to assume that you're impatient and don't want to wait 24 hours for the standard compliance evaluation cycle to go round.

    We'll use the REST API to trigger an [on demand scan](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data#on-demand-evaluation-scan) on our resource group. (Hopefully this will become a CLI command in the future.)

    ```bash
    subscriptionId=$(az account show --output tsv --query id)
    rg=tagInitiativeTest
    triggeruri=https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rg/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview

    accessToken=$(az account get-access-token --output tsv --query accessToken)
    curl --silent --include --header "Authorization: Bearer $accessToken" --header "Content-Type: application/json" --data '{}' --request POST $triggeruri
    ```

    You should get back a number of header from the HTTP 202 response, including a location URI.

1. Wait for evaluation completion

    You can track the scanning event in the Activity Log if you have non-compliant resources:

    * Azure Policy
    * Click on the Standard Tags policy assigned to the test resource group scope
    * Click on Non-compliant Resources
    * Click on the ellipsis (**...**) to the right of the non-compliant resource
    * Click on Show Activity Logs

    The _Trigger Policy Insights Compliance Evaluation_ operation will show a status of 'Accepted', which will become 'Started' and then 'Succeeded' once the policy evaluation has finished.

1. \[Optional] - Query the location URI for scanning status

    Alternatively, you can use REST You can use a REST API GET command against that location URI.

    The REST call returns **202 Accepted** whilst running and then **200 OK** once the evaluation has completed.

    Here is an example of the REST call against the location URI:

    ```bash
    locationuri=https://management.azure.com/subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62/providers/Microsoft.PolicyInsights/asyncOperationResults/eyJpZCI6IlBTUkFKb2I6MkRFMTVERjczMSIsImxvY2F0aW9uIjoiIn0?api-version=2018-07-01-preview

    curl --silent --include --header "Authorization: Bearer $accessToken" --header "Content-Type: application/json" --request GET $locationuri
    ```

    > Note that your location URI will not be the same as the one above. Use the `location:` value in the trigger output.

1. Verify compliancy

    Once the resources have been rescanned, you can return to the Azure Policy screen and verify that the resource is now compliant with the Default Tagging policy initiative.

    ![Compliant](/automation/policy/images/lab5-compliant.png)

## Assigning the policy initiative to a management group

1. Remove the test resource group

    Deleting the test resource group will delete the resource group, the resources and the policy assignment.

    ```bash
    az group delete --yes --no-wait --name tagInitiativeTest
    ```

1. Add the policy to a higher scope point

    Now that you have tested the policy, you can assign it at a more appropriate scope point, such as the Dev management group.

    ```bash
    tenantId=$(az account show --query tenantId --output tsv)
    initiatives=/providers/Microsoft.Management/managementgroups/${tenantId}/providers/Microsoft.Authorization/policySetDefinitions
    mgs=/providers/Microsoft.Management/managementGroups
    az policy assignment create --name tags --display-name "Standard Tags" --policy-set-definition $initiatives/tags --params '{"Environment":{"value": "Dev"}}' --scope $mgs/230
    ```

## Wrapping up

OK, that is quite a few labs covering the creation of policies and initiatives, and how they work with management groups.

In the next lab we will explore an example workflow for deploying a new tenancy in Azure, using Terraform to create the management groups, policy definitions, assignments and RBAC assignments.

[◄ Lab 4: Custom](../lab4){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse}