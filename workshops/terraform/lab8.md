---
layout: article
title: "Terraform Lab 8: Extending beyond ARM"
categories: null
date: 2018-11-02
tags: [azure, terraform, modules, infrastructure, paas, iaas, code, providers, api]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

In this lab we will look at other providers that can help with our Azure deployments. One of the reasons for choosing Terraform is the extensible support for multiple providers so that the same workflow and logic can be applied to various public and private cloud platforms.

The same provider extensibility also applies to supporting services and data plane configuration.  In this lab we will look at examples from Cloudflare and Datadog, and then we'll deploy an AKS Kubernetes cluster using a combination of the AzureRM provider for the control plane and the Kubernetes provider for the data plane.

We will also:

* evolve our use of modules with a nested module
* look at locals, keepers and the lifecycle meta-parameter
* use a more natural workflow to create and test a new module locally
* create a GitHub repo as an upstream and push up to it

Let's start by exploring alternative providers.

## Example Providers

Take a look at the range of [Terraform Providers](https://www.terraform.io/docs/providers/) available.  It is a wide and expanding list, covering a multitude of private and public cloud platforms, various applications, supporting technologies and cloud services such as public DNS.

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

[Cloudflare](https://www.cloudflare.com/dns/) offer a number of services including a fast authoritative public DNS servers on 1.1.1.1 and 1.0.0.1.  They are very fast in terms of DNS lookup latency and speed of DNS record propagation.

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

There are a number of different container orchestration technologies, but Kubernetes has essentially won that war and is now the *de facto* orchestrator technology for hyperscale cloud platforms.  If you are unfamiliar with Kubernetes then spend a few minutes to read the [Kubernetes core concepts](https://docs.microsoft.com/en-us/azure/aks/concepts-clusters-workloads).

The Terraform [Kubernetes Provider](https://www.terraform.io/docs/providers/kubernetes/index.html) has a couple of authentication options, and includes a wide array of resource types and also a couple of data types.  It can take a base Kubernetes cluster and its running components, and then schedule the Kubernetes resources, like pods, replication controllers, services etc.

But it does need a base Kubernetes cluster first...

## Azure Kubernetes Service (AKS)

In this lab we will create an Azure Kubernetes Service (AKS) cluster using the [azurerm_kubernetes_cluster](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html) resource type.  We will then use the Kubernetes provider to do additional configuration on top of the AKS deployment.  This lab will demonstrate how you can use multiple providers to achieve the end goal, and how to link them by using the exported attributes of one provider type as arguments to another provider type.

If you are not familiar with AKS then it is a Kubernetes cluster where you only have to pay for the compute nodes. If you want to see how it is created manually via the CLI then use this [tutorial]. A few key AKS features:

1. The Kubernetes management plane is provided as a free PaaS service!
1. [Open Service Broker for Azure](https://docs.microsoft.com/en-us/azure/aks/integrate-azure) (OSBA) simplifies integration with other Azure PaaS services
1. [Virtual kubelet provider](https://docs.microsoft.com/en-us/azure/aks/virtual-kubelet) for Azure Container Instances (ACI) enables limitless bursting (experimental open source project)

Note that we will only be using core AKS functionality in this lab, with a simple demo container image.

## Create the AKS module

We'll take this lab in stages.

1. Initialise the module area
1. Add API permissions to Azure Active Directory to your Terraform service principal
1. Define the terraform-module-aks module and the service_principal sub-module
1. Create an SSH key pair
1. Test locally with a customised providers.tf file
1. Commit locally
1. Add GitHub as a remote and push
1. Test as a module
1. Add the additional Kubernetes configuration
1. Retest

The terraform config in this section is loosely based on Nic Jackson's [blog post](https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform), updated with some of Lawrence Gripper's excellent [AKS repo](https://github.com/lawrencegripper/azure-aks-terraform).

## Initialise the module area

Create a local module area called terraform-aks-module by following the lab steps below. It is assumed that you are starting in the terraform-labs directory.

* Run the following commands to initialise the module area and open it in  a new VSCode window

```bash
mkdir -m 750 ../terraform-module-aks
cd ../terraform-module-aks
git init
touch variables.tf main.tf outputs.tf manifest.json
mkdir service_principal
touch service_principal/variables.tf service_principal/main.tf service_principal/outputs.tf
code .
```

## Insufficient directory permissions?

One feature of this lab is that it shows how to configure the Terraform service principal with sufficient API permissions to use the azurerm_service_principal resource type in order to create the AKS service principal on the fly.  There isn't a great deal of information available on the internet on how to have one service principal create another, so this lab helps to fill that gap.

However, you may be working in a subscription where you have insufficient directory authority to create users and groups and therefore you cannot successfully assign and use the additional API permissions (For instance this will be true for Microsoft employees using subscriptions associated with the microsoft.com directory.)

You can still complete the lab, but you'll have to skip the service_principal sub-module and associated API permissions for the Terraform service principal and tweak the main.tf accordingly.  Instead we'll hardcode the AKS service principal ID and secret values to those of your existing Terraform service principal.

There will be two sets of example files at the end of the lab to match whichever path you have taken.

> If you cannot create users and groups in your subscriptions directory then look out for sentences in the lab that mention **insufficient directory permissions**, or instructions blocks wrapped with HTML style **\<insufficient directory permissions>** _\<list of commands>_ **\</insufficient directory permissions>** tags.

If you have **insufficient directory permissions** then skip to the [main AKS module](#main-aks-module).

## Add the additional API permissions to your Terraform Service Principal

The [advanced configuration section](../lab5#advanced-service-principal-configuration) of Lab 5 explains both custom RBAC roles in ARM, and adding additional API permissions to the service principal's app registration.

This section adds the required API permissions for the legacy Azure Active Directory API (as per the note at the top of the [azurerm_service_principal](https://www.terraform.io/docs/providers/azurerm/r/azuread_service_principal.html) page).

* Add the following JSON into your manifest.json file:

```json
[
    {
        "resourceAppId": "00000002-0000-0000-c000-000000000000",
        "resourceAccess": [
            {
                "id": "311a71cc-e848-46a1-bdf8-97ff7156d8e6",
                "type": "Scope"
            },
            {
                "id": "1cda74f2-2616-4834-b122-5cb1b07f8a59",
                "type": "Role"
            }
        ]
    }
]
```

* Update the API permissions for your Terraform service principal's registered application:

```bash
subId=$(az account show --query id --output tsv)
appId=$(az ad sp show --id "http://terraform-${subId}-sp" --query appId --output tsv)
az ad app update --id $appId --required-resource-accesses @manifest.json
az ad app show --id $appId --query requiredResourceAccess
```

* Grant admin consent for the Default Directory via the portal: 
    * Navigate to Azure Active Directory (AAD)
    * Under the Manage list, select App registrations (Preview)
    * Ensure the All Applications tab is selected
    * Search for, and select the Terraform Service Principal application that we created previously (i.e. terraform-<subscriptionId>-sp)
    * Select API Permissions
    * Click the 'Grant admin consent for Default Directory' button
    * Click Yes on the confirmation prompt

![permissions](/workshops/terraform/images/permissions.png)

## Create the service_principal sub-module

The AKS service requires a service principal itself.  The service principal that is created will automatically be assigned the Contributor role on the new resource groups that the AKS provider deploys. Terraform has the ability to create service principals so we will make use of that. We'll keep it tidy by hiding those resource types in a sub-module.

* Open the service_principal sub-folder in the VSCode explorer
* Copy the following code block into the service_principal module's main.tf

```ruby
resource "azurerm_azuread_application" "aks_app" {
    name = "${var.sp_name}"
}

resource "azurerm_azuread_service_principal" "aks_sp" {
    application_id = "${azurerm_azuread_application.aks_app.application_id}"
}

resource "random_string" "aks_sp_password" {
    length  = 16
    special = true
    keepers = {
        service_principal = "${azurerm_azuread_service_principal.aks_sp.id}"
    }
}

resource "azurerm_azuread_service_principal_password" "aks_sp_password" {
    service_principal_id = "${azurerm_azuread_service_principal.aks_sp.id}"
    value                = "${random_string.aks_sp_password.result}"
    end_date             = "${timeadd(timestamp(), "8760h")}"

    lifecycle {
        ignore_changes = ["end_date"]
    }

    provisioner "local-exec" {
        command = "sleep 30"
    }
}
```

> Note that the password block includes a provisioner to locally sleep for 30 seconds, to give the app and service principal sufficient time to become available.  This is to overcome a current known [bug](https://github.com/terraform-providers/terraform-provider-azurerm/issues/1635). More on provisioners in the next lab.

**Question**:

What impact does the **keeper** value have on the service principal password?

**Answer**:

<div class="answer">
    <p>It ensures that the password is not changed unless the Service Principal ID is changed (i.e. it has been recreated).</p>
</div>

**Question**:

How long will the password be valid for?

**Answer**:

<div class="answer">
    <p>8760 hours = 1 year.</p>
</div>

**Question**:

What does the lifecycle meta-parameter do for the password?

**Answer**:

<div class="answer">
    <p>It manages the lifecycle of the resource, and ensures that the password is not changed if and when the end date is updated. You would have to use the Terraform [taint command](https://www.terraform.io/docs/commands/taint.html) to force a password to be recreated.</p>
</div>

* Copy the following code block into the service_principal module's outputs.tf

```ruby
output "sp_id" {
  value = "${azurerm_azuread_service_principal.aks_sp.id}"
}

output "client_id" {
  value = "${azurerm_azuread_service_principal.aks_sp.application_id}"
}

output "client_secret" {
  sensitive = true
  value     = "${random_string.aks_sp_password.result}"
}
```

The client ID and secret will be used by the azurerm_kubernetes_cluster resource in the parent.

* Copy the following code block into the service_principal module's variables.tf

```ruby
variable "sp_name" {
    description = "Service Principal name"
    type        = "string"
}
```

The only argument required by the service_principal is the name, which simplifies the main.tf that we'll be creating in the parent directory.  This is a good practice to adopt as it helps to make your modules readable and supportable.

OK, that is the sub-module finished. Let's move up a level and do the main AKS module.

## Main AKS module

* Close any open editing windows in vscode (using `CTRL`+`W`)
* Close up the service_principal folder in the Explorer
    * If you have **insufficient directory permissions** then you may delete the service_principal folder
* Add the following to the variables.tf

```ruby
variable "resource_group_name" {
   default =   "aks"
}

variable "location" {
   default =   "westeurope"
}

variable "ssh_public_key" {
   type         = "string"
   default      = ""
   description  = "Public key for aksadmin's SSH access."
}

variable "agent_count" {
   default =   2
}

variable "vm_size" {
   default =   "Standard_DS2_v2"
}

variable "tags" {
    default     = {
        source  = "citadel"
        env     = "testing"
    }
}
```

Every argument for this module has a default value, which will make testing easier. Note that the default for the SSH public key is an empty string. More on that in a moment.

* Add the following into the main.tf

```ruby
locals {
    cluster_name            = "aks-${random_string.aks.result}"
    default_ssh_public_key  = "${file("~/.ssh/id_rsa.pub")}"
    ssh_public_key          = "${var.ssh_public_key != "" ? var.ssh_public_key : local.default_ssh_public_key }"
}

module "service_principal" {
    source    = "service_principal"
    sp_name   = "${local.cluster_name}"
}

resource "azurerm_resource_group" "aks" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}

resource "random_string" "aks" {
  length  = 8
  lower   = true
  number  = true
  upper   = true
  special = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.cluster_name}"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${local.cluster_name}"
  depends_on          = [
      "module.service_principal"
  ]

  linux_profile {
    admin_username  = "aksadmin"

    ssh_key {
      key_data = "${local.ssh_public_key}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id       = "${module.service_principal.client_id}"
    client_secret   = "${module.service_principal.client_secret}"
  }

  tags              = "${var.tags}"
}
```

**\<insufficient directory permissions>**:

1. Modify the azurerm_kubernetes_cluster.aks block
    1. Remove the depends_on for module.service_principal
    1. Hardcode the service_principal stanza's values for client_id and client_secret to use the values in your provider.tf
1. Remove the module.service_principal block

**\</insufficient directory permissions>**

OK, this is the first time that we have actively used locals.  Locals are useful for generating values that will only be used within this individual .tf file.  (Locals are roughly similar to the variables section of an ARM template.)

The cluster name is a good example of a local variable, as it uses a random string appended to the aks- prefix, and is then referenced a few times throughout the main.tf.

The SSH key is another, as it allows us to overcome a limitation in Terraform.  You cannot use an interpolation within a variable definition's default value. If you remember, we defaulted the variable to an empty string.  The locals section defines a default value (based on the contents of the default name for an SSH public key), and then the local.ssh_public_key will default to that if the user has not passed in an SSH public key argument value.

* Add the following into the outputs.tf:

```ruby
output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.host}"
}
```

## SSH Public Key

OK, so we'll need an SSH key pair for this to work.  If you have one already then skip this section.

If not then create one using the command below in your home directory:

```bash
ssh-keygen -t rsa -b 2048 -C "richard.cheney@microsoft.com"
```

> Use your own email address for the comment field!

The `~/.ssh/id_rsa.pub` public SSH key will be used in the locals default. It will be used as the authentication for the aksadmin user.

## Specifying minimum provider versions

We will need the Terraform service principal credentials for full testing:

* Copy in the provider.tf file from the terraform-labs repo

We will need a minimum version of the azurerm provider for the AKS module to work.  Exploring this introduces a key tenet for Terraform regarding versioning.

As you already know, when you run terraform init, the required providers are copied locally. It is important to understand that those providers will *not* be upgraded unless you force that to happen.

Terraform has a philosophy around version management that enables you to collectively control the version of everything from top to bottom, i.e. the terraform executable, the individual Terraform providers and the terraform files themselves.  Therefore you have full control on when any of those are upgraded so that you know that nothing will become unexpectedly broken.

Take a look at the [azurerm changelog](https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/CHANGELOG.md).  This lists the new features, bug fixes and improvements that are rolled into each release.  If you require functionality of a newer release then you have a couple of options:

1. specify a [provider version constraint](https://www.terraform.io/docs/configuration/providers.html#provider-versions) in the provider block and run `terraform init`
1. run `terraform init -upgrade=true` to upgrade to the latest acceptable version of the modules

Specify a minimum version of 1.17 for the azurerm provider:

* Add a constraint to the azurerm provider block for a minimum version of 1.17 (or later)

> 1.17 is current at the time of writing; feel free to specify a more recent version if the changelog entry mentions new or updated azurerm_kubernetes_* provider types

* Run `terraform init`

Note that the output recommends that a minimum should be specified for the random provider:

```json
The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.random: version = "~> 2.0"
```

* Update the provider.tf and specify the recommended minimum version
* Show the required providers and any associated version constraints, using `terraform providers`

Example output:

```ruby
.
├── provider.azurerm ~> 1.17.0
├── provider.random ~> 2.0
└── module.service_principal
    ├── provider.azurerm (inherited)
    └── provider.random (inherited)
```

## Locally test the core AKS module

* Run `terraform init`
* Run `terraform plan`
* Run `terraform apply -auto-approve`

The cluster should take around 15 minutes to deploy, so a good time for a coffee. Once it has completed then check that the cluster is operating as expected.

* Create the Kubernetes config file using the AKS module's kube_config output:

```bash
umask 022
mkdir ~/.kube
echo "$(terraform output kube_config)" > ~/.kube/config
```

* Install kubectl using `sudo az aks install-cli`
* Check the cluster health using `kubectl get nodes`

```text
NAME                     STATUS   ROLES   AGE   VERSION
aks-default-38841400-0   Ready    agent   29m   v1.9.11
aks-default-38841400-1   Ready    agent   29m   v1.9.11
```

* Run the dashboard proxy using the kubectl proxy command
    * Use `kubectl proxy &` to run in the background
        * Run `jobs` to view running background jobs
        * Use `kill %1` to kill off background job 1
* Open the [dashboard](http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=default)

[![dashboard](/workshops/terraform/images/dashboard.png)](http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=default)

If your browser screen is similar to the image above then all is good.

## Add the Kubernetes configuration

Now it is time to introduce the kubernetes provider. We can use this to extend the configuration to not only create the AKS cluster, but to provision the pods and services on top.

* Append the following into your provider.tf file:

```ruby
provider "kubernetes" {
    version                 = "~> 1.3"
    host                    = "${azurerm_kubernetes_cluster.aks.kube_config.0.host}"
    client_certificate      = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)}"
    client_key              = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)}"
    cluster_ca_certificate  = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)}"
}
```

Note that the exported attributes of the azurerm_kubernetes_cluster are now being used by this provider, which also introduces an implicit dependency.

* Append the main.tf with the following resource type block:

```ruby
resource "kubernetes_pod" "test" {
  metadata {
    name = "terraform-example"
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "example"
    }
  }
}
```

We are now making use of a different [provider](https://www.terraform.io/docs/providers/) by using the [kubernetes_pod](https://www.terraform.io/docs/providers/kubernetes/r/pod.html) resource type.

* Run through the terraform init, plan and apply workflow
* Run `kubectl get nodes`
* Run `kubectl get pods`
* Rerun the `kubectl proxy` and check the [dashboard](http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=default)

If you can access the dashboard and see the two nodes and the single test pod then the module is successfully tested.

* Remove the cluster: `terraform destroy`

The destruction will take several minutes.  Whilst that is running you can move to the next section and push the module up to GitHub.

If you have **insufficient directory permissions** then your module will have hardcoded Terraform service principal id and secret values.  You can turn those into variables and continue, or skip to the [extending Terraform into ARM section](#extending-terraform-into-arm).

## Push to GitHub

You should already have a [GitHub account](https://github.com/join) from the earlier labs.

* Remove the Terraform service principal values from your provider.tf so that only the version argument remains
* Commit into your local repo
    * Add the files to the index `git add --all`
    * Commit the files `git commit -a -m "Initial commit"`
* Log onto [GitHub](https://github.com)
* Create a new repository called terraform-module-aks
    * Do not check the _Initialize this repository with a README_ box
* Copy the two commands for pushing an existing repository from the command line

Example commands:

```bash
git remote add origin https://github.com/richeney/terraform-module-aks.git
git push -u origin master
```

* Run the two commands in your local repository

Example output:

```yaml
/git/terraform-module-aks (master) $ git push -u origin master
Username for 'https://github.com': richeney
Password for 'https://richeney@github.com':
Counting objects: 13, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (13/13), done.
Writing objects: 100% (13/13), 2.86 KiB | 154.00 KiB/s, done.
Total 13 (delta 0), reused 0 (delta 0)
remote:
remote: Create a pull request for 'master' on GitHub by visiting:
remote:      https://github.com/richeney/terraform-module-aks/pull/new/master
remote:
To https://github.com/richeney/terraform-module-aks.git
 * [new branch]      master -> master
Branch 'master' set up to track remote branch 'master' from 'origin'.
```

The full module is now up in GitHub.

## Test the module hosted in Github

If you wish you can test the whole module.

We'll do this within your [Cloud Shell](https://shell.azure.com)'s home directory.

* Create a new lab8 folder in your home directory (`mkdir lab8`)
* Change directory (`cd lab8`)
* Create an empty aks.tf (`touch aks.tf`)
* Edit in the Monaco editor (`code .`)
* Add the following HCL into the aks.tf:

```ruby
provider "azurerm" {
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    subscription_id = "00000000-0000-0000-0000-000000000000"
}

module "aks" {
  source = "github.com/username/terraform-module-aks"
  agent_count = 4
}

output "cluster" {
  value = "${module.aks.cluster}"
}
```

* Change the tenant and subscription IDs to match those in `az account show --output json`
* Change the username
* Save and quit (`CTRL`+`S`, `CTRL`+`Q`)
* Export ARM_CLIENT_ID and ARM_CLIENT_SECRET environment variables
    * Set to the Terraform service principal's app ID and password (values in terraform-labs/provider.tf)
    * Example: `export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
    * Optionally add to your ~/.bashrc

* Run through the Terraform workflow
    * `terraform get`
    * `terraform init`
    * `terraform plan`
    * `terraform apply`

Once complete, you can use the following command to get the credentials for the ~/.kube/config file:

```bash
az aks get-credentials --name $(terraform output cluster) --resource-group aks
```

The command creates your ~/.kube/config file.  It is an alternative to the command you ran earlier that redirected the terraform kube_config output.

The kubectl binary is alfready included part of the Cloud Shell container image, so you can use that straight away without having to install:

```bash
kubectl get pods
```

For more commands check the Kubernetes [cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).

You can even open the dashboard directly from the Cloud Shell using this command:

```bash
az aks browse --enable-cloud-console-aks-browse --name $(terraform output cluster) --resource-group aks
```

Use `CTRL`+`C` to close the tunnel. You can then run `terraform destroy` to remove the cluster.

OK, that is lab element completed. Well done!

Whilst your cluster is being removed you can read through the next two sections to discuss some additional options

* Terraform driving native ARM template deployments
* ARM templates leveraging certain Terraform providers.

## Extending Terraform into ARM

One azurerm resource type that we have not discussed so far is [azurerm_template_deployment](https://www.terraform.io/docs/providers/azurerm/r/template_deployment.html).

There hase been a huge investment into the azurerm Terraform provider and it has excellent coverage of the most commonly used services.  However are some limitations:

* **coverage** - there are certain edge case services that are available as ARM resource types, and are not yet available as a Terraform resource type
* **lag** - inevitably there will be a period of lag as new Azure services are released, although prominent services such as AKS and Cosmos DB has been released close to the General Availability (GA) date

Terraform can initiate the deployment of an ARM template and have knowledge of the deployment.  Destroying the resource in Terraform will only destroy that knowledge of the deployment. For this reason it is recommended to create a separate resource group for the templated deployment so that removing both the resource group and the ARM deployment will remove the resources as well.

If an azurerm resource type then becomes available then a resource stanza can created and the existing resource(s) can be imported.  It will need careful configuration until a `terraform plan` doesn't show any creates, destroys or changes.  It would not be safe to configure new additions, deletions or changes until that steady state has been achieved.

## Extending ARM into Terraform

For information, ARM templates can now also drive certain Terraform providers as per the recent [blog](https://azure.microsoft.com/en-us/blog/introducing-the-azure-terraform-resource-provider/).

Whilst it is in public preview then the Cloudflare, Datadog and Kubernetes will be supported and then other providers will be added.

Azure Resource Manager will never drive other cloud providers, but it does allow ARM configurations to take advantage of the Terraform framework and extend the configuration beyond the functionality at the control plane level.

## End of Lab 8

We have reached the end of the lab. You have provisioned and configured a Kubernetes cluster on the AKS service, and looked at some of the other providers and provider types.  We have also leverage additional API permissions to create the AKS service principal on the fly.  We have worked through a sensible workflow to create and test a new module before publishing it and testing once more.

Your aks module should look similar to that in <https://github.com/richeney/terraform-module-aks>.

In the next lab we will also look at provisioners and how they can help to go beyond vanilla image deployments for your virtual machines.

[◄ Lab 7: Multi Tenancy](../lab7){: .btn-subtle} [▲ Index](../#labs){: .btn-subtle} [Lab 9: Provisioners ►](../lab9){: .btn-success}
