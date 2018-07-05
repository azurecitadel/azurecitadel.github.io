---
layout: article
title: "Terraform Lab 7: Modules"
categories: null
date: 2018-06-25
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
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
1. The only required argument is `source` - if you have a hardcoded Terraform module then this is all that you need
1. The other arguments match the variables defined within the module
1. The only attributes available for the module are those that have been exported as outputs within the module

As an example, if the avset module had an output.tf containing the following:

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

When your root module is using child modules then you will need to run a `terraform get`.  This will copy the module information locally.  (If your module is already local then it will return immediately.)  You can then run through the `terraform init` to initalise and pull down any required providers before running the plan and apply stages of the workflow.

## Creating a module

There is more to know about modules, but let's crack on and make one, based on everything we defined in lab 3, i.e. the networking, NSGs, key vault etc.  We'll make a module called scaffold.

* Copy the `loc`, `tags`, `tenant_id` and `kvr_object_id` variables out of your root module's variables.tf
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

OK, that's defined our local module folder.  It has a variables.tf defining the inputs, which are loc, tags, tenant_id and kvr_object_id.  And we have an outputs.tf files for the module outputs, which currently only has vpnGwPipAddress. We can always add more outputs to the module later on.

* Now create a main.tf with a module call

```ruby
module "scaffold" {
  source    = "./mymodules/scaffold"

}
```

* Run `terraform get` and then check your .terraform folder

```bash
citadel-terraform$ terraform get
- module.scaffold
  Getting source "./modules/scaffold"
citadel-terraform$
citadel-terraform$ tree .terraform/
.terraform/
├── modules
│   ├── d2a8d6021493603f7473faed81e245db -> /mnt/c/Users/richeney/git/citadel-terraform/modules/scaffold
│   └── modules.json
├── plugins
│   └── linux_amd64
│       ├── lock.json
│       ├── terraform-provider-azurerm_v1.7.0_x4
│       └── terraform-provider-random_v1.3.1_x4
└── terraform.tfstate

```

* And then `terraform init`

```bash
citadel-terraform$ terraform init
Initializing modules...
- module.scaffold

Initializing the backend...

Initializing provider plugins...

:
```

* Run `terraform plan`

You should see that all of the resources that are now in the module will be deleted and recreated. They have essentially all been renamed, with the resources prefixed with `module.terraform.` and we can use that to manipulate the terraform.tfstate file.  We can refactor the Terraform IDs for those resources using the `terraform state mv` command.  This is a very flexible tool that can selectively extract resources from one state file into another.  Run `terraform state mv --help` to check the help page for it.  

* Run the loop below to rename the resources in our existing state file

```bash
for resource in $(terraform plan -no-color | grep "^  + module.scaffold" | awk '{print $NF}')
do terraform state mv ${resource##module.scaffold.} $resource
done
```

* Rerun `terraform plan`

You should now see that there are no changes required.  

The `terraform state mv` command is potentially dangerous, so it automatically creates backup files for each action.  If you want to tidy them up then you can run `rm terraform.tfstate.??????????.backup`.

## Terraform Registry

There are a number of modules created for use at the [Terraform Registry](https://registry.terraform.io/) for all of the major Terraform providers.  This is comparable to the Azure Quickstart Templates repository in GitHub with contributions from both the vendors and from the wider community.

You will notice that AWS has by far the largest number of community contributed modules, although not many of those have been verified.  Azure is a distant second in terms of community contribution, although it has a similar number of verified modules from both Azure and Hashicorp

Browse one of the modules.  You'll notice the source path starts with `Azure/`, and the documentation shows examples in the readme, inputs, outputs, dependencies, resources etc.  In terms of standards this is a good guideline for your own modules.

You can also click on the source link and it will take you through to the GitHub repository.  Take a look at <https://github.com/Azure/terraform-azurerm-network> and you will see that it has a good README.md.  The other key thing is that for simple one level modules that most contributors stick to variables.tf, main.tf and outputs.tf.  This makes it easier for everyone usiubng a module to see the inputs, outputs, and have everything else hidden away in the main.tf.  Let's do the same:

* Move to the modules/scaffold folder
* Concatenate your coreNetworking.tf, keyvaults.tf and nsgs.tf into a single main.tf file
* Remove the old files
* Return back to the main citadel-terraform folder

```bash
citadel-terraform$ cd modules/scaffold/
scaffold$ pwd
/mnt/c/Users/richeney/git/citadel-terraform/modules/scaffold
scaffold$ cat coreNetworking.tf keyvaults.tf nsgs.tf > main.tf
scaffold$ rm coreNetworking.tf keyvaults.tf nsgs.tf
scaffold$ cd -
/mnt/c/Users/richeney/git/citadel-terraform
```

* Run the `terraform plan` to confirm no changes are required

## Using a module from the registry

If you are ahead of others in the lab then feel free to leverage one of the modules on the [Terraform Registry](https://registry.terraform.io/).  Note that instantiating services on the public cloud platformas will incur charges so be sensible!

## Updating modules

One of the key tenets for Terraform is the idea of versioning.  This applies throughout the configuration, from the version of the terraform executable itself through to the version control (via SCM) for your .tf files, and also the modules that you are using.

As a result, the terraform executable can only be updated manually, outside of standard linux package management such as `sudo apt update && sudo apt full-upgrade` on Ubuntu.  The Terraform [releases](https://releases.hashicorp.com/terraform/) page lists out all of the versions, but does not include a 'latest' to adhere to that versioning ethos.  If you want a new version then you download that version and replace the one that you have.

The same applies to modules.  When you ran the `terraform get` it takes a copy of the modules and puts them into your `.terraform/modules` folder.  (For the local modules it uses a symbolic link instead.)  And if you run `terraform get` then it **will not** update modules if they already exist in that folder.  Instead you have to use `terraform get -update=true`. And you can include [version constraints](https://www.terraform.io/docs/modules/usage.html#module-versions) to ensure that you are using a known good version.  

## End of Lab 7

We have reached the end of the lab. You have introduced modules to your environment and started to think about how to make use of those to define your standards underpinning different deployments for various reference architectures or customer requirements.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab7>.

In the next lab we will go a little bit deeper on Terraform state and how to manage and protect that in a multi-tenanted environment with multiple admins.

[◄ Lab 6: State](../lab6){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 8: Extending ►](../lab8){: .btn-success}