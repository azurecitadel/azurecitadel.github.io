#!/bin/bash

## vNet to vNet VPN Gateway connections
hubVpnGwId=$(az network vnet-gateway show --resource-group VDC-Hub --name Hub-vpn-gw --query id --output tsv)
onpremVpnGwId=$(az network vnet-gateway show --resource-group VDC-OnPrem --name OnPrem-vpn-gw --query id --output tsv)

az network vpn-connection create --name Hub2OnPrem --vnet-gateway1 $hubVpnGwId --vnet-gateway2 $onpremVpnGwId --shared-key M1crosoft123 --resource-group VDC-Hub
az network vpn-connection create --name OnPrem2Hub --vnet-gateway1 $onpremVpnGwId --vnet-gateway2 $hubVpnGwId --shared-key M1crosoft123 --resource-group VDC-OnPrem

## Configure the CSR 

csrPip=$(az network public-ip show --name csr-pip --resource-group VDC-NVA --query ipAddress --output tsv)

ssh labuser@$csrPip <<-EOF
	conf t
	interface gig1
	ip address dhcp
	no shut
	interface gig2 
	ip address dhcp
	no shut
	file prompt quiet
	end
	copy running-config startup-config
	show ip interface brief
	exit
	EOF

## Create UDR for Hub vNet to static "external" CSR internal IP

az network route-table create --name OnPrem-UDR --resource-group VDC-OnPrem
az network route-table route create --name Spoke1-Route --address-prefix 10.1.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.1.4 --route-table-name OnPrem-UDR --resource-group VDC-OnPrem
az network route-table route create --name Spoke2-Route --address-prefix 10.2.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.1.4 --route-table-name OnPrem-UDR --resource-group VDC-OnPrem
az network vnet subnet update --name GatewaySubnet --vnet-name OnPrem-vnet --route-table OnPrem-UDR --resource-group VDC-OnPrem

## Create UDR for Hub vNet to static "external" CSR internal IP

az network route-table create --name Hub-UDR --resource-group VDC-Hub
az network route-table route create --name Spoke1-Route --address-prefix 10.1.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.1.4 --route-table-name Hub-UDR --resource-group VDC-Hub
az network route-table route create --name Spoke2-Route --address-prefix 10.2.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.1.4 --route-table-name Hub-UDR --resource-group VDC-Hub
az network vnet subnet update --name GatewaySubnet --vnet-name Hub-vnet --route-table Hub-UDR --resource-group VDC-Hub

## And for the spokes to the "internal" CSR internal IP

az network route-table create --name Spoke1-UDR -g VDC-Spoke1
az network route-table create --name Spoke2-UDR -g VDC-Spoke2

az network route-table route create --name OnPrem-Route --address-prefix 10.102.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.2.4 --route-table-name Spoke1-UDR -g VDC-Spoke1
az network route-table route create --name OnPrem-Route --address-prefix 10.102.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.101.2.4 --route-table-name Spoke2-UDR -g VDC-Spoke2

az network vnet subnet update --name Spoke1-vnet-subnet1 --vnet-name Spoke1-vnet --route-table Spoke1-UDR -g VDC-Spoke1
az network vnet subnet update --name Spoke2-vnet-subnet1 --vnet-name Spoke2-vnet --route-table Spoke2-UDR -g VDC-Spoke2

## Update peerings 

az network vnet peering update --set useRemoteGateways=true --resource-group VDC-Spoke1 --name to-Hub-vnet --vnet-name Spoke1-vnet
az network vnet peering update --set useRemoteGateways=true --resource-group VDC-Spoke2 --name to-Hub-vnet --vnet-name Spoke2-vnet

# Test out the connectivity

onpremVmPip=$(az network public-ip show --name OnPrem-vm-pip --resource-group VDC-OnPrem --query ipAddress --output tsv)
spoke1LbPip=$(az network public-ip show --name Spoke1-lb-pip --resource-group VDC-Spoke1 --query ipAddress --output tsv)

ssh labuser@$onpremVmPip 