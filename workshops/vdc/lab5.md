---
layout: article
title: "VDC Lab Introduction"
categories: null
date: 2018-07-19
tags: [azure, virtual, data, centre, vdc, hub, spoke, nsg, udr, nva, policy, rbac]
comments: true
author: Richard_Cheney
published: false
---

{% include toc.html %}


# Azure Virtual Data Centre Lab

# Contents

**[VDC Lab Introduction](#intro)**

**[Initial Lab Setup](#setup)**

**[Lab 1: Explore the VDC Environment](#explore)**

**[Lab 2: Configure the VDC Infrastructure](#configure)**

- [2.1: Configure VNet to VNet Connection](#vpn)

- [2.2: Configure Cisco CSR1000V](#cisco)

- [2.3: Configure User Defined Routes](#udr)

- [2.4: Test Connectivity Between On-Premises and Spoke VNets](#testconn)

**[Lab 3: Secure the VDC Environment](#secure)**

- [3.1: Network Security Groups](#nsgsec)

- [3.2: Using Azure Security Center](#seccenter)

- [3.3: Implementing Azure Resource Policies](#armpolicies)

- [3.4: Monitor Compliance Using Azure Policy](#policycompliance)

**[Lab 4: Monitor the VDC Environment](#monitor)**

- [4.1: Enable Network Watcher](#netwatcher)

- [4.2: NSG Flow Logs](#nsgflowlogs)

- [4.3: Tracing Next Hop Information](#nexthop)

- [4.4: Metrics and Alerts with Azure Monitor](#azmonalert)

- [4.5: Diagnostics with Azure Monitor](#azmondiag)

**[Lab 5: Identity in the VDC Environment](#identity)**

- [5.1: Configure Users and Groups](#usersgroups)

- [5.2: Assign Users and Roles to Resource Groups](#roles)

- [5.3: Test User and Group Access](#useraccess)

**[Decommission the lab](#decommission)**

**[Conclusion](#conclusion)**

**[Useful References](#ref)**

# VDC Lab Introduction <a name="intro"></a>

This lab guide allows the user to deploy and test a complete Microsoft Azure Virtual Data Centre (VDC) environment. A VDC is not a specific Azure product; instead, it is a combination of features and capabilities that are brought together to meet the requirements of a modern application environment in the cloud.

More information on VDCs can be found at the following link:

[https://docs.microsoft.com/en-us/azure/networking/networking-virtual-datacenter]

Before proceeding with this lab, please make sure you have fulfilled all of the following prerequisites:

- A valid subscription to Azure. If you don't currently have a subscription, consider setting up a free trial (https://azure.microsoft.com/en-gb/free/). Please note however that some free trial accounts have been found to have limits on the number of compute cores available - if this is the case, it may not be possible to create the virtual machines required for this lab (6 VMs).
- Access to the Azure CLI 2.0. You can achieve this in one of two ways: either by installing the CLI on the Windows 10 Bash shell (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), or by using the built-in Cloud Shell in the Azure portal - you can access this by clicking on the ">_" symbol in the top right corner of the portal.

**Some subscription types (e.g. Azure Passes) do not have the necessary resource provider enabled to use NSG Flow Logs. Before beginning the lab, enable the resource provider by entering the following Azure CLI command - this will save time later.**

<pre lang="...">
az provider register --namespace Microsoft.Insights
</pre>

You can check on the current status for the provider using this command

<pre lang="...">
az provider show --namespace Microsoft.Insights --query registrationState --output tsv
</pre>

# Initial Lab Setup <a name="setup"></a>

**Important: The initial lab setup using ARM templates takes around 45 minutes - please initiate this process as soon as possible to avoid a delay in starting the lab.**

*All usernames and passwords for virtual machines are set to labuser / M1crosoft123*

Perform the following steps to initialise the lab environment:

**1)** Open an Azure CLI session, either using a local machine (e.g. Windows 10 Bash shell), or using the Azure portal cloud shell. If you are using a local CLI session, you must log in to Azure using the *az login* command as follows:

<pre lang="...">
az login
To sign in, use a web browser to open the page https://aka.ms/devicelogin and enter the code XXXXXXXXX to authenticate.
</pre>

The above command will provide a code as output. Open a browser and navigate to aka.ms/devicelogin to complete the login process.

**2)** Use the Azure CLI to create five resource groups: *VDC-Hub*, *VDC-Spoke1*, *VDC-Spoke2*, *VDC-OnPrem* and *VDC-NVA* . Note that the resource groups *must* be named exactly as shown here to ensure that the ARM templates deploy correctly. Use the following CLI command to achieve this:

<pre lang="...">
for rg in Hub Spoke1 Spoke2 OnPrem NVA; do az group create -l westeurope -n VDC-$rg; done
</pre>

**3)** Once the resource groups have been deployed, you can deploy the main lab environment into these using a set of pre-defined ARM templates. The templates are available at https://github.com/azurecitadel/vdc-networking-lab if you wish to learn more about how the lab is defined. Essentially, a single master template (*VDC-Networking-Master.json*) is used to call a number of other templates, which in turn complete the deployment of virtual networks, virtual machines, load balancers, availability sets and VPN gateways. The templates also deploy a simple Node.js application on the spoke virtual machines. Use the following CLI command to deploy the template:

<pre lang="...">
master=https://raw.githubusercontent.com/azurecitadel/vdc-networking-lab/master/DeployVDCwithNVA.json
az group deployment create --name VDC-Create --resource-group VDC-Hub --template-uri $master --verbose
</pre>

The template deployment process will take approximately 45 minutes. You can monitor the progress of the deployment from the portal (navigate to the *VDC-Hub* resource group and click on *Deployments* at the top of the Overview blade). Alternatively, the CLI can be used to monitor the template deployment progress as follows:

<pre lang="...">
<b>az group deployment list -g VDC-Hub -o table</b>
Name                                       Timestamp                         State
-----------------------------------------  --------------------------------  ---------
VDC-Create                                 2018-07-18T15:05:08.732943+00:00  Running
Deploy-Hub-vNet                            2018-07-18T15:05:35.786714+00:00  Succeeded
DeployVnetPeering-Hub-vnet-to-Spoke1-vnet  2018-07-18T15:06:39.337779+00:00  Succeeded
DeployVnetPeering-Hub-vnet-to-Spoke2-vnet  2018-07-18T15:07:30.684959+00:00  Succeeded
Deploy-Hub-vpnGateway                      2018-07-18T15:10:05.043446+00:00  Running
</pre>

Once the template deployment has succeeded, you can proceed to the deployment of the Cisco CSR1000V, as follows:

**1)** Using the Azure portal, navigate to the 'VDC-NVA' resource group. Click on the 'Add' button at the top of the screen and enter 'Cisco CSR' in the search box. Press enter.

**2)** Select the option entitled 'Cisco CSR 1000v - XE 16.6 Deployment with 2 NICs' and then select create.

**3)** Name the virtual machine 'vdc-csr-1' and use the username and password *labuser / M1crosoft123*. Make sure the 'VDC-NVA' resource group is selected and West Europe is the location.

**4)** In the next step, select 'storage account' and create a storage account with a unique name (you will receive an error if the name is not unique). Leave the storage as 'locally redundant'.

**5)** Select 'Public IP address' and call the IP address 'csr-pip'. Use the default options (Basic SKU and Dynamic Assignment).

**6)** Assign a unique DNS label (you will receive an error if the name is not unique).

**7)** Click on 'Virtual Network' and then select 'Hub_VNet'

**8)** Select 'Subnets' and choose 'Hub_VNet-Subnet1' as the first subnet, with 'Hub\_Vnet-Subnet2' as the second subnet.

**9)** Select 'OK' and check the 'purchase' button until the virtual appliance starts to deploy. Wait for the deployment to finish.

**10)** Once the deployment has completed, navigate again to the VDC-NVA resource group and click on the Network Security Group named 'vdc-csr-1-SSH-SecurityGroup'.

**11)** Click on 'Network Interfaces' and then click on the three dots on the right side of the interface. Select 'Dissociate'

You are now ready to proceed to the next sections of the lab.

# Lab 1: Explore VDC Environment <a name="explore"></a>

In this section of the lab, we will explore the environment that has been deployed to Azure by the ARM templates. The lab environment has the following topology:

![Main VDC Image](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/VDC-Networking-Main.jpg "VDC Environment")

**Figure 1:** VDC Lab Environment

Note that each of the virtual networks resides in its own Azure resource group. While this environment could be deployed in one resource group only, splitting it up in this manner makes it easier to apply Role Based Access Control to the various areas individually.

**1)** Use the Azure portal to explore the resources that have been created for you. Navigate to the various resource groups in turn to get an overall view of the resources deployed.

![VDC-Spoke1 Resource Group Image](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/VDC-Spoke1-RG.jpg "VDC-Spoke1 Resource Group")

**Figure 2:** VDC-Spoke1 Resource Group View

**Tip**: Select 'group by type' on the top right of the resource group view to group the resources together.

**2)** Under the resource groups *VDC-Hub* and *VDC-OnPrem*, look at each of the virtual networks and the subnets created within each one. You will notice that *Hub_Vnet* and *OnPrem_VNet* have an additional subnet called *GatewaySubnet* - this is a special subnet used for the VPN gateway.

**3)** Navigate to the *Spoke1-LB* load balancer in the VDC-Spoke1 resource group. From here, navigate to 'Backend Pools' - you will see that both virtual machines are configured as part of the backend pool for the load balancer, as shown in figure 3.

![LB Backend Pools](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/BackendPools.JPG "LB Backend Pools")

**Figure 3:** Load Balancer Backend Pools View

**4)** Under the load balancer, navigate to 'Load Balancing Rules'. Here, you will see that we have a single rule configured (*DemoAppRule*) that maps incoming HTTP requests to port 3000 on the backend (our simple Node.js application listens on port 3000).

**Note:** Two types of load balancer are available in Azure - either external or internal. In our case, we have an internal load balancer deployed; that is, the load balancer has only a private IP address - in other words, it is not accessible from the Internet.

Now that you are familiar with the overall architecture, let's move on to the next lab where you will start to add some additional configuration.

# Lab 2: Configure the VDC Infrastructure <a name="configure"></a>

## 2.1: Configure VNet to Vnet Connection <a name="vpn"></a>

In our VDC environment, we have a hub virtual network (used as a central point for control and inspection of ingress / egress traffic between different zones) and a virtual network used to simulate an on-premises environment. In order to provide connectivity between the hub and on-premises, we will configure a site-to-site VPN. The VPN gateways required to achieve this have already been deployed, however they must be configured before traffic will flow. Follow the steps below to configure the site-to-site VPN connection.

**1)** Using the Azure portal, click on 'All Services' at the top left of the screen and then search for and select 'Virtual Network Gateways'. Click on the virtual network gateway named 'Hub_GW1'. Select 'Connections'.

**2)** Add a connection and name it 'Hub2OnPrem'. Ensure the connection type is 'VNet-to-VNet'.

**3)** Choose 'OnPrem_GW1' as the second gateway.

**4)** Use 'M1crosoft123' as the shared key. Select 'OK' to complete the connection.

**5)** Repeat the process for the other VPN gateway (OnPrem_GW1), but reverse the first and second gateways when creating the connection (name the connection 'OnPrem2Hub').

**6)** Under the resource group *VDC-OnPrem* navigate back to the *OnPrem_GW1* virtual network gateway resource and then click 'Connections'. You should see a successful VPN connection between the OnPrem and Hub VPN gateways.

**Note:** It may take a few minutes before a successful connection is shown between the gateways.

At this point, we can start to verify the connectivity we have set up. One of the ways we can do this is by inspecting the *effective routes* associated with a virtual machine. Let's take a look at the effective routes associated with the *OnPrem_VM1* virtual machine that resides in the OnPrem VNet.

**6)** Using the Azure portal, navigate to the *OnPrem_VM1-nic* object under the VDC-OnPrem resource group. This object is the network interface associated with the OnPrem_VM virtual machine.

**7)** Under 'Support + Troubleshooting', select 'Effective Routes'. You should see an entry for 'virtual network gateway', specifying an address range of 10.101.0.0/16, as shown in figure 4.

![Effective Routes](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/EffectiveRoutes1.JPG "Effective Routes")

**Figure 4:** OnPrem_VM Effective Routes

Figure 5 shows a diagram explaining what we see when we view the effective routes of OnPrem_VM.

![Routing from OnPrem_VM](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/EffectiveRoutes2.jpg "Routing from OnPrem_VM1")

**Figure 5:** Routing from OnPrem_VM1

Next, let's move on to configuring our Cisco Network Virtual Appliances.

## 2.2: Configure Cisco CSR1000V <a name="cisco"></a>

One of the requirements of many enterprise organisations is to provide a secure perimeter or DMZ environment using third party routers or firewall devices. Azure allows for this requirement to be met through the use of third party Network Virtual Appliances (NVAs). An NVA is essentially a virtual machine that runs specialised software, typically from a network equipment manufacturer, and that provides routing or firewall functionality within the Azure environment.

In our VDC environment, we are using Cisco CSR1000V routers in the Hub virtual network - CSR stands for *Cloud Services Router* and is a virtualised Cisco router running IOS-XE software. The CSR1000V is a fully featured Cisco router that supports most routing functionality, such as OSPF and BGP routing, IPSec VPNs and Zone Based Firewalls.

In the initial lab setup, you provisioned the CSR1000V router in the Hub virtual network, however it must now be configured in order to route traffic. Follow the steps in this section to configure the CSR1000V.

**1)** To log on to the CSR1000V, you'll need to obtain the public IP address assigned to it. You can obtain this using the Azure portal (navigate to the *VDC-NVA* resource group and inspect the object named 'csr-pip'). Alternatively, you can use the Azure CLI to obtain the IP addresses for the virtual machine, as follows:

