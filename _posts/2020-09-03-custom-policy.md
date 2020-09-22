---
title: "New custom policy lab"
author: "Richard Cheney"
published: true
excerpt: Additional lab for custom policy creation.
---

## tl;dr

New lab for Custom Policies & Aliases. Use either:

* [Existing Citadel site](https://azurecitadel.com/automation/policy/custom/)
* [New WIP Hugo site](https://hugo.azurecitadel.com/policy/custom/)

## Background

Many of you are making use of Azure Policy to help standardise the governance and compliancy requirements of end customers. It is a key element of the [Cloud Adoption Framework](https://aka.ms/caf) and the Enterprise Scale reference materials that will be a focus for partners this year.

We are fortunate in that the number of policies and initiatives is now very extensive and is still growing.

Here is a list of the places we check first:

* Built-in Policy Definitions in the [portal](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions), [docs](https://docs.microsoft.com/azure/governance/policy/samples/built-in-policies) and [repo](https://github.com/Azure/azure-policy)
* [Sample custom policies](https://github.com/Azure/azure-policy/tree/master/samples)
* [Community Policy](https://github.com/Azure/Community-Policy)

The last resource is where Azure customers and Microsoft teams collaborate and contains some great real world content.

## Custom policies

If you have a specific customer requirement that could be covered by Policy but cannot be found in any of these source areas then you can always create your own. Making custom policy is easier now than it was in the early days, but is still moderately difficult, requiring an understanding of the ARM resource provider types and how to leverage the property aliases, as well as the format of custom policies.

So we have added a new lab into the middle of the [Azure Policy](https://azurecitadel.com/automation/policy) group. The new lab is [Custom Policies & Aliases](https://azurecitadel.com/automation/policy/custom/) and walks you through a real example that I went through with a partner to meet a customer demand. It is useful examples as it demonstrates the process as well as providing a good tour of the tooling, documentation and the various constructs available in the ARM policy schema.

## New Hugo Azure Citadel site

We are working on the next iteration of Azure Citadel to strip out the older content and to make the labs you enjoy easier to find and to navigate. This new lab is available there if you want to get a preview of the new format.

Note that it is a work in progress, using [Hugo](https://gohugo.io/) to generate the static HTML from the content [repo](https://github.com/azurecitadel/azurecitadel) using a custom theme based on the open sourced [Primer](https://primer.style/) CSS used on the GitHub docs sites. It is then deployed using CI/CD integration to [Azure Static Web Apps](https://azure.microsoft.com/services/app-service/static/). The site is guaranteed to change over the next few months - and that may include the urls.

If you want to run through the lab in the new formatting then go here: [Custom Policies & Aliases (Hugo)](https://hugo.azurecitadel.com/policy/custom/)

Enjoy!
