---
title: "Azure Policy labs"
author: "Richard Cheney"
published: true
---

## Azure Policy

One of the most interesting stats that came out of the Microsoft Ready event in February is that the percentage of the top 100 Azure customers using Azure Policy is 100%.

Using the native Azure governance services are core to accelerating cloud adoption as they enable workload migration and development for application modernisation whilst providing the guardrails to give management confidence on compliance and cost management.

## All grown up

Azure Policy has shifted from being an interesting deployment control to being a central pillar of our governance and compliancy story, with an extensive range of built-in policies and policy initiatives as well as the ability to create custom definitions.

Initially used purely to stop "bad" deployments, they are now far more functional. We can report on compliancy audits, automatically append resource properties such as tags, and automate the installation of required agents. And policy can be used for not only greenfield compute deployments, but also to remediate existing brownfield deployments and workloads migrated from on prem to get true compliancy at scale.

Policy is working hand in hand with the new Azure Blueprint samples that are starting to be released, such as the ISO27001 sample and accompanying core services and policy initiatives. And the compliancy reporting is not only surfaced within the Azure Policy portal service, but also in the Azure Security Centre dashboard.

## Policy Labs

Tom Wilde and I have put together a set of labs that you can use to get up to speed with policies, initiatives, compliancy and remediation and working at scale using management groups.

Main Azure Policy page (including links to the prereqs)

**Lab** | **Description**
1 | [Simple Portal Policy](/automation/policy/lab1) | Use a simple policy to stipulate the permitted regions
2 | [Creating Policies via CLI](/automation/policy/lab2) | Specify the allowed VM SKU sizes using the Azure CLI
3 | [DeployIfNotExists](/automation/policy/lab3) | Using a policy initiative with the DeployIfNotExist effect for automatic agent deployment and remediation
4 | [Management Groups and Initiatives](/automation/policy/lab4) | Step up a level using Management Groups and assigning a custom Deny initiative
5 | [Tagging and Auditing](/automation/policy/lab5) | Enable default resource tagging without compromising innovation using the append and audit effects

In the unlikely (!) event that you find any problems with the labs then let us know either by using the Disqus comments at the bottom of the lab pages, or if you are more proficient with GitHub then you can always [contribute](https://azurecitadel.com/contributing) directly.

## Coming Soon

The Azure Policy labs provide good foundational knowledge for some of the declarative governance material we have coming out over the next few months.

These will cover:

* Azure Blueprints
* subscription level ARM templates
* Terraform configurations

The aim is to cover some of the governance aspects around management group organisation, role assignments and policy assignments, as well as the provision of standard share services.

And they will be aimed at two levels, for either simpler and smaller businesses, or for more scalable organisations using the hub and spoke topology.

Enjoy!