<pre lang="...">
<b>az vm list-ip-addresses --resource-group VDC-NVA --output table</b>
VirtualMachine    PublicIPAddresses    PrivateIPAddresses
----------------  -------------------  --------------------
vdc-csr-1         51.144.132.127       10.101.1.4
vdc-csr-1                              10.101.2.4
 </pre>

**2)** Now that you have the public IP address, SSH to the CSR1000V VM from within the Cloud Shell using 'ssh labuser@_public-ip_'. The username and password for the CSR are *labuser / M1crosoft123*.

**3)** Enter configuration mode on the CSR:

<pre lang="...">
conf t
 </pre>

**4)** The CSR1000V has two interfaces - one connected to Hub_VNet-Subnet1 and the other connected to Hub_VNet-Subnet2. We want to ensure that these interfaces are configured using DHCP, so use the following CLI config to ensure that this is the case and that the interfaces are both in the 'up' state:

<pre lang="...">
vdc-csr-1(config)#interface gig1
vdc-csr-1(config-if)#ip address dhcp
vdc-csr-1(config-if)#no shut
vdc-csr-1(config)#interface gig2
vdc-csr-1(config-if)#ip address dhcp
vdc-csr-1(config-if)#no shut
vdc-csr-1(config-if)#exit
vdc-csr-1(config)#exit
 </pre>

