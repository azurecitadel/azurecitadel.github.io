---
layout: article
title: Availability Sets
categories: labs
date: 2018-03-06
tags: [azure, virtual machines, scales sets, vm, vmss, availability, sets, protect]
comments: true
author: Richard_Cheney
image:
  feature: 
  teaser: coming-soon.jpg
  thumb: 
excerpt: Hands on lab to work through making VMs and scale sets highly available within an Azure datacentre.
published: false
---
{% include toc.html %}

## Introduction

This lab is the starting point for making virtual machines and virtual machine scale sets highly available within an Azure datacentre.  The follow on labs will cover other types of protection:

* Making virtual machines, scale sets, load balancers and storage accounts availability zone aware for high availability across datacentres within an Azure region
* Using Traffic Manager and geo-replicated Azure services to create globally available services
* Using Azure Backup to protect systems both within Azure and in other location
* Using Azure Site Recovery as the foundation for business continuity in the event of the loss of an entire Azure region or for specific customer scenarios and compliancy requirements

Note that there is liberal use of some of the techniques covered in the CLI, JMESPATH and Bash guide. It is recommended to work through that first before running through this lab.

## Overview

When defining service level availability of an application, there are a wide number of factors that input to the final number.  One of the key inputs is the SLA of the infrastructure availability itself. Azure publishes a number of [SLAs](https://azure.microsoft.com/en-gb/support/legal/sla/) for the various services, and so we will explore the ones that apply to virtual machines (VMs) and Virtual Machine Scale Sets (VMSS) within an Azure datacentre.

Once these are understood, it is highly recommended that you continue to the Availability Zones lab to cover the same ground and understand how to configure high availability at the region level rather than datacentre level, and the trade offs that introduces.

## Scenarios impacting VMs within a datacentre

The scenarios may be grouped into three:

1. **Unplanned Hardware Maintenance Event** Failure prediction can trigger a Live Migration to enable imminently faulty hardware to be replaced without impacting VM availability
1. **Unexpected Downtime** A hardware fault unexpecteldy impacts the host server (or whole fault domain).  The VM wil have downtime, and will be rebooted onto good hardware in a crash consistent state (i.e. loss of data that has not been flushed to disk, ephemeral temp disk is lost, etc.)
1. **Planned Maintenance events** Most of these are now non-disruptive, but some (such as the fixes for the  Spectre and Meltdown CPU level exploits) demand a full reboot to take effect

There are also a couple of domains we refer to when managing availability:

* **Fault Domains** You can think of the Fault Domains (FDs) as a single rack, where all of the units share the same power supply and the same network switching equipment
* **Update Domains** The Update Domains (UDs) are the groups of units that the fabric controllers roll around as they apply platform updates

![Fault Domains and Update Domains](/labs/availabilitySets/images/ud-fd-configuration.png)

For further reading and detail on high availability areas, including fault domains and update domains, then it is highly recommended to read the [Linux VM high availability](https://docs.microsoft.com/en-gb/azure/virtual-machines/linux/manage-availability) page, or the [Windows VM HA](https://docs.microsoft.com/en-gb/azure/virtual-machines/windows/manage-availability) equivalent.

## Single VM using premium disk

The simplest SLA level is that for the single VM. Azure will provide an SLA of 99.9% if your virtual machine is using nothing but SSD managed disks for both its OS and data disks.

This is in recognition of the fact that SSDs are intrinsically less prone to failure due to the lack of moving parts and intelligence that is built into the health and garbage collection on the controllers in the disks themselves.  Compared to hard disk drives they have a far lower failure rate and that is reflected in the SLA.  The other key factor is that Microsoft has put an enormous amount of engineering effort into non-disruptive [in place migrations](https://docs.microsoft.com/en-gb/azure/virtual-machines/windows/maintenance-and-updates#in-place-vm-migration) to minimise the amount of downtime incurred by updates to the platform.

There are a number of organisations who have relied on the platform availability of virtualisation platforms such as VMware and Hyper-V to provide sufficient availability for single VMs, and therefore this is a quick win.  However, if you want to get an official SLA of more than three nines then Availability Sets are the next port of call.

## Availability Sets and Load Balancers

When you place two or more VMs into an Availability Set then your SLA rises to 99.95%, so you have halved the permitted downtime.  The Availability Set ensures that virtual machines are spread across multiple fault domains and multiple update domains.

When creating Availability Sets within the portal then the defaults are two fault domains and five update domains, although these may be increased to 3 FDs and 20 UDs. Therefore if an unexpected downtime occurs, it should only impact the VM(s) within one of the fault domains, and if a disruptive planned maintenance occurs then that should only impact the VMs within an update domain.

Now, before we go ahead and do this there are a few important points to be made:

* The application running on the multiple servers in the availability set should tolerate VM failure

    This is a larger area in itself regarding stateless scale out, load balancers, web farms, worker pools, queues for disaggregation and cloud native application patterns.  The simple litmus test is that if your service availability is not maintained if one of the VMs in an availability set goes down then an Availability Set won't fix that aspect for you and there is some application work required.

* Do not put a single VM into an Availability Set

    As soon as you put VMs into an availability set then any downtime notifications would disappear as Azure happily updates VMs in groups based on the update domains. It is reasonable for that notification noise to disappear as placing the VMs into an availability set implies that your application will handle that as per the point above.

    If you have a single VM in an availability set then that will not have an SLA for this reason.  Avoid.

* For VMs in an Availability Set fronted by a Load Balancer, you manage the backend pools

    Most configurations are fairly static, but it should be noted that the onus is on you to update the backend pools if you add or remove VMs from the availability set.  If a VM is simply unavailable for a period of time then the load balancer will know that via probing.  This applies to both the Internal Load Balancer (ILB) and externally facing Azure Load Balancer (ALB).

* You cannot move VMs into and out of Availability Sets

    I'll be honest in that I find this to be a frustrating limitation, but you can recreate a VM so that it then sits in the availability set . As you will hopefully already know, Azure VMs may be thought of as merely the compute and memory. They are then associated to the managed disks for OS and data, to the NICs (and therefore subnets, NSGs, public IPs etc.) and, if applicable, availability sets. Therefore you can create JSON templates to recreate a virtual machine within the availability set and reattached the OS, data and NICs. An internet search will find blog posts on this.

Before we begin the hands on part, here are a few hints to make life a little simpler with the CLI:

1. Once you have created your resource group, shorten the commands by using the `az configure --defaults group=myResourceGroupName location=westeurope` 
    * You can then skip the --resource-group and --location switches common to most az commands, which is exactly what I've done with all of these examples
    * Note that if I am scripting rather than executing from the prompt then I always specify the --resource-group and --location switches where applicable
1. Use variables in Bash if you will be reusing switch values regularly.  E.g. `rg=westeurope; avset=myAvailabilitySetName; lb=myLoadBalancerName`
1. If you are using the Cloud Shell then you can still open that up directly within the portal, but if you are doing a good chunk of work with it then you may find it better to open up a new tab and go to <https://shell.azure.com> and have a full screen session
1. Make use of the multiple screens, or multiple virtual desktops or at least Aero Snap so that you can see the instructions and your Cloud Shell session at the same time
1. If you are using the Linux subsystem for Windows (which is excellent) then copy over the id_rsa and id_rsa.pub files from your ~/.ssh directory on Cloud Shell into your home directory on Ubuntu
    * You can use `cat <filename>` and then copy and paste, providing you set the file permissions correctly
1. Don't forget that the tab auto-complete works for commands, switches and also values

OK, let's get going.

### Hands On Lab for Load Balancers and Availability Sets

This lab is based on the excellent [Load Balance VMs](https://docs.microsoft.com/en-gb/azure/virtual-machines/linux/tutorial-load-balancer) tutorial and it covers both availability sets and load balancers. 

Before we start, I'll set a large number of variables up front.  This way, should you get kicked out of a Cloud Shell session then you can repaste those variables and continue from where you left off.  And once that is done then the last two lines will set the defaults so that we can skip the --resource-group switch from now on and create the resource group (this will still succeed if it already exists):

```bash
rg=availabilitySetsLab
avset=myAvailabilitySet
lb=myLoadBalancer
fe=myFrontEndPool
be=myBackEndPool
pip=myPublicIp
probe=myHealthProbe
vnet=myVnet
subnet=mySubnet
nsg=myNetworkSecurityGroup
vmCount=3
vmSize=Standard_B1s
avset=myAvailabilitySet

az configure --defaults location=westeurope group=$rg
az group create --name $rg
```

We'll create a public IP for the load balancer and then the load balancer itself.  We'll add a probe for port 80, and a load balancing rule:

```bash
az network public-ip create --name $pip
az network lb create --name $lb --frontend-ip-name $fe --backend-pool-name $be --public-ip-address $pip
az network lb probe create --lb-name $lb --name $probe --protocol tcp --port 80
az network lb rule create --lb-name $lb --name myLoadBalancerRule --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name $fe --backend-pool-name $be --probe-name $probe
```

We'll create a vNet and subnet for our Linux VMs (we'll take the default address prefixes), and we'll create an NSG for them to use that allows HTTP and SSH traffic.

```bash
az network vnet create --name $vnet --subnet-name $subnet
az network nsg create --name $nsg
az network nsg rule create --nsg-name $nsg --name allowHTTP --priority 1001 --protocol tcp --destination-port-range 80
az network nsg rule create --nsg-name $nsg --name allowSSH --priority 1002 --protocol tcp --destination-port-range 22
```

We'll create NICs in the subnet, and  public IPs (PIPs) for each as well so that we can manage them directly, although we may remove those PIPs later.  Note the switches that adds then to the load balancer and its backend pool.

```bash
for i in $(seq $vmCount)
do
  _pip=myNic$i-pip
  az network public-ip create --name $_pip
  az network nic create --name myNic$i --vnet-name $vnet --subnet $subnet --network-security-group $nsg --public-ip-address $_pip --lb-name $lb --lb-address-pools $be
done
```

OK, now we can create the availability set and then the virtual machines within it.  We'll use nice small B series VMs and default to managed disks.  The main lab also makes use of 

```bash
az vm availability-set create --name $avset --platform-fault-domain-count 2 --platform-update-domain-count 5

for i in $(seq $vmCount)
do
  _nic=myNic$i; _pip=$_nic-pip
   az vm create --name myVM$i --availability-set $avset --nics $_nic --size $vmSize --image UbuntuLTS --admin-username $admin --generate-ssh-keys --no-wait
done
```

These will get submitted with the --no-wait, so wait a few minutes for them to deploy and start.  The tutorial on Microsoft Docs makes use cloud-init to initialise the VMs with nginx,  but we'll cover VM level automation technologies in a separate lab.  For the minute, we'll just ssh into each VM and add nginx the old-fashioned way using apt-get. 

First up is a manual example which first outputs the IP addresses for thos public IPs, and then shows the command to connect in, update the package lists and then install nginx:

```bash
az network public-ip list --query "[].[name, ipAddress]" --output table
Column1     Column2
----------  -------------
myNic1-pip  52.166.185.76
myNic2-pip  13.94.201.22
myNic3-pip  40.68.92.63
myPublicIp  52.232.45.116

ssh $admin@52.166.185.76
sudo apt-get -y update
sudo apt-get -y install nginx
```

And then simply repeat for the other two VM PIPs.  Or you can bash it through in a slightly more automated fashion:

```bash
for i in $(seq 3)
do
  _pip=myNic$i-pip
  _pipAddress=$(az network public-ip show --name $_pip --query ipAddress --output tsv)
  ssh-keyscan -H $_pipAddress >> ~/.ssh/known_hosts
  ssh $admin@$_pipAddress "sudo apt-get -y upgrade && sudo apt-get -y install nginx"
done
```

You can check that all is working OK by connecting to the load balancer's public IP address in a browser, and you should see the nginx holding page display as below:

![nginx](/labs/availabilitySets/images/nginx.png)

The public IP is going through the load balancer and hitting one of those three virtual machines. If we were looking to lock it down then we could adjust or remove the SSH rule in the NSG and also remove the three public IPs for the individual VMs.

The tutorial on Microsoft Docs adds in a node.js application so that the hostname is displayed as part of the website so that browser refreshes will then prove that the load balancing rule is rotating through the backend pool as expected. And it never adds SSH or the additional public IPs. As mentioned earlier, VM automation is a key aspect to managing cloud services at scale effectively and this is a good example of that.

Let's finish up by using JMESPATH to query a few of the services in the resource group to pull out more of the information.  First up, let's query the load balancer's public IP for its IP address, and then interrogate the backend pool to find the list of NIC IDs in the backend pool, and then grab the internal IP address for each of those.

```bash
az network public-ip show --name myPublicIp --query ipAddress --output tsv
52.232.45.116

for id in $(az network lb address-pool list --lb-name $lb --query "[].backendIpConfigurations[].id" --output tsv)
do
  az network nic ip-config show --ids $id --query "privateIpAddress" --output tsv
done
10.0.0.4
10.0.0.5
10.0.0.6
```

Now we know the IP addresses either side of the load balancer.  OK, what about some commands to determine which fault domain and update domain the VMs are in? For this you need the `az vm get-instance-view` command.  For example:

```bash
az vm get-instance-view --name myVm1 --output json --query "{name:name, resourceGroup:resourceGroup, updateDomain:instanceView.platformUpdateDomain, faultDomain:instanceView.platformFaultDomain}"
{
  "faultDomain": 0,
  "name": "myVM1",
  "resourceGroup": "availabilitySetsLab",
  "updateDomain": 0
}
```

Note that this is not currently working well with JMESPATH queries when using multiple VM resource IDs as there is an open [bug](https://github.com/Azure/azure-cli/issues/5591), although you can work around this with [jq](https://stedolan.github.io/jq/manual/#TypesandValues) to create a JSON output of an array of objects as per the codeblock example below.

```bash
vmIds=$(az vm list --output tsv --query [].id)
instanceInfo=$(az vm get-instance-view --id $vmIds --output json)
jq "[.[]|{name,resourceGroup,updateDomain:.instanceView.platformUpdateDomain,faultDomain:.instanceView.platformFaultDomain}]" <<< $instanceInfo
[
  {
    "name": "myVM1",
    "resourceGroup": "availabilitySetsLab",
    "updateDomain": 0,
    "faultDomain": 0
  },
  {
    "name": "myVM2",
    "resourceGroup": "availabilitySetsLab",
    "updateDomain": 1,
    "faultDomain": 1
  },
  {
    "name": "myVM3",
    "resourceGroup": "availabilitySetsLab",
    "updateDomain": 2,
    "faultDomain": 0
  }
]
```

Another nice feature is that you can also query this from within the virtual machines themselves using the Instance Metadata Service using simple curl commands.

The example codeblock below is run from the Cloud Shell, and assumes that the VM is running.  It first programmatically finds the IP address and adminUsername for a Linux VM, and then uses SSH to connect in from the Cloud Shell. (You could just use the Connect button in the portal, but where's the fun in that!)  It then shows the curl command to find the information from within the virtual machine.  All three make liberal use of jq for the JMESPATH queries.  Don't forget that I have scoped the az commands to the resource group using the `az configure --defaults`:

```bash
vmInfo=$(az vm show --name myVM1 --show-details --output json)
ip=$(jq -r .publicIps <<< $vmInfo)
admin=$(jq -r .osProfile.adminUsername <<< $vmInfo)
ssh $admin@$ip

sudo apt-get -y install jq
metadata=$(curl -sH Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01")
jq -C . <<< $metadata
```

This will return the following JSON:

```json
{
  "compute": {
    "location": "westeurope",
    "name": "myVM1",
    "offer": "UbuntuServer",
    "osType": "Linux",
    "placementGroupId": "",
    "platformFaultDomain": "0",
    "platformUpdateDomain": "0",
    "publisher": "Canonical",
    "resourceGroupName": "availabilitySetsLab",
    "sku": "16.04-LTS",
    "subscriptionId": "2ca40be1-7680-4f2b-92f7-06b2123a68cc",
    "tags": "",
    "version": "16.04.201802220",
    "vmId": "2833edd2-54fa-485d-b58f-282098a6f910",
    "vmSize": "Standard_B1s"
  },
  "network": {
    "interface": [
      {
        "ipv4": {
          "ipAddress": [
            {
              "privateIpAddress": "10.0.0.4",
              "publicIpAddress": "52.166.185.76"
            }
          ],
          "subnet": [
            {
              "address": "10.0.0.0",
              "prefix": "24"
            }
          ]
        },
        "ipv6": {
          "ipAddress": []
        },
        "macAddress": "000D3A2E32E3"
      }
    ]
  }
}
```

## Generalising a Virtual Machine to an image

Right, next step is to take one of the VMs (including nginx) and make this a generalised image. First we'll stop two of the VMs, then generalise the remaining VM.  We'll then move it to a new resource group called "images".  And then we'll remove the whole of the previous resource group, availabilitySetLab to keep everything tidy.

```bash
az vm stop --name myVm2 --no-wait
az vm stop --name myVm2 --no-wait

ssh $admin@52.166.185.76
sudo waagent -deprovision -force
WARNING! The waagent service will be stopped.
WARNING! Cached DHCP leases will be deleted.
WARNING! root password will be disabled. You will not be able to login as root.
WARNING! /etc/resolvconf/resolv.conf.d/tail and /etc/resolvconf/resolv.conf.d/original will be deleted.
exit

az vm deallocate --name myVm1
az vm generalize --name myVm1
az image create --name myImageOfMyVm1 --source myVm1
```

Ideally we would be able to move the new image to a new resource group, using the following commands:

```bash
az group create --name images
imageId=$(az image show --name myImageOfMyVm1 --query id --output tsv)
az resource move --destination-group images --ids $imageId
```

Unfortunately at this point of time it is not yet supported to move resources that use managed disks.  Still it give us an opportunity to show how to deploy a single VM from an image.


```

## Next steps

OK, we have covered some good ground for using load balancers, availability sets and virtual machine scale sets to manage any scenarios around fault domain or update domain level events. Don't forget that  