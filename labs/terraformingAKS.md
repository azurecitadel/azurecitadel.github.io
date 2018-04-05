---
layout: article
title: Lab Terraforming Azure Kubernetes Service (AKS)
date: 2018-03-15
categories: labs
author: Richard_Cheney
image:
  feature: 
  teaser: cloud-builder.png
  thumb: 
comments: true
excerpt: Use Terraform's AzureRM provider to drive Infrastructure as Code.
published: true
---

{% include toc.html %}

## Introduction

This self serve lab will get you set up to run Terraform to orchestrate Azure resources using infrastructure (and more) as code, and then set you a number of challenges to increase your familiarity with the product and how it works.

This lab is provided as an intentionally challenging hackathon style lab, as a little pain tends to make the learning stick.  It is also a placeholder whilst we work on a fuller set of labs to mirror the depth of the ARM workshop.

The short URL for this page is <https://aka.ms/citadel/terraform>.

## Prereqs

You'll need an Azure subscription.

Before starting you should have a read through of the Terraform [intro](https://www.terraform.io/intro/index.html) and [AzureRM provider](https://aka.ms/terraform) areas so that you have some familiarity with the following:

* Terraform and the AzureRM provider
* Terraform workflow (init -> plan -> apply)
* Terraform state (build, change, destroy)
* Implicit and explicit resource dependencies and terraform graph
* Input and output variables, list and maps (defined, file, switch, variables, environment variables)
* Modules and the Terraform Registry
* Custom ARM deployments triggered by Terraform

Useful links

* [Terraform docs for AzureRM provider](https://aka.ms/terraform)
* [Azure Docs hub for Terraform](https://docs.microsoft.com/en-gb/azure/terraform/)
* [Terraform page in Linux VM area](https://aka.ms/terraformdocs) (useful one pager)

## Connection options for the Terraform Azure Provider

There are three options for connecting to Azure with the Terraform AzureRM provider. Each is described below with the most appropriate use case.

Connection Type | Use case scenario
Azure CLI | Single user for demo or test/dev
Managed Service Identity | VM level trust and authentication.  Designed for team use within a subscription.
Service Principal | Credentials for subscription included in Terraform files.  Centralised systems for multi-tenancy / subscriptions, automation platforms such as CI/CD pipelines and other orchestration tools.

## Terraform provider authenticated with the Azure CLI

If you are logged in with the Azure CLI then it will use that authentication by default.

This is only really suitable for single user environments, so personal test and dev and for demonstration purposes.

### Terraform provider authenticated with the Azure CLI - Cloud Shell

If you are using the Cloud Shell then you will already be logged into Azure, although you may want to use `az account list` and `az account set --subscription <subscriptionId>` to change your default subscription.

Both az and terraform are maintained packages in the bash Cloud Shell container image.

Type `terraform` and you'll see the command help.

### Terraform provider authenticated with the Azure CLI - Windows Subsystem for Linux

The following have been tested on the Ubuntu version of WSL.

Install the Azure CLI from <https://aka.ms/GetTheAzureCli> if you haven't done so already.

You may also want to install jq: `sudo apt-get --assume-yes install jq`.

Install Terraform.  Either:

1. Download the zip from <https://www.terraform.io/downloads.html> and extract the terraform executable to somewhere within your path such as /usr/local/bin
2. Or if you are feeling trusting then run the following code block:

```bash
curl --output terraform.zip https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
sudo bash <<"EOF"
apt-get --assume-yes install zip
unzip -o terraform.zip terraform -d /usr/local/bin && rm terraform.zip
chown root:root /usr/local/bin/terraform
chmod 755 /usr/local/bin/terraform
EOF
```

Use `az login` and `az account set --subscription <subscriptionId>` to login to the correct subscription.

Run the `terraform` command.

## Terraform provider authenticated with Managed Service Identity

Managed Service Identity (MSI) is perfect for allowing code to run on a virtual machine.  You have an automatically managed identity for logging into Azure without passing credentials in the code.

Once configured you can set the `use_msi` provider option in Terraform to `true` and the virtual machine will retrieve a token to access the Azure API.  In this context MSI allows all users on that trusted machine to share the same authentication mechanism when running Terraform.

MSI is the authentication mechanism used by the Terraform offering in the Azure Marketplace. See the section below for information on the offering and how to spin it iup within your subscription.

Be aware that Terraform is also capable of deploying virtual machines that are configured with their own managed service identities.

## Terraform provider authenticated with a Service Principal

Making use of a Service Principal for the authentication is the most appropriate route if embedded into another automation framework such as a CI/CD pipeline.

It make uses of a set of variables or environment variables. If the  variables are separated out into their own .tf file(s) then they may be customised for the customer or project and therefore the other .tf files are more portable. The same applies to using environment variables, which may then be exported in config files.

This lab will not make use of Service Principals, but you may still find the following useful. The commands assume that you have jq installed, are already logged in via the Azure CLI and have the correct subscription selected.

Create the Service Principal and login:

```bash
subscriptionId=$(az account show --output tsv --query id)
echo "az ad sp create-for-rbac --role=\"Contributor\" --scopes=\"/subscriptions/$subscriptionId\""
spout=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscriptionId" --output json)
jq . <<< $spout

clientId=$(jq -r .appId <<< $spout)
clientSecret=$(jq -r .password <<< $spout)
tenantId=$(jq -r .tenant <<< $spout)

az login --service-principal --username $clientId --password $clientSecret --tenant $tenantId
```

Check that the login is successful using any CLI command such as `az account list-locations --output table` or `az account show --output jsonc`.

Create a azureProviderAndCreds.tf file with the information:

```bash
echo "provider \"azurerm\" {
  subscription_id = \"$subscriptionId\"
  client_id       = \"$clientId\"
  client_secret   = \"$clientSecret\"
  tenant_id       = \"$tenantId\"
}
" > azureProviderAndCreds.tf && chmod 640 azureProviderAndCreds.tf
```

Alternatively, export ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_TENANT_ID.

Your Azure Provider section then only needs to contain `provider "azurerm" { }`.

If you also want to back off your terraform.tfstate file to blob storage then you can run the commands below to create a new resource group and storage account within the subscription and then a new remoteState.tf file to configure the Azure backend correctly.  The commands follow on naturally from the commands above, i.e. they assume that you are logged in with the Service Principal. Oh, and if you already have a remoteState.tf then these commands _will_ merrily overwrite it.

```bash
subscriptionId=$(az account show --output tsv --query id)
az group create --name "terraform" --location "westeurope"
saName=terraformstate$(tr -dc "[:lower:]" < /dev/urandom | head -c 10)
az storage account create --name $saName --kind BlobStorage --access-tier hot --sku Standard_LRS --resource-group terraform --location westeurope
saKey=$(az storage account keys list --account-name $saName --resource-group terraform --query "[1].value" --output tsv)
az storage container create --name tfstate --account-name $saName --account-key $saKey

echo "terraform {
  backend \"azurerm\" {
  storage_account_name = \"$saName\"
  container_name       = \"tfstate\"
  key                  = \"$subscriptionId.terraform.tfstate\"
  access_key           = \"$saKey\"
  }
}
" > remoteState.tf && chmod 640 remoteState.tf
```

In this example I have included the subscriptionId in the naming convention for the storage blob.

## Spin up a Terraform VM from the Marketplace

Support for Terraform in Azure is already strong, but has been strengthened further with the addition of Terraform VM in the Marketplace.  This is ideal for customers who want to use a single Terraform instance across multiple team members, multiple automation scenarios and shared environments.

The offering is at <https://aka.ms/aztf> and is free except for the underlying VM hardware resource costs. The Ubuntu VM will have the following preconfigured:

* Terraform (latest)
* Azure CLI 2.0
* Managed Service Identity (MSI) VM Extension
* Unzip
* JQ
* apt-transport-https

It features:

* Shared remote state with locking, backed off to Azure Storage
* Shared identity using MSI and RBAC

--------------

### SETUP: Spin up a Terraform VM

Spin up a B1s Terraform VM in your subscription. This will take around 15 minutes to deploy, so a good time to get a coffee.

```bash
$ az vm list-ip-addresses --name Terraform --resource-group terraform --output table
VirtualMachine    PublicIPAddresses    PrivateIPAddresses
----------------  -------------------  --------------------
Terraform         52.174.86.74         10.0.0.4
```

Check that you can SSH to the machine using Putty, WSL Ubuntu or Cloud Shell.  

There is also an Azure Docs page at <https://aka.ms/aztfdoc> which covers how to access and configure the Terraform VM by running the `~/tfEnv.sh` script. Note that if you have multiple subscriptions then myou should make sure that you are in the correct one (using `az account list --output table` and `az account set --subscription <subscriptionId>`) and then run just the role assignment command within the `tfEnv.sh` file.

One of the nice features of the Terraform VM Marketplace offering is that it will automatically back off the local terraform.tfstate to blob storage, with locking based on blob storage leases. It also creates a remoteState.tf file for you in your home directory. The remoteState.tf has the following format:

```json
terraform {
 backend "azurerm" {
  storage_account_name = "storestatelkbfjngsqkyiim"
  container_name       = "terraform-state"
  key                  = "prod.terraform.tfstate"
  access_key           = "6Wbo0IfW3YKRbsjeF9LFxyvlA2dJ8cJQF+ys6ZHIkW8GdBemXB20MGv66E+Nxx5Wi5KjeCXuVF7BcMo1OPAZYw=="
  }
}
```

Note that the "key" is the name of the blob that will be created in the terraform-state container.

#### Optional group setting configuration

By default you'll be in your home directory.  You can check the `/etc/passwd` and `/etc/group` files to show your default group.

You could use it like this if you were the only one working on the deployment. But if you were working as a team of Terraform admins for a deployment then you'd probably want to add a group of admins and a shared area for the Terraform files. (And optionally change the default group for your ID.) E.g.:

```bash
$ sudo addgroup terraform
Adding group 'terraform' (GID 1001) ...
$ sudo usermod --group terraform richeney
$ sudo mkdir --mode 2775 /terraform
$ sudo chgrp terraform /terraform
$ ll -d /terraform
drwxrwsr-x 2 root terraform 4096 Mar 19 11:19 /terraform/
```

Only members of the new terraform group will be able to create files in the /terraform folder.  The setgid permission ensures that all new files will automatically be assigned terraform as the group rather than the user's default group. You may need to log out of the Terraform VM and then log back in again to reflect the usermod change to the /etc/passwd file.

### SETUP: Test the Terraform flow

We'll check your configuration with a test deployment. Make a directory called deleteme and copy in the remoteState.tf file. (Don't `cd /terraform` if you didn't do the optional group work above.)

```bash
umask 002
cd /terraform
cp ~/tfTemplate/remoteState.tf .
cp ~/tfTemplate/azureProviderAndCreds.tf .
```

Create a file called deleteme.tf using the editor of your choice (e.g. nano or vi) and paste in the following section:

```yaml
resource "azurerm_resource_group" "deleteme" {
  name     = "deleteme"
  location = "West Europe"

  tags {
    environment = "test"
  }
}
```

Initialise the directory for Terraform by running `terraform init`:

```bash
richeney@Terraform:/terraform$ terraform init

Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "azurerm" (1.3.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.azurerm: version = "~> 1.3"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

This configures the .terraform sub-directory, automatically downloading the plugins for the providers in your various *.tf files and initialising the terraform.tfstate file.

See the execution plan by running `terraform plan`:

```bash
richeney@Terraform:/terraform$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.deleteme
      id:               <computed>
      location:         "westeurope"
      name:             "deleteme"
      tags.%:           "1"
      tags.environment: "test"


Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

That looks fine. Run `terraform apply` to deploy the resource group.

```bash
richeney@Terraform:/terraform$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.deleteme
      id:               <computed>
      location:         "westeurope"
      name:             "deleteme"
      tags.%:           "1"
      tags.environment: "Technical Depth"


Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.deleteme: Creating...
  location:         "" => "westeurope"
  name:             "" => "deleteme"
  tags.%:           "" => "1"
  tags.environment: "" => "Technical Depth"
azurerm_resource_group.deleteme: Creation complete after 1s (ID: /subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62/resourceGroups/deleteme)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Not the most exciting first deployment, but we're off an running. And more importantly if you check your storage accounts in the resource group for your terraform VM then you can see that the state is being backed up:

![state backed up to blob](/labs/terraformingAKS/images/blob.png)

You have a choice for tidying up before moving on to the challenges.  You could either:

* delete the deleteme.tf file and then rerun both the plan and apply commands
* run `terraform destroy` and then `rm deleteme.tf`

OK, once you have cleaned up then you should be good to head into the challenges. Don't forget those useful links:

* [Terraform docs for AzureRM provider](https://aka.ms/terraform)
* [Azure Docs hub for Terraform](https://docs.microsoft.com/en-gb/azure/terraform/)
* [Terraform page in Linux VM area](https://aka.ms/terraformdocs) (useful one pager)

--------------

## Challenge 1: Spin up a standard VM of your choice

Use Terraform to deploy a virtual machine into a new resource group.

Add in the following tags: environment = 'test' and description = 'Technical Depth'. (In fact please do this for all of the challenges.)

* Create a variables.tf file for the resource group name and the virtual machine name
* Define the resource group in a resourceGroups.tf file
* Define a diagnostics storage account with randomly generated text in the name
* Define the networking (virtual network, subnet, NSG) in a network.tf file
* Define the VM (including NIC and PIP) in a vm.tf file
* Use the virtual machine name that to create the PIP and NIC names (e.g. `<vmname>-nic`)

Don't forget to look at the useful links (and some of the surrounding pages in those areas) to find "inspiration".

And if you get really stuck then feel free to look at some example files [here](https://github.com/azurecitadel/terraform/tree/master/challenge1).

--------------

## Challenge 2: Terraform Outputs

Modify your Challenge 1 Terraform scripts to output the IP address of the VM you created.  Call the variable *ip*.  Test this work by calling

```bash
terraform output ip
```

after you have applied the updated Terraform script.

--------------

## Challenge 3: Spin up a Cosmos DB and ACI

Create a new resource group containing a Cosmos DB and an ACI deployment.

Cosmos DB:

* Set the API to `MongoDB`
* Set consistency level to `Session`
* Make `West Europe` the primary region, with failover to `East US`
* Calculate a random 8 byte code for the FQDN

_Question: which consistency level is not currently supported by the Terraform provider?_

ACI

* Public IP
* Linux container
* 0.5 CPU, 1.5 memory, port 80
* For the container image on DockerHub, use either of the following:
  * Microsoft's [aci-helloworld](https://hub.docker.com/r/microsoft/aci-helloworld/) image
    * In the environment variables section set `"NODE_ENV" = "testing"`
    * Note that this container image will not make use of your CosmosDB
  * Justin Davies' more interesting [iexcompanies](https://hub.docker.com/r/inklin/iexcompanies) image
    * The environment variable section needs `"COSMOSDB"="mongodb://cosmosdbname:cosmosdbprimarykey@cosmosdbname.documents.azure.com:10255/?ssl=true&replicaSet=globaldb"`
    * You should be able to use reference variables for both cosmosdbname and cosmosdbprimarykey to generate that environment variable dynamically
* Also run the aci-tutorial-sidecar
  * Same size - 0.5 CPUs and 1.5 memory
  * This container starts watchdog.sh which runs `watch -n 3 curl -I http://localhost:80`
  * No need to open any ports

Again, if you get stuck then feel free to look at some example files [here](https://github.com/azurecitadel/terraform/tree/master/challenge3).

--------------

## Challenge 4: Spin up an AKS cluster with a single B series for the afternoon

Remove the ACI deployment from the previous challenge.

Create a new resource group for the AKS cluster to use.

AKS needs a separate Service Principal to run correctly. There is an [enhancement request](https://github.com/terraform-providers/terraform-provider-azurerm/issues/16) to add this in to the provider, but in the meantime you'll have to do it via the Azure CLI. However, you should be able to to the RBAC role assignment to the new resource group.

Add in a single node AKS cluster:

* Single node
* Set the size to B1ms VM
* 30 GiB SSD

The final set of example files for this challenge are [here](https://github.com/azurecitadel/terraform/tree/master/challenge4).

--------------

## Optional Challenge: Automate ACI Integration

If you have time, automate the deployment of the ACI connector (using the virtual kubelet) without any manual steps.

As a helping hand, this [script](terraformingAKS/init_aci_connector.sh) would need to be passed the AKS cluster name and resource group to carry out this task.