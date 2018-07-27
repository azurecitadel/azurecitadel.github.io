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

**Important: The initial lab setup using ARM templates takes around 45 minutes - please initiate this process as soon as possible to avoid a delay in starting the lab.**

> **💬** All usernames and passwords for virtual machines are set to **labuser** / **M1crosoft123**

Perform the following steps to initialise the lab environment.

## Log in to Azure

 Open an Azure CLI session, either using a local machine (e.g. Windows 10 Bash shell), or using the Azure portal cloud shell. If you are using a local CLI session, you must log in to Azure using the *az login* command as follows:

```bash
az login
To sign in, use a web browser to open the page https://aka.ms/devicelogin and enter the code XXXXXXXXX to authenticate.
```

The above command will provide a code as output. Open a browser and navigate to aka.ms/devicelogin to complete the login process.

## Create the resource groups

Use the Azure CLI to create five resource groups: *VDC-Hub*, *VDC-Spoke1*, *VDC-Spoke2*, *VDC-OnPrem* and *VDC-NVA* . Note that the resource groups *must* be named exactly as shown here to ensure that the ARM templates deploy correctly.

Use the following CLI command to achieve this:

```bash
for rg in Hub Spoke1 Spoke2 OnPrem NVA
do az group create --location westeurope --name VDC-$rg
done
```

## Accept the Cisco CSR 1000v Marketplace terms

You will need to accept Cisco's Marketplace terms before the ARM template can programmatically deploy the Cisco CSR 1000v into the VDC-NVA resource group.  Normally you would do this automatically as part of purchasing the offer in the portal, but as we are provisioning the CSR programatically then we can use these CLI commands to do that before deploying:

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

The template deployment process will take approximately 45 minutes. You can monitor the progress of the deployment from the portal (navigate to the *VDC-Hub* resource group and click on *Deployments* at the top of the Overview blade). Alternatively, open up another Cloud Sgell session and use the CLI to monitor the template deployment progress as follows:

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