**5)** Verify that the interfaces are up and configured with an IP address as follows:

<pre lang="...">
vdc-csr-1#show ip interface brief
Interface              IP-Address      OK? Method Status                Protocol
GigabitEthernet1       10.101.1.4      YES DHCP   up                    up
GigabitEthernet2       10.101.2.4      YES DHCP   up                    up
</pre>

**6)** Exit the SSH session to the Cisco CSR and then find the public IP address of the virtual machine named *OnPrem_VM1* using the following command:

<pre lang="...">
az vm list-ip-addresses --name OnPrem-VM1 --resource-group VDC-OnPrem --output table
</pre>

**7)** SSH to the public IP of OnPrem_VM1. From within the VM, attempt to connect to the private IP address of one of the CSR1000V interfaces (10.101.1.4):

<pre lang="...">
ssh labuser@10.101.1.4
</pre>

This step should succeed, which proves connectivity between the On Premises and Hub VNets using the VPN connection. Figure 6 shows the connection we have just made.

![SSH to NVA](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/SSHtoNVA.jpg "SSH to NVA")

**Figure 6:** SSH from OnPrem_VM1 to vdc-csr-1

**8)** Exit the SSH session to the CSR1000V and then exit the SSH session to the OnPrem virtual machine. Find the internal IP address of a virtual machine's NIC in VDC-Spoke1, either by using the portal or any of the following CLI 2.0 commands:

<pre lang="...">
az network nic ip-config list --resource-group VDC-Spoke1 --nic-name Spoke1-VM1-nic -o table
az network nic list --query "[].{group: resourceGroup, NIC:name, IPaddress: ipConfigurations[0].privateIpAddress}" -o table
</pre>

The second command is more complicated, using a JMESPATH query to customise the output.  

The VM's IP address is expected to be 10.1.1.5 or 10.1.1.6 depending on the order in which the VM builds completed.

**9)** Log back in to OnPrem_VM1, and then attempt to connect to the private IP address of the virtual machine within the Spoke 1 vNet.  (Note that this should fail.)

<pre lang="...">
ssh labuser@10.1.1.5
</pre>

The reason for the failure is that we do not yet have the correct routing in place to allow connectivity between the On Premises VNet and the Spoke VNets via the hub / NVA. In the next section, we will configure the routing required to achieve this.

## 2.3: Configure User Defined Routes <a name="udr"></a>

In this section, we will configure a number of *User Defined Routes*. A UDR in Azure is a routing table that you as the user define, potentially overriding the default routing that Azure sets up for you. UDRs are generally required any time a Network Virtual Appliance (NVA) is deployed, such as the Cisco CSR router we are using in our lab. The goal of this exercise is to allow traffic to flow from VMs residing in the Spoke VNets, to the VM in the On Premises VNet. This traffic will flow through the Cisco CSR router in the Hub VNet. The diagram in figure 7 shows what we are trying to achieve in this section.

![User Defined Routes](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/UDR.jpg "User Defined Routes")

**Figure 7:** User Defined Routes

We'll create our first User Defined Route using the Azure portal, with subsequent UDRs configured using the Azure CLI.

**1)** In the Azure portal, navigate to the *VDC-OnPrem* resource group. Click 'Add' and then search for 'Route Table'. Select this and then create a new route table named *OnPrem-UDR*, making sure that you have selected the existing *VDC-OnPrem* resource group. Once complete, navigate to the newly created UDR and select it.

**2)** Click on 'Routes' and then 'Add'. Create a new route with the following parameters:

- Route Name: *Spoke1-Route*
- Address Prefix: *10.1.0.0/16*
- Next Hop Type: *Virtual Network Gateway*

Click 'OK' to create the route. Repeat the process for Spoke 2 as follows:

- Route Name: *Spoke2-Route*
- Address Prefix: *10.2.0.0/16*
- Next Hop Type: *Virtual Network Gateway*

Figure 8 shows the route creation screen.

![Defining UDRs](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/UDR2.jpg "Defining UDRs")

**Figure 8:** Defining UDRs

