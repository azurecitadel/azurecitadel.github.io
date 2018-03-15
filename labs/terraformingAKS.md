---
layout: article
title: Lab Terraforming Azure Kubernetes Service (AKS)
date: 2018-02-23
categories: internal
author: Richard_Cheney
image:
  feature: 
  teaser: cloud-builder.jpg
  thumb: 
comments: true
excerpt: Use Hashicorp's Terraform in the Cloud Shell to create an AKS environment and then burst containers to ACI.
published: true
---

{% include toc.html %}

<https://www.danielstechblog.info/deploying-kubernetes-aci-connector-aks-managed-kubernetes-azure/>

## Introduction

Add 

## Prereqs

If you are using the Cloud Shell then the tools are preinstalled.  You may need to add jq: `sudo apt-get install jq`.

If using the Windows Subsystem for Linux:

1. <https://aka.ms/GetTheAzureCli>
    * The install kubectl: `az aks install-cli`

2. <https://www.terraform.io/downloads.html>
    * Download the zip and extract the terraform executable to somewhere within your path such as /usr/local/bin
    * Or you are free to make use the following code block if you are feeling trusting:

```bash
curl --output terraform.zip https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip

sudo bash <<"EOF"
apt-get --assume-yes install zip
unzip -o terraform.zip terraform -d /usr/local/bin && rm terraform.zip
chown root:root /usr/local/bin/terraform
chmod 755 /usr/local/bin/terraform
EOF
```

3. Install jq: `sudo apt-get install jq`

4. Install Helm:

```bash
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

# Set up the service principal

There are three ways for the Terraform AzureRM provider to interact with the platform:

1. Azure CLI (when running Terraform locally)
2. Service Principal (shared environments, automation, CI/CD)
3. Managed Service Identity (MSI) (from authorised VM)

We will use the Service Principal. Details from this section are from <https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html>.

Login and set your subscription if you haven't done so already:

```bash
az login
az account list --output table
az account set --subscription=<subscriptionId>
```

The following commands will then create the service principal, and login using that.

```bash
subscriptionId=$(az account show --output tsv --query id)
echo "az ad sp create-for-rbac --role=\"Contributor\" --scopes=\"/subscriptions/$subscriptionId\""
spout=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscriptionId" --output json)
jq . <<< $spout

clientId=$(jq -r .appId <<< $spout)
clientSecret=$(jq -r .password <<< $spout)
tenantId=$(jq -r .tenant <<< $spout)

az login --service-principal --username $clientId --password $clientSecret --tenant $tenantId --output json
```

Check that the login is successful using any CLI command such as `az account list-locations --output table`.

Let's create a brand new terraform.tf file to make sure we don't lose the service principal information. The code block below uses a suggested directory for WSL, so if you are using the Cloud Shell then either create it within the home directory or within the clouddrive if you wish.

If you want to keep your files in a GitHub repo then now would be a good time to set up a new one and clone it down to your machine (or Cloud Shell) before continuing.

```bash
umask 022
mkdir /mnt/c/terraform && cd /mnt/c/terraform

echo "provider \"azurerm\" {
  subscription_id = \"$subscriptionId\"
  client_id       = \"$clientId\"
  client_secret   = \"$clientSecret\"
  tenant_id       = \"$tenantId\"
}

" > terraform.tf
```

It is a good idea to squirrel away the credential information for your new Service Principal. You can use `cat terraform.tf` and then copy and paste it somewhere safe.

Note that it is perfectly acceptable to have an empty [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html) section in the template (e.g. `provider "azurerm" { }`), if you have set the ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_TENANT_ID environment variables instead. In fact this is a best practice if your terrform files are to be hosted publicly.

## Create test Terraform flow

If you are unfamiliar with Terraform then spend a few minutes looking through the [Introduction to Terraform](https://www.terraform.io/intro/index.html).  Once you understand the basics then the [Terraform docs area](https://www.terraform.io/docs/index.html) is pretty exhaustive.

Right, before we create anything to do with AKS, let's create a resource group with a couple of resources, to test out Terraform and get used to the flow. There are two main areas for the Terraform Azure provider that you will use regularly as you become familiar with for this section:

* <https://docs.microsoft.com/en-us/azure/terraform/>
* <https://www.terraform.io/docs/providers/azurerm/>

You may also find this [template](https://gist.github.com/TsuyoshiUshio/6abf201db0ab23dde83acd0c86636b12) useful, although it is starting to show its age.

Add in the following to the terraform.tf file, deploying to  West Europe:

1. Add a resource group called "terraformed" with Terraform name of "testrg"
1. Add in a storage account with Standard_LRS, with a unique Azure name, and Terraform name of "testsa"

Remember that indentation is absolutely key within YAML. It is more human readable than JSON, but cannot be minified in the same way. Once you are done the terraform file should look something like [this](about:blank).

## Test run #1

One of the great features of Terraform is the okanning step, which creates an execution plan.  You can see what will happen before it is executed.

You should still be in your terraform folder at this point. WHen you run the terraform commands it will automatically look at all of the .tf files within the working directory. Use `pwd` and `ls -l` to confirm you are in the right place.

Initialise the directory using `terraform init` and this will download the required module(s) and create the .terraform directory.

The create the execution plan using `terraform plan`.  terraform apply then yes terraform plan no changes required