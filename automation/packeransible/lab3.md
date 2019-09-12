---
title: "Dynamic Inventories in Ansible"
date: 2019-08-19
author: Richard Cheney
category: automation
comments: true
featured: false
hidden: true
published: true
tags: [ ansible, dynamic, linux ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "images"
excerpt: Using dynamic inventories on Azure based on tags, resource groups and more
---

## Introduction

In this lab we will move away from static inventory lists and start generating groups automatically.

Dynamic inventories are integrated into Ansible as of version 2.8.

> If you stumble across internet sites that reference a Python script called azure_rm.py then this is the way that dynamic inventories were done prior to v2.8. Those pages are now out of date.

## Setup

In the setup for the last lab you extended the bottom of the ~/.images_env file with additional environment variables.

```bash

export AZURE_TENANT=$ARM_TENANT_ID
export AZURE_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
export AZURE_CLIENT_ID=$ARM_CLIENT_ID
export AZURE_SECRET=$ARM_CLIENT_SECRET
```

> Note that ~/_images_env is not an Ansible standard.  You could have named the file anything you like, or just exported the same environment variables in your .bashrc file.

1. Export the environment variables

    Make sure the environment variables are exported in your current session.

    ```bash
    source ~/.image_env
    ```

    > Remember that there are other options for Azure credentials, as per the [documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ansible-install-configure#create-azure-credentials)

1. Change directory to the working area

    Go back to your ansible folder for the duration of these labs:

    ```bash
    cd ~/ansible
    ```

## Dynamic inventory based on resource group filters

1. Create a third VM

    Create another VM in the ansible_vms resource group.

    ```bash
    imageId=$(az image show --resource-group packer_images --name lab1 --output tsv --query id)

    az vm create --name vm3 \
    --resource-group ansible_vms \
    --image $imageId \
    --ssh-key-values "@~/.ssh/id_rsa.pub" \
    --vnet-name vnet \
    --subnet subnet \
    --output jsonc \
    --no-wait
    ```

    > Note that we skipped the tags on this third VM.

1. Create a dynamic inventory file

    Create a configuration file called inventory.azure_rm.yml:

    ```yaml
    plugin: azure_rm

    include_vm_resource_groups:
    - ansible_vms

    auth_source: auto
    ```

    > Note that Azure inventory config filenames *must* end with either `azure_rm.yml` or `azure_rm.yaml`

1. Verify the dynamic inventory

    Check that the inventory works and the hosts can be managed:

    ```bash
    ansible all -m ping -i inventory.azure_rm.yml
    ```

    Ansible is now using hostnames rather than IP addresses. It will suffix your hostnames with a string to ensure uniqueness.

    > You can override this behaviour using `plain_host_names: yes` in your yaml inventory file.

    Once the third VM is up and running, the command should return for all three VMs in the resource group.

The include_vm_resource_groups section in the YAML config file allows multiple resource groups to be specified. If this section is omitted then all resource groups will be included.

The <https://docs.ansible.com/ansible/latest/plugins/inventory/azure_rm.html> page shows some of the other options for creating dynamic inventories.

You can include vmss_resource_groups, define different authentication methods, and filter by including or excluding based on VM naming convention, tags and their values, location and the current powerstate.

## Keyed groups

Keyed groups are very powerful as they will dynamically generate multiple groups based on the prefix and
key.

1. Add keyed groups

    Extend the inventory file with some keyed groups

    ```yaml
    keyed_groups:

    # Generate 'tag_(tag name)_(tag value)' for each tag on a VM.
    - prefix: tag
    key: tags

    # Generate 'loc_(location name)', depending on the VM's location
    - prefix: loc
    key: location
    ```

1. Verify the keyed groups

    Check that the dynamic groups work:

    ```bash
    ansible tag_owner_citadel -m ping -i inventory.azure_rm.yml
    ansible loc_westeurope -m ping -i inventory.azure_rm.yml
    ```

    Your vm3 won't be in the tag_owner_citadel group as it was created without any tags.

1. Default to the dynamic inventory

    Switch the default inventory file to the dynamic inventory. Edit the ansible.cfg file, and set the default inventory away from the static hosts inventory to the new yaml file.

    ```yaml
    [defaults]
    inventory = ~/ansible/inventory.azure_rm.yml
    default_roles_path = ~/ansible/roles
    interpreter_python = auto
    ```

1. Clean up the static file

    Remove the old static hosts file:

    ```bash
    rm ~/ansible/hosts
    ```

1. Confirm

    We are now working with dynamic inventories as the default.

    ```bash
    ansible loc_westeurope -m ping
    ```

It is up to you how you organise your groups of VMs.

You may wish to maintain named inventory files, each with filtered resource groups and VM types, and with its own keyed groups. You would then use the `-i` switch to specify the alternate inventory file.

That would be one way to organise your dynamic inventories. Instead we'll maximise the default dynamic inventory yaml file to generate as many useful groups as possible.

## Keyed groups format

We'll add to the number of automatically generated dynamic groups by extending the keyed groups.

The keyed groups all defined under the `keyed_groups:` section, and have the following format.

```yaml
- prefix: loc
  key: location
```

The prefix is a text string that prefixes the resulting auto generated groups.  It is combined with underscore and then the key, which in this example is location.  With our VMs this resulted in a group called **loc_westeurope**. (You can override the underscore default separator if desired.)

## Instance Metadata Service

Adding the Azure dynamic inventories functionality has added a wide number of Azure platform values to the hostvars set.  These have been pulled from the [Azure instance metadata service](https://docs.microsoft.com/azure/virtual-machines/windows/instance-metadata-service), so we'll take a quick look at that now.

1. SSH onto one of your hosts
1. Hit the Instance Metadata Service

    Run the following command to see the Azure environmental information for that Ubuntu server

    ```bash
    curl -sH Metadata:true "http://169.254.169.254/metadata/instance/?api-version=2019-03-11" | jq .
    ```

    > Piping the minified JSON through jq will output coloured and prettified JSON

    Example output:

    ```json
    {
    "compute": {
        "azEnvironment": "AzurePublicCloud",
        "customData": "",
        "location": "westeurope",
        "name": "vm1",
        "offer": "",
        "osType": "Linux",
        "placementGroupId": "",
        "plan": {
        "name": "",
        "product": "",
        "publisher": ""
        },
        "platformFaultDomain": "0",
        "platformUpdateDomain": "0",
        "provider": "Microsoft.Compute",
        "publicKeys": [
        {
            "keyData": "<REDACTED>",
            "path": "/home/richeney/.ssh/authorized_keys"
        }
        ],
        "publisher": "",
        "resourceGroupName": "ansible_vms",
        "resourceId": "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/ansible_vms/providers/Microsoft.Compute/virtualMachines/vm1",
        "sku": "",
        "subscriptionId": "2d31be49-d999-4415-bb65-8aec2c90ba62",
        "tags": "managed_by:ansible;owner:citadel",
        "version": "",
        "vmId": "526a1d3a-467c-400b-8ea0-ab2d0f393bff",
        "vmScaleSetName": "",
        "vmSize": "Standard_DS1_v2",
        "zone": ""
    },
    "network": {
        "interface": [
        {
            "ipv4": {
            "ipAddress": [
                {
                "privateIpAddress": "10.0.0.4",
                "publicIpAddress": "65.52.158.233"
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
            "macAddress": "000D3A4A002D"
        }
        ]
    }
    }
    ```

    If you are bash scripting on a host then it is common to pull the metadata JSON into a file and then pull out values using jq. Or you can use a fully pathed value directly using the service, e.g.:

    ```bash
    pip=$(curl -sH Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2019-03-11&format=text")
    echo $pip
    ```

1. Exit the SSH session

    Exit back to your desktop:

    ```bash
    exit
    ```

## Ansible hostvars

A subset of the Azure instance metadata is being pulled into the hostvars now that you are using dynamic inventories. You can view these hostvars using the debug module from Ansible.

1. View the hostvars visible from one host

    ```bash
    ansible vm1_c069 -m debug -a 'var=hostvars'
    ```

    Excerpt of example output for one of the hosts:

    ```json
    {
        "ansible_check_mode": false,
        "ansible_diff_mode": false,
        "ansible_facts": {},
        "ansible_forks": 5,
        "ansible_host": "13.94.232.252",
        "ansible_inventory_sources": [
            "/home/richeney/ansible/inventory.azure_rm.yml"
        ],
        "ansible_playbook_python": "/usr/bin/python",
        "ansible_verbosity": 0,
        "ansible_version": {
            "full": "2.8.3",
            "major": 2,
            "minor": 8,
            "revision": 3,
            "string": "2.8.3"
        },
        "group_names": [
            "loc_westeurope"
        ],
        "groups": {
            "all": [
                "vm1_c069",
                "vm2_8506",
                "vm3_7e2c"
            ],
            "loc_westeurope": [
                "vm1_c069",
                "vm2_8506",
                "vm3_7e2c"
            ],
            "tag_managed_by_ansible": [
                "vm1_c069",
                "vm2_8506"
            ],
            "tag_owner_citadel": [
                "vm1_c069",
                "vm2_8506"
            ],
            "ungrouped": []
        },
        "id": "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/ansible_vms/providers/Microsoft.Compute/virtualMachines/vm3",
        "image": {
            "id": "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/packer_images/providers/Microsoft.Compute/images/lab1"
        },
        "inventory_dir": "/home/richeney/ansible",
        "inventory_file": "/home/richeney/ansible/inventory.azure_rm.yml",
        "inventory_hostname": "vm3_7e2c",
        "inventory_hostname_short": "vm3_7e2c",
        "location": "westeurope",
        "mac_address": "00-0D-3A-4A-6D-13",
        "name": "vm3",
        "network_interface": "vm3VMNic",
        "network_interface_id": "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/ansible_vms/providers/Microsoft.Network/networkInterfaces/vm3VMNic",
        "omit": "__omit_place_holder__3c14a05b4e80fe0ed654257a299a255d3cd93bfc",
        "os_disk": {
            "name": "vm3_disk1_18a9d5b216c74c649d51e8d67612fa72",
            "operating_system_type": "linux"
        },
        "plan": null,
        "playbook_dir": "/home/richeney/ansible",
        "powerstate": "running",
        "private_ipv4_addresses": [
            "10.0.0.6"
        ],
        "provisioning_state": "succeeded",
        "public_dns_hostnames": [],
        "public_ip_id": "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/ansible_vms/providers/Microsoft.Network/publicIPAddresses/vm3PublicIP",
        "public_ip_name": "vm3PublicIP",
        "public_ipv4_addresses": [
            "13.94.232.252"
        ],
        "resource_group": "ansible_vms",
        "resource_type": "Microsoft.Compute/virtualMachines",
        "security_group": "vm3NSG",
        "security_group_id": "/subscriptions/2d31be49-d999-4415-bb65-8aec2c90ba62/resourceGroups/ansible_vms/providers/Microsoft.Network/networkSecurityGroups/vm3NSG",
        "tags": {},
        "virtual_machine_size": "Standard_DS1_v2",
        "vmid": "b0ae2ca7-d524-4d26-9cd8-e59ca240756e",
        "vmss": {}
    }
    ```

> Note that this output only shows the information for one host.  Each host actually sees the hostvar info for others in the inventory.

You can see that _location_ and _tags_ are in the list, and this is where the current keyed groups are taking their information.

## Adding simple hostvar keyed groups

We can use any of these hostvars to create additional keyed groups.

Let's add keyed groups based on resource group, operating system type and VM size.

1. Add metadata keyed groups

    Extend the `keyed_groups:` section of your inventory yaml file:

    ```yaml
    # Generate rg_(resource_group)
    - prefix: rg
    key: resource_group

    # Generate os_type_(os_type)
    - prefix: os
    key: os_disk.operating_system_type

    # Generate vm_size_(vm_size)
    - prefix: vm_size
    key: virtual_machine_size
    ```

1. List the groups and members

    List out the auto generate groups and the membership:

    ```bash
    ansible localhost -m debug -a 'var=groups.keys()'
    ansible localhost -m debug -a 'var=groups'
    ```

## Using nested values and Jinja2 filters

If you want to use a nested value then just use the standard dot notation.

For example, the operating system type is within the os_disk hostvar:

```json
    "os_disk": {
        "name": "vm3_disk1_18a9d5b216c74c649d51e8d67612fa72",
        "operating_system_type": "linux"
    },
```

So your keyed group would look like:

```yaml
# Generate os_type_(os_type)
- prefix: os
  key: os_disk.operating_system_type
```

Assuming that you have followed the labs all the way through, then one of your three VMs will not have any tags.

## Defaults

There is more functionality shown in the [documentation](https://docs.ansible.com/ansible/latest/plugins/inventory/azure_rm.html). One of those is using defaults.

If you remember the tags keyed group then it was in this format:

```yaml
# Generate 'tag_(tag name)_(tag value)' for each tag on a VM.
- prefix: tag
  key: tags
```

This does all of the tags. But it won't provide a group for an important tag that is missing a value. What if we wanted to look at all servers that didn't have an owners tag?

You can use the following format to get a specific set of owner tags keyed groups including an owner_none group for those that do not have a defined owner value:

```yaml
# Generate 'owner__(owner value)'
- prefix: owner
  key: tags.owner | default('none')
```

## Complete the dynamic inventory file

1. Finalise the dynamic inventory

    If you haven't already done so, add those two blocks into the keyed groups area:

    ```yaml
    # Generate os_type_(os_type)
    - prefix: os
    key: os_disk.operating_system_type
    # Generate 'owner__(owner value)'
    - prefix: owner
    key: tags.owner | default('none')
    ```

1. List the groups

    ```bash
    ansible localhost -m debug -a 'var=groups'
    ```

## Debug messages

We can now also use the extended set of hostvars in debug messages.  This will be useful in the next lab within the Ansible Playbook.

1. Display a custom debug message

{% raw %}

```bash
ansible all -m debug -a "msg='{{ inventory_hostname }} ({{ ansible_host }})) is {{ powerstate }}.'"
```

{% endraw %}

These use the [Jinja2](https://ansible-docs.readthedocs.io/zh/stable-2.0/rst/playbooks_variables.html#using-variables-about-jinja2) expressions.

## Coming up next

In the next section we will look at playbooks and publishing to the shared image gallery.

## References

* <https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ansible-install-configure>
* <https://www.ansible.com/resources/get-started>
* <https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html>
* <https://www.howtoforge.com/ansible-guide-ad-hoc-command/>
* <http://docs.ansible.com/ansible/modules_by_category.html>
* <https://docs.microsoft.com/en-us/azure/ansible/ansible-manage-azure-dynamic-inventories>
* <https://docs.ansible.com/ansible/latest/plugins/inventory/azure_rm.html>

[◄ Lab 2: Packer](../lab2){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 4: Shared Image Gallery ►](../lab4){: .btn .btn--primary}