**3)** We now need to associate the UDR with a specific subnet. Click on 'Subnets' and then 'Associate'. Select the VNet 'OnPrem\_Vnet' and then the subnet 'OnPrem\_Vnet-Subnet1'. Click OK to associate the UDR to the subnet.

We'll now switch to the Azure CLI to define the rest of the UDRs that we need.

**4)** Create the UDR for the Hub Vnet (GatewaySubnet):

<pre lang="...">
az network route-table create --name Hub_UDR -g VDC-Hub
</pre>

**5)** Create the routes to point to Spoke1 and Spoke2, via the Cisco CSR router:

<pre lang="...">
az network route-table route create --name Spoke1-Route --address-prefix 10.1.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.1.4 --route-table-name Hub_UDR -g VDC-Hub
az network route-table route create --name Spoke2-Route --address-prefix 10.2.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.1.4 --route-table-name Hub_UDR -g VDC-Hub
</pre>

**6)** Associate the UDR with the GatewaySubnet inside the Hub Vnet:

<pre lang="...">
az network vnet subnet update --name GatewaySubnet --vnet-name Hub_VNet --route-table Hub_UDR -g VDC-Hub
</pre>

**7)** Configure the UDRs for the Spoke VNets, with relevant routes and associate to the subnets:

<pre lang="...">
az network route-table create --name Spoke1_UDR -g VDC-Spoke1
az network route-table create --name Spoke2_UDR -g VDC-Spoke2

az network route-table route create --name OnPrem-Route --address-prefix 10.102.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.2.4 --route-table-name Spoke1_UDR -g VDC-Spoke1
az network route-table route create --name OnPrem-Route --address-prefix 10.102.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.2.4 --route-table-name Spoke2_UDR -g VDC-Spoke2

az network vnet subnet update --name Spoke1_VNet-Subnet1 --vnet-name Spoke1_Vnet --route-table Spoke1_UDR -g VDC-Spoke1
az network vnet subnet update --name Spoke2_VNet-Subnet1 --vnet-name Spoke2_Vnet --route-table Spoke2_UDR -g VDC-Spoke2
</pre>

Great, everything is in place - we are now ready to test connectivity between our on-premises environment and the Spoke VNets.

## 2.4: Test Connectivity Between On-Premises and Spoke VNets <a name="testconn"></a>

In this section, we'll perform some simple tests to validate connectivity between our "on-premises" environment and the Spoke VNets - this communication should occur through the Cisco CSR router that resides in the Hub VNet.

**1)** SSH into the virtual machine named *OnPrem-VM1* as you did earlier.

**2)** From within this VM, attempt to SSH to the first virtual machine inside the Spoke 1 virtual network (e.g. with an IP address of 10.1.1.5) - this will fail:

<pre lang="...">
ssh labuser@10.1.1.5
</pre>

Although we have all the routing we need configured, this connectivity is still failing. Why?

It turns out that there is an additional setting we must configure on the VNet peerings to allow this type of hub and spoke connectivity to happen. Follow these steps to make the required changes:

**3)** In the Azure portal, navigate to *Spoke1_VNet* in the 'VDC-Spoke1' resource group. Select 'peerings' and then select the 'to-Hub_Vnet' peering. You'll see that the option entitled *Use Remote Gateways* is unchecked. Checking this option allows the VNet to use a gateway in a *remote* virtual network - as we need our Spoke VNets to use a gateway residing in the Hub VNet, this is exactly what we need, so check the box as shown in figure 9.

![Use Remote GW](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/UseRemoteGW.JPG "Use Remote GW")

**Figure 9:** Use Remote Gateway Option

**4)** From within the OnPrem_VM1 virtual machine, try to SSH to the Spoke VM once more. The connection attempt should now succeed.

**5)** Configure the Spoke 2 VNet peering with 'Use Remote Network Gateway' and then attempt to connect to one of the virtual machines in Spoke 2 (e.g. 10.2.1.5). This connection should also now succeed.

**6)** Still from the OnPrem_VM1 machine, use the curl command to make an HTTP request to the load balancer private IP address in Spoke1. Note that the IP address *should* be 10.1.1.4, however you may need to verify this in the portal or CLI:

<pre lang="...">
curl http://10.1.1.4
</pre>

This command should return an HTML page showing some information, such as the page title, the hostname, system info and whether the application is running inside a container or not.

If you try the same request a number of times, you may notice that the response contains either *Spoke1-VM1* or *Spoke1-VM2* as the hostname, as the load balancer has both of these machines in the backend pool.

In the next section, we will lock down the environment to ensure that our On Premises user can only reach the required services.

# Lab 3: Secure the VDC Environment <a name="secure"></a>

In this section of the lab, we will use Azure features to further secure the virtual data centre environment. We will use the *Network Security Group* (NSG) feature to secure traffic from our On Premises virtual network to the applications running on our spoke VNets. In addition, we will explore the *Azure Security Center* to analyse potential security issues in our environment and take action to resolve them.

## 3.1: Network Security Groups <a name="nsgsec"></a>

At the moment, our user in the On Premises VNet is potentially able to access the Spoke 1 & 2 virtual machines on any TCP port - for example, SSH. We want to use Azure Network Security Groups (NSGs) to prevent traffic on any port other than HTTP and port 3000 (the port the application runs on) being allowed into our Spoke VNets.

An NSG is a list of user-defined security rules that allows or denies traffic on specific ports, or to / from specific IP address ranges. An NSG can be applied at two levels: at the virtual machine NIC level, or at a subnet level.

Our NSG will define two inbound rules - one for HTTP and another for TCP port 3000. We'll create this NSG within our Hub VNet in order to enforce traffic at a central location. This NSG will be applied at the first CSR1000V interface (i.e. the interface where traffic would come in from the OnPrem VNet).

**1)** In the Azure portal under the resource group VDC-Hub, click 'Add' and search for 'Network Security Group'. Create a new NSG named *Hub-NSG*.

**2)** Navigate to the newly created NSG and select it. Select 'Inbound Security Rules'. Click 'Add' to add a new rule. Use the following parameters:

- Name: *Allow-http*
- Priority: *100*
- Source port range: *Any*
- Destination port range: *80*
- Action: *Allow*

![NSG Rule1](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/NSG1.jpg "NSG Rule1")

**Figure 10:** Network Security Group - HTTP Rule

**3)** Add another rule with the following parameters:

- Name: *Allow-3000*
- Priority: *110*
- Source port range: *Any*
- Destination port range: *3000*
- Action: *Allow*

**4)** Add one more rule with the following parameters:

