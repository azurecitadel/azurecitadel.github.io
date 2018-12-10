---
layout: article
title: "VDC Lab Setup"
categories: null
date: 2018-07-19
tags: [azure, virtual, data, centre, vdc, hub, spoke, nsg, udr, nva, policy, rbac]
comments: true
author: Richard_Cheney
published: true
---

{% include toc.html %}

## Introduction

This lab guide allows the user to deploy and test a complete Microsoft Azure Virtual Data Centre (VDC) environment. A VDC is not a specific Azure product; instead, it is a combination of features and capabilities that are brought together to meet the requirements of a modern application environment in the cloud.

More information on VDCs can be found at the following link:

<https://docs.microsoft.com/en-us/azure/networking/networking-virtual-datacenter>

This is recommended reading as it covers the theory and recommendations from the field for enterprise deployments in Azure, and the documentation also includes a number of additional governance topics and some extended topologies.

**Important: The initial lab setup using ARM templates takes around 45 minutes - please initiate this process as soon as possible to avoid a delay in starting the lab.**

> **💬** All usernames and passwords for virtual machines are set to **labuser** / **M1crosoft123**

## Pre-requisites

Before proceeding with this lab, please make sure you have fulfilled all of the following prerequisites:

* A valid subscription to Azure. If you don't currently have a subscription, consider setting up a free trial (<https://azure.microsoft.com/en-gb/free/>). Please note however that some free trial accounts have been found to have limits on the number of compute cores available - if this is the case, it may not be possible to create the virtual machines required for this lab (6 VMs).
* Access to the Azure CLI 2.0. You can achieve this in one of two ways:
    1. Use Cloud Shell in the Azure portal, by either
        * clicking on the ">_" symbol in the top right corner of the portal
        * open a new tab to <https://shell.azure.com>
    1. Installing the CLI on the Windows Subsystem for Linux (<https://aka.ms/InstallTheAzureCLI>)

## Log in to Azure

### Cloud Shell

You can open the Cloud Shell by clicking on the icon (**>_**) at the top of the [portal](https://portal.azure.com).  But for a better experience then you can open an (almost) full page tab using <https://shell.azure.com>, so this is recommended.

The first time you use the cloud shell you will be prompted for Bash or PowerShell.  Choose Bash for this lab. You will also be prompted to create storage.  Say yes.

The storage account is used to back off your home directory to a page blob so that any changes you make in that directory will be persistent.  (The linux containers used for Cloud Shell are ephemeral.) Drag and drop files from File Explorer into the terminal area to upload.

The other persistent area is an SMB 3.0 area mounted in the ~/clouddrive, so you can also move files in or out using [Storage Explorer](https://azure.microsoft.com/en-gb/features/storage-explorer/).  The mount options for the Azure Files area does not support symbolic links and all files will be given permissions of 777.

Note that if you are using the Cloud Shell then you will already be logged into Azure.

### Windows Subsystem for Linux

If you are using a local CLI session (WSL for Windows 10, or the macOS or linux terminals) then you must log in to Azure using the *az login* command as follows:

```bash
az login
```

Depending on your config then it will either open a browser window for authentication, or give you a device code and link to a web page to authenticate and link to the CLI session.

### Showing and switching context

Show your current context by running the following command:

```bash
az account show --output jsonc
```

(You can triple click the command in the code box below to highlight the whole line, which makes copy and paste quicker.)

If you have multiple subscriptions then the following commands may be used to switch context.

```bash
az account list --output table
az account set --subscription <subscriptionId>
az account show
```

## Registering the Microsoft.Insights provider

**Some subscription types (e.g. Azure Passes) do not have the necessary resource provider enabled to use NSG Flow Logs. Before beginning the lab, enable the resource provider by entering the following Azure CLI command - this will save time later.**

```bash
az provider register --namespace Microsoft.Insights
```

> **💬** There is no need to wait for the registration to complete before continuing with the lab set up.

If you do want to double check the status for the provider then you can always use this command:

```bash
az provider show --namespace Microsoft.Insights --query registrationState --output tsv
```

## Create the resource groups

When you deploy using ARM templates then the resource groups need to exist prior to the deployment of the templates themselves.

Use the Azure CLI to create five resource groups: *VDC-Hub*, *VDC-Spoke1*, *VDC-Spoke2*, *VDC-OnPrem* and *VDC-NVA* . Note that the resource groups *must* be named exactly as shown here to ensure that the ARM templates deploy correctly.

Highlight the whole of the code block below, and run:

```bash
for rg in Hub Spoke1 Spoke2 OnPrem NVA
do az group create --location westeurope --name VDC-$rg
done
```

## Accept the Cisco CSR 1000v Marketplace terms

You will need to accept Cisco's Marketplace terms before the ARM template can programmatically deploy the Cisco CSR 1000v into the VDC-NVA resource group.  Normally you would do this automatically as part of purchasing the offer in the portal, but as we are provisioning the CSR programatically then we will use these CLI commands to accept the EULA in advance.

Again, copy out all of the following code block and run:

```bash
for urn in $(az vm image list --all --publisher cisco --offer cisco-csr-1000v --sku 16_6 --query '[].urn' --output tsv)
do az vm image accept-terms --urn $urn
done
```

## Deploy the ARM template

Once the resource groups have been deployed, you can deploy the main lab environment into these using a set of pre-defined ARM templates.

The templates are available at <https://github.com/azurecitadel/vdc-networking-lab> if you wish to learn more about how the lab is defined.  The templates are also referenced in the <https://aka.ms/citadel/arm> lab.  If you want to create your own programmatic deployments then this workshop is recommended

Essentially, a single master template (*DeployVDCwithNVA.json*) is used to call a number of other templates, which in turn complete the deployment of virtual networks, virtual machines, load balancers, availability sets and VPN gateways. The templates also deploy a simple Node.js application on the spoke virtual machines, and the Cisco CSR into the VDC-NVA resource group, attached to the two subnets in the hub vNet.

Use the following CLI commands to deploy the template:

```bash
master=https://raw.githubusercontent.com/azurecitadel/vdc-networking-lab/master/DeployVDCwithNVA.json
az group deployment create --name VDC-Create --resource-group VDC-Hub --template-uri $master --verbose
```

The template deployment process will take approximately 45 minutes. You can monitor the progress of the deployment from the portal (navigate to the *VDC-Hub* resource group and click on *Deployments* at the top of the Overview blade). Alternatively, open up another Cloud Shell session and use the CLI to monitor the template deployment progress as follows:

```bash
az group deployment list -g VDC-Hub -o table
Name                                       Timestamp                         State
-----------------------------------------  --------------------------------  ---------
VDC-Create                                 2018-07-18T15:05:08.732943+00:00  Running
Deploy-Hub-vNet                            2018-07-18T15:05:35.786714+00:00  Succeeded
DeployVnetPeering-Hub-vnet-to-Spoke1-vnet  2018-07-18T15:06:39.337779+00:00  Succeeded
DeployVnetPeering-Hub-vnet-to-Spoke2-vnet  2018-07-18T15:07:30.684959+00:00  Succeeded
Deploy-Hub-vpnGateway                      2018-07-18T15:10:05.043446+00:00  Running
```

Once it has completed then you are ready to proceed to the next section of the lab.

[◄ Introduction](../intro){: .btn-subtle} [▲ Index](../#labs){: .btn-subtle} [Lab 1: Explore ►](../lab1){: .btn-success}