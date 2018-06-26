---
layout: article
title: "Terraform Lab 8: Extending with other providers"
categories: null
date: 2018-06-25
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

In this lab we will look at other providers that can help with our Azure deployments. One of the reasons for choosing Terraform is the extensible support for multiple providers so that the same workflow and logic can be applied to various public and private cloud platforms.

The same provider extensibility also applies to supporting services and data plane configuration.  In this lab we will look at examples from Cloudflare and Datadog, and deploy an AKS Kubernetes cluster using a combination of the AzureRM provider for the control plane and the Kubernetes provider for the data plane.

Finally will also look at how you can use Terraform to fork a native ARM template deployment.  We'll discuss why that may be useful and some of the caveats to bear in mind.

## Example Providers

Take a look at the range of [Terraform Providers](https://www.terraform.io/docs/providers/) available.  It is a wide and expanding list, covering am ultitude of private and public cloud platforms, various applications, supporting technologies and cloud services such as public DNS.

All of the providers follow the same documentation standard as the azurerm provider.  

### Datadog

[Datadog](https://www.datadoghq.com/) is used by 1000s of customer as their platform for modern monitoring and analytics, and it has over 200 integrations with various cloud services, including a number of [Azure services](https://www.datadoghq.com/product/integrations/#cat-azure).

The [Datadog Provider](https://www.terraform.io/docs/providers/datadog/index.html) is relatively simple, with a couple of key variables for the API to authenticate with, and four possible resource types:

1. datadog_downtime
1. datadog_monitor
1. datadog_timeboard
1. datadog_user

This allows the monitoring to be configured automatically as one facet of the wider Terraform configuration.

### Cloudflare

[Cloudflare](https://www.cloudflare.com/dns/) offer a number of services including a fast authoritative public DNS servers on 1.1.1.1 and 1.0.0.1.  They are very fast in terms of DNS lookup latency and speed of DNS record propogation.

These are widely used as an alterative to other well known public DNS servers such as Google's 8.8.8.8 and 8.8.4.4, and have a free tier for personal use.

The [Cloudflare Provider](https://www.terraform.io/docs/providers/cloudflare/index.html) is authenticated using an email address for the Cloudflare account plus an API token.  There are a few more resource types available:

1. cloudflare_load_balancer
1. cloudflare_load_balancer_pool
1. cloudflare_page_rule
1. cloudflare_rate_limit
1. cloudflare_record
1. cloudflare_load_balancer_monitor
1. cloudflare_zone_settings_override

Again, the options here extend out what is possible in a configuration.  

### Kubernetes

There are a number of different container orchestration technologies, but Kubernetes has essentially won the war and is now the de facto orchestrator technology for hyperscale cloud platforms.

The [Kubernetes Provider](https://www.terraform.io/docs/providers/kubernetes/index.html) has a couple of authentication options, and a wide array of resource types and also a couple of data types.  It can take the base Kubernetes cluster and its running components, and then schedule the Kubernetes resources, like pods, replication controllers, services etc.

## Azure Container Service (AKS)

OK, let's create an AKS cluster using the [azurerm_kubernetes_cluster](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html) resource type and then use the Kubernetes provider to do some additional configuration.  We'll need an SSH key pair, so let's make sure we have one and put the public key into the Key Vault.

### Allow the Service Principal to create keys

### SSH Public Key

Hopefully you have am SSH key pair already.  If not then you can create one using the commands below.  

> NOte! Substitute in your own email address!

```bash
cd ~
umask 033
ssh-keygen -t rsa -b 2048 -C "richard.cheney@microsoft.com"
ls -Al .ssh
cat .ssh/id_rsa.pub
```



**CHECK THIS SECTION WITH JUSTIN DAVIES AND BEN COLEMAN!!**



## Azure Resource Manager (ARM)

### Extending Terraform into ARM

One azurerm resource type that we have not discussed so far is [azurerm_template_deployment](https://www.terraform.io/docs/providers/azurerm/r/template_deployment.html).

There are some limitations with using the Terraform provider:

* **coverage** - there are certain edge case services that are available as ARM template resource types, and are not available as a Terraform resource type
* **lag** - inevitably there will be a period of lag as new Azure services are released, although prominent services such as AKS and Cosmos DB has been released close to the General Availability (GA) date

Terraform can initiate the deployment and have knowledge of it.  Destroying the resource in Terraform will only destroy that knowledge of the deployment. For this reason it is recommended to create a separate resource group for the templated deployment so that removing both the resource group and the ARM deployment will remove the resources as well.

If an azurerm resource type then becomes available then a resource stanza can created and the existing resource(s) can be imported.  It will need careful configuration until a `terraform plan` doesn't show any creates, destroys or changes.  It is not safe to configure new additions, deletions or changes until that steady state has been achieved.

### Extending ARM into Terraform

For information, ARM templates can now also drive certain Terraform providers as per the recent [blog](https://azure.microsoft.com/en-us/blog/introducing-the-azure-terraform-resource-provider/).  

Whilst it is in public preview then the Cloudflare, Datadog and Kubernetes will be supported and then other providers will be added.

Azure Resource Manager will never drive other cloud providers, but it does allow ARM confiogurations to take advantage of the Terraform framework and extend the configuyration beyond the functionality at the control plane level.

## End of Lab 8

We have reached the end of the lab. You have provisioned and configured a Kubernetes cluster on the AKS service, and looked at some of the other providers and provider typesz.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab8>.

In the next lab we will also look at provisioners and how they can help to go beyond vanilla image deployments for your virtual machines.

[◄ Lab 7: Multi Tenancy](../lab7){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 9: Provisioners ►](../lab9){: .btn-success}