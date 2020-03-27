---
title: "Terraform Modules"
date: 2020-02-01
author: Richard Cheney
category: automation
comments: true
featured: false
hidden: true
tags: [terraform]
header:
  overlay_image: images/header/terraform.png
  teaser: images/teaser/terraformlogo.png
sidebar:
  nav: "terraform"
excerpt: Understand how Terraform modules can be re-used as standard building blocks for your environments and explore the Terraform Registry
---

## Introduction

> These labs have been updated soon for 0.12 compliant HCL. If you were working through the original set of labs then go to [Terraform on Azure - Pre 0.12](/automation/terraform-pre012).

Terraform modules are used to create reusable components, and are the key to sensibly scaling out your configurations whilst maintaining your sanity.

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

## Key module characteristics

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

A few really important points to make:

1. **Provider type is not required**
    * You only need the Terraform id
1. **_Source_ is the only required argument**
    * If your module is hardcoded (like the NSGs) then this is all that you need
1. **Create additional arguments for your module by defining variables**
    * The module cannot see any variables from the root module
1. **Create attributes for your module by defining output**
    * You cannot access any 'normal' provider type attributes from the module unless they are exported as outputs

Let's look at using a module's outputs as an exported attribute. For example, if the avset module had an output.tf containing the following:

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

## Create a terraform-module-scaffold repository

There is more to know about modules, but let's crack on and make a simple one called scaffold, based on the networking and NSGs from lab 3.

We'll first make a make a new GitHub repository for our modules.

* Go into GitHub and create a new repository called terraform-module-scaffold
* Clone it in vscode
* Select add Add to Workspace from the notification

![Add to Workspace](/automation/terraform/images/addToWorkshop/png)

* Check vscode's Explorer (`CTRL`+`SHIFT`+`E`) and SCM (`CTRL`+`SHIFT`+`G`) to see how it handles multi root workspaces

## Create the scaffold module

* Copy the `loc` and `tags` variables out of your root module's variables.tf
* Right click the terraform-module-scaffold bar in vscode Explorer
* Create a new file called `variables.tf`
* Paste the two variables into the scaffold variables.tf
* Create an `outputs.tf` file
* Add in the following output

```ruby
output "vpnGwPipAddress" {
  value = "${azurerm_public_ip.vpnGatewayPublicIp.ip_address}"
}
```

Concatenate the coreNetworking.tf and nsgs.tf file into the terraform-module-scaffold folder

* Open the Integrated Console and make sure you are in the terraform-labs folder
* Run the commands in the following code block:

```bash
cat coreNetworking.tf nsgs.tf > ../terraform-module-scaffold/main.tf
rm coreNetworking.tf nsgs.tf
```

The commands have concatenated the two files into a new main.tf in our scaffold module, and then removed them from out terraform-labs area.

OK, that's defined our local module folder.  It is a common convention for modules to have only a variables.tf, main.tf and an outputs.tf and that is what we have.

1. The variables.tf defines our modules inputs, which are loc and tags
1. The main azurerm stanzas are in the main.tf
1. The outputs.tf file has the module outputs, which is currently only the vpnGwPipAddress

## Create a new main.tf in terraform-labs

