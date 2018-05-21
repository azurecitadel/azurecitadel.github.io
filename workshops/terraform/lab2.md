---
layout: article
title: "Terraform Lab 2: Variables"
categories: null
date: 2018-06-01
tags: [azure, terraform, modules, infrastructure, paas, iaas, code]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

In this lab we'll still be using the Cloud Shell, but we'll switch to using Visual Studio Code for our editing and leverage some of the extensions to integrate.

If you haven't done so already, install [vscode](/guides/vscode) and make sure that you have the following extensions installed:

**Module Name** | **Author** | **Extension Identifier**
Azure Account | Microsoft | [ms-vscode.azure-account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
Azure Terraform | Microsoft | [ms-azuretools.vscode-azureterraform](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform)
Terraform | Mikael Olenfalk | [mauve.terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)
Advanced Terraform Snippets Generator | Richard Sentino | [mindginative.terraform-snippets](https://marketplace.visualstudio.com/items?itemName=mindginative.terraform-snippets)

Use `CTRL+SHIFT+X` to open the extensions sidebar.  You can search and install the extensions from within there.

As you move through the lab you will start to make use of variables and multiple .tf files.  We'll modify existing resources and add new resources and new providers.

## Visual Studio Code

Before we start using variables etc., let's spend a little time getting vscode configured for us.  In this section we'll create a folder for our workspace and then set the workspace to default to linux friendly LF line endings for the Bash based Cloud Shell.

* Open Visual Studio Code
* Open Folder, by either:
    * clicking on the 'Open folder...' link in the Start section of the Welcome page,
    * clicking on File -> Open Folder, or
    * using the CTRL-K, CTRL-O keyboard shortcut chord
* Use the dialog box to create a new local folder for your lab files
    * This lab assumes C:\terraform\citadel as your local workspace
* Select the folder
* Type `CTRL+,` to open Settings:

![eol](/workshops/terraform/images/eol.png)

All of the available and defaulted settings are shown on the left, and they can then be overriden at the user or workspace level.

1. Click on Workspace Settings
    * As soon as you do then you will notice a .vscode/settings.json file is created in your workspace
1. Search for `eol`
1. Hover over the "files.eol" setting, click on the pen to edit it and select "\n"
1. Type `CTRL+S` to save your new workspace settings

OK, the area is ready.  Let's quickly recreate the main.tf file from the last lab with a new resource group name.

## Create the main.tf and push to Cloud Shell

* Create a new file in the root of the workspace called main.tf
    * Hover over the citadel bar in the explorer sidebar for the New File icon
    * if you accidentally created the main.tf file in the vscode subfolder then you can drag it into the blank area to move it up
* Paste in the contents of the codebox below

```yaml
resource "azurerm_resource_group" "citadel" {
  name      = "terraformCitadelWorkshop"
  location  = "West Europe"

  tags {
    environment = "Training"
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = "richeneysa1976"
  resource_group_name      = "${azurerm_resource_group.citadel.name}"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

This is the same file as we used in the last lab except that we have a new resource group name.  Don't forget to change your storage account name again.

Now that we are using vscode with the various plugins, we have a multitude of productivity gains, such as linting, intellisense, snippets, auto-complete. The .tf extension is automatically associated with Terraform.

![vscode](/workshops/terraform/images/main.tf.png)

1. It should now show LF rather than CRLF in the toolbar (from the workspace settings)
1. The round blob in the tab shows it is not saved - use `CTRL-S` to save it locally

Let's push it up to the Cloud Shell:

* Type 'CTRL+SHIFT+P` to open the Command Palette
* Type 'push' and select 'Azure Terraform: push'
* You'll be asked if you want to open Cloud Shell.  Click on OK
* Select the directory if your ID is linked to multiple tenancies
* Bash in Cloud Shell will open in the Integrated Console
* You will be prompted to confirm the push of project files from the current workspace to the Cloud Shell
* The files will be pushed up into a new ~/clouddrive/citadel directory in the Cloud Shell
    * Subsequent pushes will be much quicker
* In the Cloud Shell `cd clouddrive/citadel` and then `ls -l`

![Post push](/workshops/terraform/images/postpush.png)

You can now run through the terraform init, plan and apply workflow using the Command Palette (CTRL+SHIFT+P).  If you search on init, plan and apply you will find the commands from the Azure Terraform extension.  Running these also syncs the files up to Cloud Shell first.

Confirm that the services are up by checking in the portal of using the CLI.

## Introducing variables

One thing that is very useful in Terraform is to make use of multiple .tf files.  The terraform commands will look at all *.tf files in the current working directory.  (Note that by design it does _not_ recursively move through sub-directories.)

So let's create a variables.tf file in the citadel directory and define some of the key variables in there.

Create the variables.tf file in vscode and paste in the following:

```ruby
variable "rg" {
    default = "terraformCitadelWorkshop"
}

variable "loc" {
    default = "West Europe"
}

variable "tags" {
    type = "map"
    default = {
        environment = "training"
        source      = "citadel"
    }
}
```

Browse to the <https://aka.ms/terraform/docs> area, and navigate to the [variables](https://www.terraform.io/docs/configuration/variables.html) section.  You'll see that there are different ways to define the variables.  There are three types of valid variables, which are string, list or map.

> **💬 Note.** If you are familiar with ARM template then the Terraform variables are roughly synonymous with the parameters in ARM templates, and are used to declare what the user can specify.  They can also be used to define variables that can be used globally by all *.tf files in the current working directory (cwd).

The most commonly used variable argument is `default`. Terraform will infer the variable type from the default value.  If you do not have a default then it will default to string so if you want a list or map then you have to specify the `type` argument.

The `description` argument is optional but recommended, particularly when you are creating reusable modules in the later labs.

We could have added these lines to the top of our main.tf file, but it makes sense to have them in separate files.  It is the variables that commonly change between deployments, so moving them may allow the other *.tf files to be re-used without change.  Also we can use different file permissions for the variables file if required.

## Using strings

Let's edit our existing main.tf file and make use of the variables. The interpolation format for simple string variables is `"${var.<varname>}"`.

1. Change the resource group's name to use `"${var.rg}"`
1. Change the resource group's location to make use of the new `loc` variable
1. Change the location for the storage account and link it to the resource group's location
1. Save your files locally
1. Run a `terraform plan`

We may have introduced some simple string variables, but the plan output should indicate that there is nothing there that requires a change.

## Using lists

Lists are simple arrays.  We won't use them just yet, but now is the right time to cover them quickly. Here is an example declaration of a simple array:

```yaml
variable "webAppLocations" {
    default = [ "francecentral", "canadaeast", "brazilsouth", "japanwest" ]
}
```

Terraform will interpolate `"${var.webAppLocations[2]}"` as `brazilsouth`as the list index starts at zero.

**Question**:

What would be the interpolation syntax to return the number of Web App locations in the array?  (Search the [Terraform Docs](https://www.terraform.io/docs/index.html) area for an example.)

**Answer**:

<div class="answer">
    <p>"${length(var.webAppLocations)}"</p>
</div>

That's our first function. It won't be our last.

We will use use lists actively in the next lab when defining multiple subnets in our virtual network.  Let's move on to maps.

## Using maps

There is a 'tags' variable in the variables.tf file that is defined as a map.

```yaml
variable "tags" {
    type = "map"
    default = {
        environment = "training"
        source      = "citadel"
    }
}
```

We can pull out individual values.  For instance `"${var.tags['source']}"` would be evaluated as `citadel`.

Or we can pass in the full map using `"${var.tags}"`, which will be resolved to:

```json
{
    environment = "training"
    source      = "citadel"
}
```

Let's use the tags map for our resources:

* Change the tags for the resource group to use the variable map
* Set the tags on the storage account to inherit the tags of the resource group
* Prefix the storage account name with the value of the source tag
* Rerun the `terraform plan`

You should notice that the plan now shows some changes to be applied:

![Plan after tagging](/workshops/terraform/images/tagplan.png)

This is when the plan stage becomes very useful, to see the impact of a change or addition.  Doing something trivial such as modifying tags can be managed as a simple update, whereas a rename of a resource group or resource will require a more disruptive re-creation as the cosmetic names form part of each resource's unique Azure id. The same is true for other changes that cannot be handled by the Azure Resource Manager layer as an update.

![planSymbols](/workshops/terraform/images/planSymbols.png)

The plan stage removes the guess work in managing a system through infrastructure as code, not only showing you what will happen, and the order and dependencies of those changes, but also the reasons for certain actions such a re-create.

In the Cloud Shell, type `terraform --help plan`.  You will see a `--out` switch, that can be used to create a file of the plan. This may be used as a record of the change for change management systems, and may also be an input for the `terraform apply` stage.  The `terraform apply` will run the plan first by default, except when it is fed a serialised plan file.

There is no capability to revert to a previous configuratiom directly within Terraform itself.  Instead you need to leverage source code management (SCM) systems to roll back to a previous set of configuration files and then run the plan and apply stages.  In the next lab we will make use of a personal GitHub repository.

OK, let's apply that change:

* Run `terraform apply`

## Additional Terraform providers

First of all, as you know, Terraform supports multiple [providers](https://www.terraform.io/docs/providers/), from public and private cloud providers, through configuration management software such as Chef, application providers such as RabbitMQ and Kubernetes, a number of public DNS providers (e.g. Cloudflare)  and monitoring software such as Datadog.  It also has a number of miscellanous providers to extend the core functionality, such as those interacting with file and zips using the _local_, _archive_ and _template_ resource types.

We will use the random_id provider type to create an eight character random code. Find the Terraform provider page and read it through.  Note the _keeper_ map argument.  This allows us to re-use random values based on a criteria, under the concept of managed randomness.

## Defining unique names using random_id

Those who have done the [ARM workshop](https://aka.ms/citadel/arm) will remember that the storage account names need to be unique as it forms part iof the external FQDN of the public endpoint.  The shortname needs to be 3-24 characters of lowercase alphanumerics. We'll quickly cover how to do that as it introduces a couple of key concepts.

OK, let's add that into our configuration and use it in our storage account name. There will be a little less hand holding in this section:

* Add in a new resource
* Use random_id as the provider type
* Specify the id as "rnd"
* Use the resource group id as the keeper
    * Check the [Azure resource group page](https://www.terraform.io/docs/providers/azurerm/r/resource_group.html) to see which attributes are exported
* Set the bytes length to 8

* Configure the storage account name to use the random value
    * Start the name with 'sa'
    * Concatenate with the value of the source tag
    * Suffix with the random value
    * The random_id has a few options for the outputs, so check the page and choose an appropriate one

Save the file and then run `terraform plan` to see the impact.

The command should show that you haven't got all of the required providers:

```yaml
richard@Azure:~/clouddrive/terraform-lab2$ terraform plan
Plugin reinitialization required. Please run "terraform init".
Reason: Could not satisfy plugin requirements.

Plugins are external binaries that Terraform uses to access and manipulate
resources. The configuration provided requires plugins which can't be located,
don't satisfy the version constraints, or are otherwise incompatible.

1 error(s) occurred:

* provider.random: no suitable version installed
  version requirements: "(any version)"
  versions installed: none

Terraform automatically discovers provider requirements from your
configuration, including providers used in child modules. To see the
requirements and constraints from each module, run "terraform providers".


Error: error satisfying plugin requirements

```

Run the `terraform init` command to pull down the random provider, and then run through the `terraform plan` and `terraform apply` steps.

**Question**:

Which of random_id's exported attributes can be used?

**Answer**:

<div class="answer">
    <p>Either .hex or .dec can be used. The .hex value is shorter. You cannot use the b64_url or b64_std as they may include uppercase and special characters.</p>
</div>

**Question**:

If you wanted to ensure that the storage account name never exceeded 24 characters then which interpolation function could you use?

**Answer**:

<div class="answer">
    <p>substr(string, offset, length)</p>
</div>

## Using terraform console

You may use `terraform console` to query the values of graph database entities.  The console command creates a REPL, or Read-Evaluate-Print-Loop.

Enter in the values of Below is an example:

```yaml
richard@Azure:~/clouddrive/citadel$ terraform console
> var.rg
terraformCitadelWorkshop
> var.tags
{
  "environment" = "training"
  "source" = "citadel"
}
> random_id.rnd.hex
368e6a50844e
> random_id.rnd.dec
59985296917582
> azurerm_resource_group.citadel.id
/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/terraformCitadelWorkshop
> azurerm_storage_account.sa.name
sacitadel368e6a50844e
> azurerm_storage_account.sa.account_tier
Standard
> exit
Releasing state lock. This may take a few moments...
```

## End of Lab 2

We have reached the end of the lab. You have started to use variables and functions, and we are now working within Visual Studio Code.

Your .tf files should look similar to those in <https://github.com/richeney/terraform-lab2>.

We will scrap everything we've created to date.  Run a `terraform destroy` to remove the environment. Remove your local lab directory containing the variables.tf and main.tf files.

In the next lab we will start to create the core of a more substantial Azure environment and base it in GitHub.

[◄ Lab 1: Basics](../lab1){: .btn-subtle} [▲ Index](../#lab-contents){: .btn-subtle} [Lab 3: Outputs ►](../lab3){: .btn-success}