- Name: *Deny-All*
- Priority: *120*
- Source port range: *Any*
- Destination port range: *Any*
- Action: *Deny*

**5)** Select 'Network Interfaces'. Click the 'Associate' button and choose 'vdc-csr-1-Nic0'.

![NSG Associate Subnet](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/NSG2.jpg "NSG Associate Subnet")

**Figure 11:** Network Security Group - Associating with a Subnet

**6)** SSH back into the OnPrem-VM1 virtual machine from your terminal emulator (this will refresh the NSG rules for the associated NIC). From this VM, attempt to SSH to the first Spoke1 VM:

<pre lang="...">
ssh labuser@10.1.1.5
</pre>

This connection attempt will fail due to the NSG now associated with the Spoke1 subnet.

**7)** From OnPrem_VM1, make sure you can still access the demo app:

<pre lang="...">
curl http://10.1.1.4
</pre>

You might wonder why the third rule denying all traffic is required in this example. The reason for this is that a default rule exists in the NSG that allows all traffic from every virtual network. Therefore, without the specific 'Deny-All' rule in place, all traffic will succeed (in other words, the NSG will have no effect). You can see the default rules by clicking on 'Default Rules' under the security rules view.

## 3.2: Using Azure Security Center <a name="seccenter"></a>

Azure Security Center is a feature built in to Azure which allows administrators to gain visibility into the security of their environment and to detect and respond to issues and threats. In this part of the lab, we'll explore Azure Security Center and what it has to offer.

**1)** In the Azure portal, expand the left hand menu and select 'All Services'. Search for and then select 'Security Center'.  Select the free plan using the link on the Getting Started page (which may be selected from the General section of the blade) as this will be sufficient information for this lab.

**2)** The overview section of the Security Center shows an 'at-a-glance' view of any security recommendations, alerts and prevention items relating to compute, storage, networking and applications.

![Azure Security Center](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/SecCenter.jpg "Azure Security Center")

**Figure 12:** Azure Security Center - Overview Page

**3)** Click on 'Recommendations' in the Security Center menu. You will see a list of recommendations relating to various areas of the environment - for example, the need to add Network Security Groups on subnets and VMs, or the recommendation to apply disk encryption to VMs.

![Azure Security Recommendations](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/SecRecommendations.jpg "Azure Security Recommendations")

**Figure 13:** Azure Security Center - Recommendations

**4)** Explore other areas of the Security Center - click through the Compute, Networking and Storage sections to see recommendations specific to these areas.

## 3.3: Implementing Azure Resource Policies <a name="armpolicies"></a>

Azure resource policies are used to place restrictions on what actions can be taken at a subscription or resource group level. For example, a resource policy could specify that only certain VM sizes are allowed, or that encryption is required for storage accounts. In this section of the lab, we'll apply both built-in and custom resource policies to one of our resource groups to restrict what can and can't be done in our environment.

**1)** In the Azure portal, navigate to the VDC-Hub resource group and then click on *Policies* in the menu.

**2)** Select *Definitions* and then *Policy Definitions* in the right hand pane.

**3)** Scroll down to the policy entitled 'Allowed Resource Types', click the '...', select 'View Definition' and then click on 'JSON'. This shows you the JSON policy document - this simple example takes a list of resource types and prevents the ability to create them.

![Azure Resource Policy Example](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/armpolicies1.jpg "Azure Resource Policy Example")

**Figure 14:** Example Resource Policy - Allowed Resource Types

**4)** Click on 'Assignments' in the menu and then click 'Assign Policy'.

**5)** Use the following details to create the policy:

- Policy Definition: *Allowed Resource Types*
- Allowed Resource Types: *Select all 'Microsoft.Network' resources*
- Display Name: *Allow Network*
- ID: *Allow-Network*

**6)** Use the Azure Cloud Shell to attempt to create a virtual machine using the following commands:

<pre lang="...">
az vm create -n policy-test-VM -g VDC-Hub --image UbuntuLTS --generate-ssh-keys
</pre>

**7)** The validation should fail with a message stating "The template deployment failed because of policy violation. Please see details for more information."

**8)** Return to the 'Policies' page and remove the 'Allow-Network' resource policy assignment.

If the built-in policies do not meet your requirements, it is also possible to create custom policies. The following steps walk you through custom policy creation.

In this example, we'll create a policy that enforces a specific naming convention - if the user attempts to create a resource that does not meet the convention, the request will be denied. We first need to define the resource policy template - these are written in JSON format. The JSON for our custom policy is as follows:

<pre lang="...">
{
    "if": {
      "not": {
        "field": "name",
        "like": "VDC-*"
      }
    },
    "then": {
      "effect": "deny"
    }
  }
</pre>

This policy states that we must name our resources with the 'VDC-' prefix.

In this exercise, a file has been created on Github containing the above policy - that file will then be referenced from an AZ CLI command in order to create the policy in Azure.

**1)** Using the AZ CLI, enter the following command:

<pre lang="...">
 az policy definition create --name EnforceNaming --display-name EnforceNamingConvention --rules https://raw.githubusercontent.com/azurecitadel/vdc-networking-lab/master/naming-policy.json
</pre>

**2)** Assign the policy to the VDC-Hub resource group using the following AZ CLI command:

<pre lang="...">
az policy assignment create --policy EnforceNaming -g VDC-Hub --name EnforceNaming
</pre>

**3)** In the VDC-Hub resource group, create a new virtual network named "test-net" using default parameters. You should receive a validation error as the name does not meet the required convention, as specified in the resource policy.

**4)** Attempt to create the virtual network again, but this time name it "VDC-testnet". This attempt should succeed as the name matches the convention.

**5)** Remove the VDC-Test virtual network from the resource group.

**6)** Unassign and remove the naming convention policy using the following commands:

<pre lang="...">
az policy assignment delete -g VDC-Hub --name EnforceNaming
az policy definition delete --name EnforceNaming
</pre>

## 3.4: Monitor Compliance Using Azure Policy <a name="policycompliance"></a>

In addition to the ability to define and assign resource policies, Azure Policy allows you to identify existing resources within a subscription or resource that are not compliant against the configured policies. In this section, we will use Azure Policy to view non-compliant resources within the VDC-Hub resource group.

**1)** In the 'Policies' section under VDC-Hub, click on 'Definitions' and then '+ Policy Definition'. Name the policy 'compliance-test' and select your subscription under 'Definition Location'.

**2)** Select 'Use existing' under the category section and select 'Compute'.

