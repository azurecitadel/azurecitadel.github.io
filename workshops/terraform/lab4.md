---
layout: article
title: "Terraform Lab 4: Meta Parameters"
categories: null
date: 2018-06-05
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

You can go a long way with Terraform making use of hard coded stanzas or defaulted variables.  If you have a simpler configuration or don't mind manually editing the files to configure the variables then this is a simple way to manage your Terraform files.  However we are looking to build up reusable IP that will work in a multi-tenanted environment, and will prove to be more robust over time as we update those building blocks.

In this lab we will leverage some of the functions and meta parameters that you can use within HCL.  Some of the richer configuration examples that you see will make extensive use of these meta parameters.  We'll also look at the various ways that we can define variables.

## Reference documentation

There are a few key pages on the Terraform site that you will come back to often:

[Interpolation Syntax](https://www.terraform.io/docs/configuration/interpolation.html) | Variables, conditionals, functions, count, mathematical operations
[Variables](https://www.terraform.io/docs/configuration/variables.html)| Strings, lists, maps, booleans, environment variables and variable files
[Locals](https://www.terraform.io/docs/configuration/locals.html) | Local values and how to use them
[Data Sources](https://www.terraform.io/docs/configuration/data-sources.html) | Using data sources
[Outputs](https://www.terraform.io/docs/configuration/outputs.html) | Defining outputs

## Interpolation

You have been using interpolation as Terraform has interpreted everything wrapped in `"${ ... }"`. So far this has been limited to referencing variables (e.g. `"${var.loc}"`) or the attributes of various resource types (e.g. `"${azurerm_resource_group.nsgs.location}"`).  Terraform has a rich syntax covered on the [interpolation syntax](https://www.terraform.io/docs/configuration/interpolation.html) page.

* Scroll through the page to familiarise yourself with the breadth of capability

**Question**:

How could you reference the location within the current resource stanza?

**Answer**:

<div class="answer">
    <p>"${self.location}"</p>
</div>

**Question**:

If you had a boolean variable for createResource then how could you use count to control the resource creation?

**Answer**:

<div class="answer">
    <p>"${var.createResource ? 1 : 0}"</p>
</div>

**Question**:

What ios the difference between `"${var.index-count - 1}"` and `"${var.index-count-1}"`

**Answer**:

<div class="answer">
    <p>The first subtracts 1 from the index-count variable and the second returns the index-count-1 variable.</p>
</div>

## Initial webapp.tf file

Count is one of the more useful meta parameters, and allows for multiple resources to be configured.  Let's work through an example to get some familiarity with it.  We'll use the web app PaaS service, and deploy them to multiple locations

* Change the existing loc variable from "West Europe" to the shortname "westeurope"
* Create a new webapplocs list variable
    * Set the default to contain the shortnames of a few regions from `az account list-locations --output table`
* Create a new webapps.tf file
    * Define a new resource group called **webapps**
        * Use the loc and tags variables as per normal
        * Note that the resource group location only determines the region for the resource group's metadata
    * Add in the following code block which deploys a free tier plan and a linux web app to a single region

```ruby
resource "random_string" "webapprnd" {
  length  = 8
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "azurerm_app_service_plan" "free" {
    name                = "plan-free-${var.loc}"
    location            = "${var.loc}"
    resource_group_name = "${azurerm_resource_group.webapps.name}"
    tags                = "${azurerm_resource_group.webapps.tags}"

    kind                = "Linux"
    sku {
        tier = "Free"
        size = "S1"
    }
}

resource "azurerm_app_service" "citadel" {
    name                = "webapp-${random_string.webapprnd.result}-${var.loc}"
    location            = "${var.loc}"
    resource_group_name = "${azurerm_resource_group.webapps.name}"
    tags                = "${azurerm_resource_group.webapps.tags}"

    app_service_plan_id = "${azurerm_app_service_plan.free.id}"
}
```

* Save your files
* Run through the Terraform init, plan and apply workflow to test the deployment
* Show the id for the plan: `echo azurerm_app_service_plan.free.id | terraform console`
* Show the web address: `echo azurerm_app_service.citadel.default_site_hostname | terraform console`

> If you haven't done so for a while then now would be an excellent time for a git commit and push.

## Using count

OK, we'll now modify those two stanzas to make it multi-region.  This is done by using the count meta parameter, which may be as set to something simple such as `count = 2` or a numeric variable.  However we'll set this to the number of locations we have in the webapplocs list variable.  

We can then reference `${count.index}` in the stanzas.  Remember that we can slice out a single list element. For instance you can select the first element of a variable called myList using `${var.myList[0]}`.

* Add a new count value based on the length of the webapplocs list variable
    * This was one of the questions in lab 2
* Change the azurerm_app_service_plan.free and azurerm_app_service.citadel stanzas
    * Change location to the correct webapplocs element using `${count.index}`
    * Change the resource name to use the same region shortname as a suffix, replacing `${var.loc}`
* Save the webapps.tf file

Again, if you are struggling then you can 

If you run the terraform plan at this point then it should error, saying that it can no longer find `azurerm_app_service_plan.free.id`.  Now that we are using count for the app service plans, we are creating a list of resources. This introduces a special variable form called the splat. Rather then the single `azurerm_app_service_plan.free.id`, we now have `azurerm_app_service_plan.free.*.id`. And you can pull out a single element from that list using the `element()` function.

* Change the app_service_plan_id attribute value to `"${element(azurerm_app_service_plan.free.*.id, count.index)}"`
* Run the terraform plan and apply steps
* List out all of the app service plan ids and web app hostnames using the splat operator:
    * `echo "azurerm_app_service_plan.free.*.id" | terraform console`
    * `echo "azurerm_app_service.citadel.*.default_site_hostname" | terraform console`

One really nice feature of the element() function is that it automatically wraps, acting like a mod operator.  So if you wanted to have a number of web apps at each location you could create a new variable, multiply up the count and use the index directly in the naming convention. Here is an example of the two stanzas plus a local variable:

```ruby
locals {
    webappsperloc   = 3  
}

resource "azurerm_app_service_plan" "free" {
    count               = "${length(var.webapplocs)}"
    name                = "plan-free-${var.webapplocs[count.index]}"
    location            = "${var.webapplocs[count.index]}"
    resource_group_name = "${azurerm_resource_group.webapps.name}"
    tags                = "${azurerm_resource_group.webapps.tags}"

    kind                = "Linux"
    sku {
        tier = "Free"
        size = "S1"
    }
}

resource "azurerm_app_service" "citadel" {
    count               = "${ length(var.webapplocs) * local.webappsperloc }"
    name                = "webapp-${random_string.webapprnd.result}-${element(var.webapplocs, count.index)}-${count.index + 1}"
    location            = "${element(var.webapplocs, count.index)}"
    resource_group_name = "${azurerm_resource_group.webapps.name}"
    tags                = "${azurerm_resource_group.webapps.tags}"

    app_service_plan_id = "${element(azurerm_app_service_plan.free.*.id, count.index)}"
}
```

That could be a little by using format to set leading zeros for a better naming convention, but proves the point:

![Multiple Web Apps in multiple locations](/workshops/terraform/images/webappsperloc.png)

OK, so that is the basics for using copy.  For those who are familiar with copy in ARM templates then it is roughly comparable with some important differences:

1. ARM supports copy at both the resource and sub-resource level (for those array defined sub-resources such as subnets, data disks, NICs etc.)
1. Terraform supports count at the resource stanza level only
1. Not all Terraform resource types support the use of the count meta parameter
1. Support for ARM's array sub-resource types in Terraform definitely varies, for example:
    * subnets (vNet sub-resource) have their own provider type (azurerm_subnet) in Terraform and count can therefore be used
    * data disks are sub-stanzas in the azurerm_virtual_machine provider type and count is not supported at that level even if defined elsewhere with azurerm_managed_disk and then attached
    * NICs are supported using the azurerm_network_interface and the NIC ids can be passed as a list to the azurerm_virtual_machine stanza as network_interface_ids

Terraform and Microsoft have been actively working together to improve the azurerm provider support and there has been a huge amount of progress to date. These anomalies will be addressed as the devs work through the enhancements list as part of the continual improvement.

## Variables

ADD IN INFO ABOUT VARIABLES, LOCALS AND OUTPUTS

## End of Lab 4

We have reached the end of the lab. You have made use of count and count.index and also been introduced to a few other areas such as locals and outputs.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab4>.

You should now be able to create some pretty rich building blocks.  In the next lab we will look at how they can be converted to modules.

[◄ Lab 3: Core](../lab3){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 5: Modules ►](../lab5){: .btn-success}