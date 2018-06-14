---
layout: article
title: "Terraform Lab 5: Modules"
categories: null
date: 2018-08-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: false
---

{% include toc.html %}

## Introduction

Terrform modules are used to create reusable components, and are the key to sensibly scaling out your configurations whilst maintaining your sanity.

This lab will cover:

* why modules are important
* key characteristics
* how to convert your existing .tf files
* the Terraform Registry

## Why use modules?

[Modules](https://www.terraform.io/docs/modules/index.html) help you to standardise your defined building blocks into defined and self contained packages. Modules can be referenced by multiple terraform configurations if they are centrally placed, which promotes reusability and therefore facilitates your default reference architectures and application patterns.

Terraform is flexible enough to pull in modules from different sources:

* Local file paths
* Terraform Registry
* GitHub
* HTTP URLs
* Other (S3 buckets, Git, Mercurial and Bitbucket repos)

As Terraform supports HTTP URLs then Azure blob storage would also be supported and could be secured using SAS tokens.  We'll look at Terraform Registry at the end of the lab, but for the moment we'll be working with local paths and raw GitHub URLs.

You can also nest modules.  For instance, you might have a customised virtual machine module, and then you could call that direct, or it could be called from within an availability set module.  And then that availability set module itself could be nested within an application pattern that included, for instance, three subnets, Azure load balancers, NSGs and called the availability set module a few times.

This is an efficient way of starting with smaller modules and combining them to create complex configurations.

## Key characteristics

The truth is that you have already been working with a module.  The **root module** is everything that sits in the directory in which you have been running your terraform commands.

And a module is just a collection of terraform files in a location.  

The code block below shows an example module call:

```ruby
module "avset" {
  source    = "./modules/availabilityset"
  name      = "myAvSet"
  vms       = 3
  os        = "ubuntu"
  size      = "small"
  lb        = "internal"
}
```

A couple of points to make:

1. There is no provider type required - you only need the Terraform id
1. The only required argument is `source`. If you have a hardcoded Terraform module then this is all that you need.
1. The other arguments are the variables defined within the module
1. The only attributes available for the module are those that have been exported as outputs

If the avset module had an output.tf containing the following:

```ruby
output "ilb_ip" {
  description = "Private IP address for the Internal Load Balancer resource"
  value       = "${azurerm_lb.azlb.private_ip_address}"
}
```

You could then make use of the exported attribute in your root module as follows:

```ruby
resource "azurerm_provider_type" "tfid" {
    dest_ip_address = "${module.avset.ilb_ip}"
}
```

Before we move on, we have a new command to be aware of.  When your root module is using modules then you will need to run a `terraform get`.  This will copy the module information locally.  (If your module is local then it will return immediately.)  You can then run through the `terraform init` to initalise and pull down any required providers before running the plan and apply stages of the workflow.

## Creating a module

There is more to know about modules, but let's crack on and make one, based on everything we defined in lab 3, i.e. the networking, NSGs, key vault etc.  We'll make a module called scaffold.

* Copy the `tenant_id` and `object_id` variables out of your root module's variables.tf
* Create a new file called `modules/scaffold/variables.tf`
    * Visual Studio Code will automatically create the subfolders
* Paste the two variables into the scaffold variables.tf
* Move the coreNetworking.tf, keyvaults.tf and nsgs.tf file into the scaffold folder
* Create a `/modules/scaffold/outputs.tf` file
    * Add in the following output

```ruby
output "vpnGwPipAddress" {
  value = "${azurerm_public_ip.vpnGatewayPublicIp.ip_address}"
}
```

OK, that's defined our local module folder with separate variables.tf and outputs.tf files for our module inputs and outputs. We can always add more outputs to the module later on.

* Run `terraform push` from the Command Palette
* Push syncs up the files but won't remove any that you have "removed"
    * You should be in the Cloud Shell in the ~/clouddrive/citadel-terraform folder
    * If you type `'ls -l` then you should see more files compare to your vscode workspace
    * Remove them: `rm coreNetworking.tf keyvaults.tf nsgs.tf`
* Staying in the Cloud Shell:
    * Run `terraform get` to ensure the modules are in place

## End of Lab 5

We have reached the end of the lab. You have introduced modules to your environment and started to think about how to make use of those to define your standards underpinning different deployments for various reference architectures or customer requirements.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab5>.

In the next lab we will go a little bit deeper on Terraform state and how to manage and protect that in a multi-tenanted environment with multiple admins.

[◄ Lab 6: State](../lab6){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 8: Extending ►](../lab8){: .btn-success}