**3)** Cut and paste the following JSON into the 'Policy Rule and Parameters' box and then click 'save':

<pre lang="...">
{
    "policyRule": {
    "if": {
      "not": {
        "field": "name",
        "like": "test-*"
      }
    },
    "then": {
      "effect": "audit"
      }
    }
}
</pre>

**4)** Click on 'Assignments' and then 'Assign Policy'. Under 'Policy Definition', select the policy created in the last step (compliance-test). Name the assignment 'compliance-test'.

**5)** Under 'Scope', ensure that the 'VDC-Hub' resource group is selected. Finally, click on 'Assign'.

**6)** Click on the 'Compliance' menu option - after some time, this screen should show the resources within the VDC-Hub resource group that are not compliant with the policy (all of them, as none match the name 'test-*').

**Note: it can take around 30 - 60 minutes for the compliance information to be updated, so you may wish to return to this section.**

![Azure Policy - Compliance](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/PolicyCompliance.jpg "Azure Policy - Compliance")

**Figure 15:** Azure Policy - Compliance View

**8)** Under the 'Assignments' page, click on the '...' on the right hand side of the assignment and select 'Delete Assignment'.

**9)** Under the 'Definitions' page, click on 'Policy Definitions' and delete the 'compliance-test' definition we created earlier.

# Lab 4: Monitor the VDC Environment <a name="monitor"></a>

In this section, we will explore some of the monitoring options we have in Azure and how those can be used to troubleshoot and diagnose issues in a VDC environment. The first tool we will look at is *Network Watcher*. Network Watcher is a collection of tools available to monitor and troubleshoot issues with network connectivity in Azure, including packet capture, NSG flow logs and IP flow verify.

## 4.1: Enabling Network Watcher <a name="netwatcher"></a>

Before we can use the tools in this section, we must first enable Network Watcher. To do this, follow these steps:

**1)** In the Azure portal, expand the left hand menu and then click *All Services*. In the filter bar, type 'Network Watcher' and then click on the Network Watcher service.

**2)** You should see your Azure subscription listed in the right hand pane - find your region and then click on the'...' on the right hand side. Click 'Enable Network Watcher':

![Enabling Network Watcher](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/NetWatcher1.jpg "Enabling Network Watcher")

**Figure 16:** Enabling Network Watcher

**3)** On the left hand side of screen under 'Monitoring', click on 'Topology'. Select your subscription and then the resource group 'VDC-Hub' and 'Hub_Vnet'. You will see a graphical representation of the topology on the screen:

![Network Topology](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/NetWatcherTopo.jpg "Network Topology")

**Figure 17:** Network Topology View in Network Watcher

**4)** A useful feature of Network Watcher is the ability to view network related subscription limits and track your resource utilisation against these. In the left hand menu, select 'Network Subscription Limit'. You will see a list of resources, including virtual networks, public IP addresses and more:

![Network Subscription Limits](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/SubLimits.jpg "Network Subscription Limits")

**Figure 18:** Network Related Subscription Limits

## 4.2: NSG Flow Logs <a name="nsgflowlogs"></a>

Network Security Group (NSG) Flow Logs are a feature of Network Watcher that allows you to view information about traffic flowing through a NSG. The logs are written in JSON format and are stored in an Azure storage account that you must designate. In this section, we will enable flow logging for the NSG we configured in the earlier lab and inspect the results.


**1)** To begin with, we need to create a storage account to store the NSG flow logs. Use the following CLI to do this, substituting the storage account name for a unique name of your choice:

<pre lang="...">
az storage account create --name storage-account-name -g VDC-Hub --sku Standard_LRS
</pre>

**2)** Use the Azure portal to navigate to the Network Watcher section (expand left menu, select 'All Services' and search for 'Network Watcher'). Select 'NSG Flow Logs' from the Network Watcher menu. Filter using your subscription and Resource Group at the top of the page and you should see the NSG we created in the earlier lab.

**3)** Click on the NSG and then in the settings screen, change the status to 'On'. Select the storage account you created in step 1 and change the retention to 5 days. Click 'Save'.

![NSG Flow Log Settings](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/FlowLogs1.jpg "NSG Flow Log Settings")
**Figure 19:** NSG Flow Log Settings

**4)** In order to view data from the NSG logs, we must initiate some traffic that will flow through the NSG. SSH to the OnPrem_VM1 virtual machine as described earlier in the lab. From here, use the curl command to view the demo app on Spoke1\_VM1 (through the load balancer) and attempt to SSH to the same VM (this will fail):

<pre lang="...">
curl http://10.1.1.4
ssh labuser@10.1.1.5
</pre>

**5)** NSG Flow Logs are stored in the storage account you configured earlier in this section - in order to view the logs, you must download the JSON file from Blob storage. You can do this either using the Azure portal, or using the *Microsoft Azure Storage Explorer* program available as a free download from http://storageexplorer.com/. If using the Azure portal, navigate to the storage account you created earlier and select 'Blobs'. You will see a container named 'insights-logs-networksecuritygroupflowevent'. Navigate through the directory structure (structured as subscription / resource group / day / month / year / time) until you reach a file named 'PT1H.json'. Download this file to your local machine.

![NSG Log Download](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/NSGLogs.jpg "NSG Log Download")

**Figure 20:** NSG Flow Log Download

