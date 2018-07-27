#!/bin/bash

## vNet to vNet VPN Gateway connections
az network vpn-connection create --name Hub2OnPrem --vnet-gateway1 Hub-vnet-gw --vnet-gateway2 OnPrem-vnet-gw --shared-key M1crosoft123 --resource-group VDC-Hub
az network vpn-connection create --name OnPrem2Hub --vnet-gateway1 OnPrem-vnet-gw --vnet-gateway2 Hub-vnet-gw --shared-key M1crosoft123 --resource-group VDC-OnPrem

csrPip=$(az network nic ip-config list --resource-group VDC-NVA --nic-name csr-pip --query "[? name == 'ipconfig1'].publicIpAddress.ipAddress" --output tsv)