---
layout: article
title: "Terraform Lab 8: Extending with other providers"
categories: null
date: 2018-06-25
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: false
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

## Create an AKS module

** ADD THEM IN **

### SSH Public Key

Hopefully you have an SSH key pair already.  If not then you can create one using the commands below.  

> Use your own email address for the comment field.

```bash
cd ~
umask 033
ssh-keygen -t rsa -b 2048 -C "richard.cheney@microsoft.com"
ls -Al .ssh
cat ~/.ssh/id_rsa.pub
```

The `~/.ssh/id_rsa.pub` public SSH key will be used by default by the module we're about to create and should allow us to login quickly as the aksadmin.

### Create the AKS Service Principal

As per the `modules/aks/variables.tf` file, we need to specify an [AKS Service Principal](https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal), using the client_id and client_secret.  The AKS Service Principal is used to access the AKS service's API endpoints.

* First add two new variable definitions with empty defaults into the root module's variables.tf:

```ruby
variable "aks_client_id" {
    description = "AKS Service Principal's appId"
    default     = ""
}

variable "aks_client_secret" {
    description = "AKS Service Principal's password"
    default     = ""
}
```

> If you are logged in as the the terraform Service Principal (check with `az account show`), then `az logout` then `az login` to log back in as your normal userid for the subscription. Check you are in the right subscription before running the command to create the AKS Service Principal.

* Create the AKS Service Principal with no role

```bash
subscriptionId=$(az account show --output tsv --query id)
az ad sp create-for-rbac --skip-assignment --name "aksapi-$subscriptionId"
{
  "appId": "73da5ad0-42cd-445d-aafb-7b4896b12710",
  "displayName": "aksapi-2d31be49-d999-4415-bb65-8aec2c90ba62",
  "name": "http://aksapi-2d31be49-d999-4415-bb65-8aec2c90ba62",
  "password": "cc5f9262-00d9-4e0c-b89b-f3e296da3fc9",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

OK, let's add the required values into the terraform.tfvars file.

* Add in aks_client_id using the appId value
* Add in aks_client_secret using the password value

```ruby
aks_client_id       = "73da5ad0-42cd-445d-aafb-7b4896b12710"
aks_client_secret   = "cc5f9262-00d9-4e0c-b89b-f3e296da3fc9"
```

There is no need to use the CLI to assign a role as the AKS resource creation will automatically assign the right role.

Finally, we should be able to use the module in the root module's main.tf.

* Add the module resource into the main.tf

```ruby
module "aks" {
    source          = "./modules/aks"
    client_id       = "${var.aks_client_id}"
    client_secret   = "${var.aks_client_secret}"
    tags            = "${var.tags}"
}
```

### Build the AKS Cluster

Right, let's test the new module and build that cluster.  

* Run `terraform get` and `terraform init`

```bash
citadel-terraform$ terraform get
- module.scaffold
- module.aks
  Getting source "./modules/aks"
citadel-terraform$ terraform init
Initializing modules...
- module.scaffold
- module.aks

Initializing the backend...

Initializing provider plugins...
:
```

* Now run the `terraform plan` and `terraform apply`

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

[◄ Lab 7: Multi Tenancy](../lab7){: .btn-subtle} [▲ Index](../#labs){: .btn-subtle} [Lab 9: Provisioners ►](../lab9){: .btn-success}