**6)** Open the PT1H.json file in an editor on your local machine (Visual Studio Code is a good choice - available as a free download from https://code.visualstudio.com/). The file should show a number of flow entries which can be inspected. Let's start by looking for an entry for TCP port 80 from our OnPrem_VM1 machine to the Spoke1 load balancer IP address. You can search for the IP address '10.102.1.4' to see entries associated with OnPrem\_VM1.

Here is an example of a relevant JSON entry:

<pre lang="...">
"rule":"UserRule_Allow-HTTP","flows":[{"mac":"000D3A25DC84","flowTuples":["1501685102,10.102.1.4,10.1.1.5,56934,80,T,I,A"
</pre>

The above entry shows that a flow has hit the user rule named 'Allow-HTTP' (a rule that we configured earlier) and that the flow has a source address of 10.102.1.4 and a destination address of 10.1.1.5 (one of our Spoke1 VMs), using TCP port 80. The letters T, I and A signify the following:

- **T:** A TCP flow (a 'U' would indicate UDP)
- **I:** An ingress flow (an 'E' would indicate an egress flow)
- **A**: An allowed flow (a 'D' would indicate a denied flow)

 **7)** Search the JSON file for a flow using port 22 (SSH).

<pre lang="...">
"rule":"UserRule_Deny-All","flows":[{"mac":"000D3A25DC84","flowTuples":["1501684054,10.102.1.4,10.1.1.5,60084,22,T,I,D"
</pre>

The above example shows a flow that has hit our user defined rule name 'Deny-All'. The source and destination addresses are the same as in the previous example, however the TCP port is 22 (SSH), which is not allowed through the NSG (note the 'D' flag).

## 4.3: Tracing Next Hop Information <a name="nexthop"></a>

Another useful feature of Network Watcher is the ability to trace the next hop for a given network destination. As an example, this is useful for diagnosing issues with User Defined Routes.

**1)** Navigate to Network Watcher as described in earlier sections.

**2)** In the left hand menu, select 'Next Hop'. Use the following parameters as input:

- Resource Group: *VDC-Spoke1*
- Virtual Machine: *Spoke1-VM1*
- Network Interface: *Spoke1-VM1-nic*
- Source IP address: *10.1.1.5*
- Destination IP address: *10.102.1.4*

**3)** The resulting output should display *10.101.2.4* as the next hop. This is the IP address of our Network Virtual Appliance (Cisco CSR) and corresponds to the User Defined Route we configured earlier.

![Next Hop Tracking](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/NextHop.jpg "Next Hop Tracking")

**Figure 21:** Next Hop Tracking

**4)** Try other combinations of IP address / virtual machine. For example, reverse the IP addresses used in the previous step.

## 4.4: Metrics and Alerts with Azure Monitor <a name="azmonalert"></a>

Azure Monitor is a tool that provides central monitoring of most Azure services, designed to give you infrastructure level diagnostics about a service and the surrounding environment. In this section of the lab, we will use Azure Monitor to look at metrics on a resource and create an alert to receive an email when a CPU threshold is crossed.

**1)** Start by using the Azure portal to navigate to the Azure Monitor view by expanding the left hand main menu and selecting 'Monitor'. If it is not shown, select 'All Services' and search for it. Select 'Activity Log' from the left hand menu. This shows a filterable view of all activity in your subscription - you can filter based on timespan, event severity, resource type and operation. Modify some of the filter fields in this screen to narrow down the search criteria.

![Azure Monitor Activity Log](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/AzMon1.jpg "Azure Monitor Activity Log")

**Figure 22:** Azure Monitor Activity Log

**2)** In the Azure Monitor menu on the left, select 'Metrics (Preview)'. In the 'resource' box at the top of the screen, search for 'onprem' and then select the 'OnPrem1_VM' virtual machine in the drop-down menu. Select 'host' as the sub-service and then 'Percentage CPU' as the metric.

![Azure Monitor CPU Metrics](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/AzMonCPU.jpg "Azure Monitor CPU Metrics")

**Figure 23:** Azure Monitor CPU Metrics

**3)** For all types of metric displayed, it is possible to configure alerts when a specific threshold is reached. Select 'Alerts' from the left hand menu and then click on 'New Alert Rule' at the top of the screen.

**4)** Click on 'Select Target' and then choose your subscription. Select 'Virtual Machines' as the resource type and then choose 'OnPrem-VM1'.

**5)** Click on 'Add Criteria' and then select 'Percentage CPU' as the signal type.

**6)** Under 'Alert Logic', ensure the condition is 'Greater than' and set the threshold to 40%. Change the period to 'Over the last 1 minute'.

**7)** Expand the section named 'Define Alert Details'. Name the alert rule 'alert-cpu' and give it a suitable description. Click OK.

**8)** Expand the section named 'Define Action Group'. Name the action group 'alert-email' (use this for the short name as well). Under 'Actions', use the same name and select 'Email/SMS/Push/Voice'. In the resulting dialog box, configure your own email address. Select OK.

**9)** On the main page, click 'Select Action Group' and select the group you have just configured.

**10)** SSH to your OnPrem_VM1 virtual machine and install the 'Stress' tool:

<pre lang="...">
sudo apt-get install stress
</pre>

**11)** Use the Stress program to hog the CPU:

<pre lang="...">
stress -c 50
stress: info: [61727] dispatching hogs: 50 cpu, 0 io, 0 vm, 0 hdd
</pre>

**12)** After approximately 5 minutes, you should receive an email alerting you to the high CPU on your VM:

![Azure Monitor CPU Alert](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/AzMonAlert.jpg "Azure Monitor CPU Alert")

**Figure 24:** Azure Monitor CPU Alert

**13)** Stop the Stress program. After another few minutes you should receive another mail informing you that the CPU percentage has reduced.

# Lab 5: Identity in the VDC Environment <a name="identity"></a>

A critical part of any data centre - whether on-premises or in the cloud - is managing identity. In this section of the lab, we will look at two of the primary mechanisms for managing identity in the virtual data centre: Azure Active Directory (AAD) and Role Based Access Control (RBAC). We will use Azure AD to create users and groups and then use RBAC to assign roles and access to resources for these groups.

In this lab, we will create three groups of users, as shown in figure 23:

![VDC Users and Groups](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/Identity.jpg "VDC Users and Groups")

**Figure 25:** VDC Lab Users and Groups

The groups will have the following rights:

- The **Central IT** group has overall responsibility for network and security components, therefore should have full control of the hub resources, with network contributor access on the spokes.

- The **AppDev** group has responsibility for compute resources in the spoke resource groups, therefore should have the contributor role for virtual machines. Users in the AppDev group would also like to view (but not configure) resources in the Hub.

- The **Ops** group are responsible for managing workloads in production, therefore will need full contributor rights in the spoke resource groups.

We'll start by configuring a number of users and groups.

## 5.1: Configure Users and Groups <a name="usersgroups"></a>

**1)** To begin, we'll verify our domain name in the Azure portal. On the left hand side of the portal screen, click 'All Services' and then search for 'Azure Active Directory'. Click on 'Domain Name' and you will see the domain assigned to your Azure AD directory.

![AAD Domain Name](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/DomainName.jpg "AAD Domain Name")

**Figure 26:** Azure AD Domain Name

**2)** Create three users (Fred, Bob and Dave) using the Azure CLI. Note that you will need to substitute your own domain in the user principal name.

<pre lang="...">
az ad user create --display-name Fred --user-principal-name Fred@*domain*.onmicrosoft.com --password M1crosoft123
az ad user create --display-name Bob --user-principal-name Bob@*domain*.onmicrosoft.com --password M1crosoft123
az ad user create --display-name Dave --user-principal-name Dave@*domain*.onmicrosoft.com --password M1crosoft123
</pre>