We will rename the webapps.tf and add in the new module call at the top. (You still have full flexibility over how you name your *.tf files, but we'll make the change anyway.)

* Rename the webapps.tf to main.tf
* Insert the following stanza at the top of the file

```ruby
module "scaffold" {
  source    = "../terraform-module-scaffold/scaffold"
}
```

That is a relative path for the _source_ value.  You may fully path if you prefer.

## Import the module

* Run `terraform get`

```bash
terraform-labs$ terraform get
- module.scaffold
  Getting source "/mnt/c/Users/richeney/git/terraform-module-scaffold"

terraform-labs$ tree .terraform
.terraform
├── modules
│   ├── ca0c4bdbf3f2e5218f73ce44078a995f -> /mnt/c/Users/richeney/git/terraform-module-scaffold
│   └── modules.json
├── plugins
│   └── linux_amd64
│       ├── lock.json
│       ├── terraform-provider-azurerm_v1.13.0_x4
│       └── terraform-provider-random_v2.0.0_x4
└── terraform.tfstate

```

Notice that it is a symlink when using local modules.

* Display the modules.json through jq

```bash
terraform-labs$ jq . .terraform/modules/modules.json
{
  "Modules": [
    {
      "Source": "/mnt/c/Users/richeney/git/terraform-module-scaffold",
      "Key": "1.scaffold;/mnt/c/Users/richeney/git/terraform-module-scaffold",
      "Version": "",
      "Dir": ".terraform/modules/ca0c4bdbf3f2e5218f73ce44078a995f",
      "Root": ""
    }
  ]
}
```

* Run `terraform init`

```bash
terraform-labs$ terraform init
Initializing modules...
- module.scaffold

Initializing the backend...

Initializing provider plugins...

:
```

* Run `terraform plan`

You should see in the plan output that all of the resources that are now in the module will be deleted and recreated.  **DO NOT RUN A TERRAFORM APPLY!!**

Those resources have essentially all been renamed, with the resources prefixed with `module.terraform.` and we can use that to manipulate the terraform.tfstate file.  This gives us an opportunity to introduce another command to manage state effectively.

## Refactoring module resources in a state file

We can refactor the Terraform IDs for those resources using the `terraform state mv` command.  This is a very flexible tool that can selectively extract resources from one state file into another.  Run `terraform state mv --help` to check the help page for it.

* Run the loop below to rename the resources in our existing state file

```bash
for resource in $(terraform plan -no-color | grep "^  + module.scaffold" | awk '{print $NF}')
do terraform state mv ${resource##module.scaffold.} $resource
done
```

* Rerun `terraform plan`

You should now see that there are no changes required. Whenever you are making fundamental backend changes to a configuration then getting to this point of stability is important before introducing actual adds, deletes and changes to the infrastructure.

The `terraform state mv` command is potentially dangerous, so Terraform sensibly creates backup files for each action.  If you want to tidy those automatically created backup files up then you can run `rm terraform.tfstate.??????????.backup`.

## Using a module from GitHub

You probably wouldn't create and use a local module and then switch to using the very same module in GitHub.  If you did then the clean way to handle that would be to remove the modules area entirely (`rm -fR .terraform/modules`) as we are only using the one local module at this point.  But we won't do that as it will allow us to dig into them and understand them a little better.

Push the module up to GitHub:

* Open the Source Control sidebar in vscode (`CTRL`+`SHIFT`+`G`)
* Commit your scaffold module
* Push the terraform-module-scaffold repository up to GitHub
    * If you have multiple repositories open then click on the sync icon for terraform-module-scaffold in the Source Control Providers
    * Repeat the above for your terraform-labs repository if you have not pushed it up recently
* Open a browser and navigate to the terraform-module-scaffold repository
    * Example path: `https://github.com/\<username>/terraform-module-scaffold/`
    * You should see the variables.tf, main.tf and outputs.tf
* Copy the address in the address bar (`CTRL`+`L`, `CTRL`+`C`)
* Find the module in your terraform-labs main.tf
* Replace the local path with the GitHub URI without the `https://` prefix

For example:

```ruby
module "scaffold" {
  # source    = "/mnt/c/Users/richeney/git/terraform-module-scaffold"
  source    = "github.com/richeney/terraform-module-scaffold"
}
```

* Run `terraform get`
    * It will take a little longer as it will clone it locally
    * Local modules are quicker to 'get' as they are only symlinks
* Run `tree .terraform`

```bash
terraform-labs$ tree .terraform
.terraform
├── modules
│   ├── a5269b88508cfda37e02e97e5759753f
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   └── variables.tf
│   ├── ca0c4bdbf3f2e5218f73ce44078a995f -> /mnt/c/Users/richeney/git/terraform-module-scaffold
│   └── modules.json
├── plugins
│   └── linux_amd64
│       ├── lock.json
│       ├── terraform-provider-azurerm_v1.13.0_x4
│       └── terraform-provider-random_v2.0.0_x4
└── terraform.tfstate

5 directories, 9 files
```

The modules directory has a code to denote each module.  The top one (`a5269b88508c...`) contains the files cloned from GitHub.  The second one is symlinked to the local module directory.

* Open the modules.json file in vscode
    * It contains a list (`[]`) containing a JSON object (`{}`) for both of the modules
    * The file will be minified, but if you have Erik Lynd's JSON Tools extension then you can use `CTRL`+`ALT`+`M` to prettify the JSON.

```json
{
  "Modules": [
    {
      "Source": "/mnt/c/Users/richeney/git/terraform-module-scaffold",
      "Key": "1.scaffold;/mnt/c/Users/richeney/git/terraform-module-scaffold",
      "Version": "",
      "Dir": ".terraform/modules/ca0c4bdbf3f2e5218f73ce44078a995f",
      "Root": ""
    },
    {
      "Source": "github.com/richeney/terraform-module-scaffold",
      "Key": "1.scaffold;github.com/richeney/terraform-module-scaffold",
      "Version": "",
      "Dir": ".terraform/modules/a5269b88508cfda37e02e97e5759753f",
      "Root": ""
    }
  ]
}
```

We'll remove the old local module, which is the first one in my example

* Remove the local module object, for instance:

```json
{
  "Modules": [
    {
      "Source": "github.com/richeney/terraform-module-scaffold",
      "Key": "1.scaffold;github.com/richeney/terraform-module-scaffold",
      "Version": "",
      "Dir": ".terraform/modules/a5269b88508cfda37e02e97e5759753f",
      "Root": ""
    }
  ]
}
```

If you have any JSON syntax errors then vscode will highlight those for you.

* Save the file
* Remove the matching dir

```bash
terraform-labs$ ls -l .terraform/modules/
total 0
drwxrwxrwx 1 richeney richeney 4096 Sep  4 17:01 a5269b88508cfda37e02e97e5759753f
lrwxrwxrwx 1 richeney richeney   51 Sep  4 16:46 ca0c4bdbf3f2e5218f73ce44078a995f -> /mnt/c/Users/richeney/git/terraform-module-scaffold-rwxrwxrwx 1 richeney richeney  439 Sep  4 17:01 modules.json

terraform-labs$ rm .terraform/modules/ca0c4bdbf3f2e5218f73ce44078a995f

terraform-labs$ ls -l .terraform/modules/
total 0
drwxrwxrwx 1 richeney richeney 4096 Sep  4 17:01 a5269b88508cfda37e02e97e5759753f
-rwxrwxrwx 1 richeney richeney  439 Sep  4 17:01 modules.json
```

* Rerun `terraform get`, `terraform init` and `terraform plan` to ensure all is good

Note that the plan did not flag any required changes as the terraform IDs were unaffected by the change in module location.

## Updating modules

One of the key tenets for Terraform is the idea of versioning.  This applies throughout the configuration, from the version of the terraform executable itself through to the version control (via SCM) for your .tf files, and also the modules that you are using.

As a result, the terraform executable can only be updated manually, outside of standard linux package management such as `sudo apt update && sudo apt full-upgrade` on Ubuntu.  The Terraform [releases](https://releases.hashicorp.com/terraform/) page lists out all of the versions, but does not include a 'latest' to adhere to that versioning ethos.  If you want a new version then you download that version and replace the one that you have.

The same applies to modules.  When you ran the `terraform get` it takes a copy of the modules and puts them into your `.terraform/modules` folder.  (For the local modules it uses a symbolic link instead.)  And if you run `terraform get` then it **will not** update modules if they already exist in that folder.  Instead you have to use `terraform get -update=true`. And you can include [version constraints](https://www.terraform.io/docs/modules/usage.html#module-versions) to ensure that you are using a known good version.

## Terraform Registry

There are a number of modules created for use at the [Terraform Registry](https://registry.terraform.io/) for all of the major Terraform providers.  This is comparable to the Azure Quickstart Templates repository in GitHub with contributions from both the vendors and from the wider community.

You will notice that AWS has by far the largest number of community contributed modules, although not many of those have been verified.  Azure is a distant second in terms of community contribution, although it has a similar number of verified modules from both Azure and Hashicorp

Browse one of the modules.  You'll notice the source path starts with `Azure/`, and the documentation shows examples in the readme, inputs, outputs, dependencies, resources etc.  In terms of standards this is a good guideline for your own modules.

You can also click on the source link and it will take you through to the GitHub repository.  Take a look at <https://github.com/Azure/terraform-azurerm-network> and you will see that it has a good README.md.  As mentioned before, for simple one level modules that most contributors stick to variables.tf, main.tf and outputs.tf.  This makes it easier for everyone using a module to see the inputs and the outputs, and have everything else hidden away in the main.tf.

## End of Lab 7

We have reached the end of the lab. You have introduced modules to your environment and started to think about how to make use of those to define your standards underpinning different deployments for various reference architectures or customer requirements.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-pre-012-lab7>.

In the next lab we will go a little bit deeper on Terraform state and how to manage and protect that in a multi-tenanted environment with multiple admins.

[◄ Lab 6: State](../lab6){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 8: Extending ►](../lab8){: .btn .btn--primary}