**3)** Create three groups (CentralIT, AppDev and Ops) using the Azure CLI:

<pre lang="...">
az ad group create --display-name CentralIT --mail-nickname CentralIT
az ad group create --display-name AppDev --mail-nickname AppDev
az ad group create --display-name Ops --mail-nickname Ops
</pre>

**4)** In order to add users to groups using the CLI, you will need the object ID of each user. To get these IDs, use the following command - make a note of the object IDs associated with each user:

<pre lang="...">
<b>az ad user list</b>
</pre>

The following is an example output from the previous command (do not use these object IDs - use your own!!):
<pre lang="...">
[
  {
    "displayName": "Bob",
    "mail": null,
    "mailNickname": "Bob",
    "objectId": "d0463199-07c8-4768-abb0-3012b1ef856f",
    "objectType": "User",
    "signInName": null,
    "userPrincipalName": "Bob@*domain*.onmicrosoft.com"
  },
  {
    "displayName": "Dave",
    "mail": null,
    "mailNickname": "Dave",
    "objectId": "69f6f292-2c2f-4451-8054-ff6addb300a4",
    "objectType": "User",
    "signInName": null,
    "userPrincipalName": "Dave@*domain*.onmicrosoft.com"
  },

  {
    "displayName": "Fred",
    "mail": null,
    "mailNickname": "Fred",
    "objectId": "4c53a57e-2a2d-4a1d-8af6-e811850a869e",
    "objectType": "User",
    "signInName": null,
    "userPrincipalName": "Fred@*domain*.onmicrosoft.com"
  }
]
</pre>

**5)** Use the object IDs to add the users to each group as follows:

- **Fred**: CentralIT
- **Bob**: AppDev
- **Dave**: Ops

The Azure CLI can be used to do this, as follows:

<pre lang="...">
az ad group member add --member-id *Fred's OID* --group CentralIT
az ad group member add --member-id *Bob's OID* --group AppDev
az ad group member add --member-id *Dave's OID* --group Ops
</pre>

## 5.2: Assign Users and Roles to Resource Groups <a name="roles"></a>

Now that we have our users and groups in place, it's time to make use of them by assigning the groups to resource groups. We will also assign roles to determine what access a group has on a given resource group.

**1)** In the Azure portal, navigate to the 'VDC-Hub' resource group and then the 'IAM' section.

**2)** You will see the user you are currently logged on as (i.e. the admin). Click 'Add' at the top of the screen and then select the 'Contributor' role from the drop down box. Select the 'CentralIT' user from the list of users and groups. Click 'save'.

**3)** Click 'Add' again, but this time select the 'Reader' role and then choose the 'AppDev' group.

![Hub RBAC](https://github.com/azurecitadel/vdc-networking-lab/blob/master/images/Hub-RBAC.jpg "Hub RBAC")

**Figure 27:** Hub Role Based Access Control

**4)** Navigate to the 'VDC-Spoke1' resource group and select 'IAM'. Click 'Add' and then select the 'Virtual Machine Contributor' role. Add the AppDev group. Repeat this step for the 'VDC-Spoke2' resource group.

**5)** For Spokes 1 and 2, add CentralIT with the 'Network Contributor' role.

**6)** For Spokes 1 and 2, add the 'Ops' group with the 'Contributor' role.

## 5.3: Test User and Group Access <a name="useraccess"></a>

Now that we have Azure AD groups assigned to resource groups with the appropriate roles, we can test the access that each user has.

**1)** Open a private browsing window / incognito window (depending on browser) and browse to the Azure portal (portal.azure.com).

**2)** Log on to the portal as Dave (dave@*domain*.onmicrosoft.com) using the password M1crosoft123.

**3)** Navigate to the resource groups view. As Dave is part of the Ops group, you will see that he has full visibility of the Spoke 1 and 2 resource groups, however Dave has no visibility of any other resource group, including the Hub.

**4)** Log off from the portal and then log on again, this time as Bob (bob@*domain*.onmicrosoft.com).

**5)** Navigate to the resource groups view. As Bob is part of the AppDev group, he has full visibility of the two Spoke resource groups, but only has read access to the VDC-Hub group. Select the VDC-Hub group and then 'Hub\_VNet'. Notice that Bob cannot make any changes to the Hub\_VNet resource, or any resource within the group.

**6)** Log off from the portal and then log on again, this time as Fred (fred@*domain*.onmicrosoft.com).

**7)** Navigate to the 'VDC-Spoke1' resource group. Select 'Hub\_VNet'. Note that Fred is able to make changes / adds, etc to the Hub\_VNet network resource (remember that Fred is part of the CentralIT group, which has the network contributor role on Spoke 1 and 2 resource groups). However, Fred is not able to see any of the virtual machine resources as the CentralIT group does not have the virtual machine contributor role on this resource group.


# Decommission the Lab <a name="decommission"></a>

To decommission the VDC lab, simply remove the resource groups using the following commands:

<pre lang="...">
az group delete --name VDC-Hub --no-wait -y
az group delete --name VDC-NVA --no-wait -y
az group delete --name VDC-Spoke1 --no-wait -y
az group delete --name VDC-Spoke2 --no-wait -y
az group delete --name VDC-OnPrem --no-wait -y
</pre>

# Conclusion <a name="conclusion"></a>

Well done, you made it to the end of the lab! We've covered a lot of ground in this lab, including networking, security, monitoring and identity - I hope you enjoyed running through the lab and that you learnt a few useful things from it. Don't forget to delete your resources after you have finished!

# Useful References <a name="ref"></a>

- **Azure Virtual Data Center White Paper:** https://azure.microsoft.com/mediahandler/files/resourcefiles/1ad643b8-73f7-43f6-b05a-8e160168f9df/Azure_Virtual_Datacenter.pdf

- **Secure Network Designs:** https://docs.microsoft.com/en-us/azure/best-practices-network-security?toc=%2fazure%2fnetworking%2ftoc.json

- **Hub and Spoke Network Topologies:** https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke

- **Azure Role Based Access Control**: https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-control-what-is

- **Azure Network Watcher:** https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-monitoring-overview

- **Azure Monitor:** https://docs.microsoft.com/en-us/azure/monitoring-and-diagnostics/monitoring-overview-azure-monitor

[◄ Lab 1: Basics](../lab1){: .btn-subtle} [▲ Index](../#labs){: .btn-subtle} [Lab 3: Outputs ►](../lab3){: .btn-success}