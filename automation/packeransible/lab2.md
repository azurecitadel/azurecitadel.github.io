---
title: "Basic Ansible Management"
date: 2019-08-19
author: Richard Cheney
category: automation
comments: true
featured: false
hidden: true
published: true
tags: [ ansible, ad hoc, linux ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "images"
excerpt: Run ad hoc Ansible commands against static inventories
---

## Introduction

In this lab we will install Ansible locally, and then work through some of things it can do when using it ad hoc. We will be using the two VMs we created in the previous lab.

## Ansible

Ansible could be a very large set of labs by itself. It is popular for configuration management as it is open source, extensible, multi platform and agentless. We could use Ansible to provision the Azure infrastructure, but we will leave that job to Terraform.

In these labs we will use Ansible purely for configuring the images and helping to manage the VMs once they have been deployed from the image.

Ansible is growing in popularity as it is open source, extensible, multi platform, powerful and agentless. It uses OpenSSH to connect to linux servers and WinRm to connect to Windows servers.

You should be aware that there are many other options in the configuration management space, such as Chef, Puppet, Salt, Octopus, etc.

Go to <https://www.ansible.com/resources/get-started> and watch the Quick Start Video to get an overview of the Ansible functionality and ecosystem.

## Initialise

In this section you'll create a local Ansible area to work in, including a default cfg file and a static hosts file containing the public IP addresses for the two VMs we created in the previous lab.

1. Create an ansible folder

    ```bash
    umask 077
    mkdir -m 700 ~/ansible && cd ~/ansible
    ```

    We will be intentionally strict with permissions.

1. Install Ansible

    ```bash
    sudo apt-get update && sudo apt-get install -y libssl-dev libffi-dev python-dev python-pip
    sudo -H pip install ansible[azure]
    ```

    As per the [Ansible install guide](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ansible-install-configure) for Azure.

1. Extend the .env file

    We'll reuse the service principal from lab1 for Ansible to authenticate to Azure's ARM layer.

    Add the following to the bottom of the ~/.images_env file.

    ```bash

    export AZURE_TENANT=$ARM_TENANT_ID
    export AZURE_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
    export AZURE_CLIENT_ID=$ARM_CLIENT_ID
    export AZURE_SECRET=$ARM_CLIENT_SECRET
    ```

    Note that the environment variables used by Ansible are slightly different to those used by Packer.

1. Export the additional set of environment variables

    ```bash
    source ~/.image_env
    ```

    > There are many other options for Azure credentials, as per the [documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ansible-install-configure#create-azure-credentials)

1. Create an *ansible.cfg* file

    The file should contain the following:

    ```text
    inventory = ~/ansible/hosts
    default_roles_path = ~/ansible/roles
    interpreter_python = auto
    host_key_checking = false
    nocows = 1
    ```

    > For info on the config file: <https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html#intro-configuration>

1. Create a static *hosts* inventory

    The file should be in the following format, but you will need to specify the public IP addresses of the VMs you created in lab1.

    ```yaml
    [citadel]
    65.52.158.233
    104.47.146.216
    ```

    If you wanted to do that programmatically:

    ```bash
    echo "[citadel]" > hosts
    az vm list-ip-addresses --resource-group ansible_vms --output tsv --query [].virtualMachine.network.publicIpAddresses[0].ipAddress >> hosts
    ```

    > Read our [JMESPATH guide](https://azurecitadel.com/prereqs/cli/cli-3-jmespath/) if you want to know how to construct your own queries

1. Check your config

    ```bash
    ansible --version
    ```

    Example output:

    ```text
    ansible 2.8.3
    config file = /home/richeney/ansible/ansible.cfg
    configured module search path = [u'/home/richeney/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
    ansible python module location = /usr/local/lib/python2.7/dist-packages/ansible
    executable location = /usr/local/bin/ansible
    python version = 2.7.15+ (default, Nov 27 2018, 23:36:35) [GCC 7.3.0]
    ```

## Hosts files

The hosts file is an inventory file. These may have multiple server groupings, and hosts can belong to more than one group. We have defined just one group, "citadel", and will use that. All servers belong to the default "all" group.

As per the video, inventories can be defined in different ways:

* Static lines of servers
    * IP addresses
    * fully qualified domain names (FQDNs)
* IP address ranges
* Other custom things
* Dynamic lists of servers

We will look at dynamic inventories in a later lab.

## Getting started with Ansible

The [intro_adhoc](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html) page is very good and worth reading.

Below are some good commands to begin with.

1. list all of the servers in the inventory

    ```bash
    ansible all --list-hosts
    ```

    Example output:

    ```yaml
    hosts (2):
        65.52.158.233
        104.47.146.216
    ```

    This command used the *all* group.  You could have instead specified *citadel*, or any other group that you have defined in the inventory file.

1. Check the citadel group

    Check that the servers in the citadel group are running and can be managed by Ansible

    ```bash
    ansible citadel -m ping
    ```

    Example output:

    ```text
    65.52.158.233 | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false,
        "ping": "pong"
    }
    104.47.146.216 | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false,
        "ping": "pong"
    }
    ```

## Using the command and shell modules

That last command used the ping module. Modules are core to how Ansible works.

If you do not specify a module then ansible will default module to *command*. Here is an example short form.

1. Run a simple command

    ```bash
    ansible citadel -a whoami
    ```

    Example output:

    ```text
    104.47.146.216 | CHANGED | rc=0 >>
    richeney

    65.52.158.233 | CHANGED | rc=0 >>
    richeney

    ```

1. Run the same command as root

    The `-a` switch is for arguments. Here is a long form version of the previous command, adding `--become` to sudo to root.

    ```bash
    ansible citadel --args "/usr/bin/whoami" -become
    ```

    Example output:

    ```text
    104.47.146.216 | CHANGED | rc=0 >>
    root

    65.52.158.233 | CHANGED | rc=0 >>
    root

    ```

    > Fully pathing commands is a sensible security stance with sudo commands

1. Use the shell module

    The *command* module can only do simple commands.  For anything more complex then you can specify the *shell* module.

    ```bash
    ansible citadel -m shell -a "cd ~; /bin/pwd" -b
    ```

    Example output:

    ```text
    104.47.146.216 | CHANGED | rc=0 >>
    /root

    65.52.158.233 | CHANGED | rc=0 >>
    /root

    ```

## Raising concurrency

Ansible will fork multiple processes when talking to multiple hosts.  The default number of concurrent forked processes is rather low at 5.

Use the `-f` switch to specify a larger number for bigger groups. For example:

```bash
ansible dev -a "/sbin/reboot" -f 20
```

> This is an example - there is no dev group defined in the hosts inventory and so this command will fail if you run it.

## Modules

Browse the list of inbuilt modules at <http://docs.ansible.com/ansible/modules_by_category.html>.

The <https://www.howtoforge.com/ansible-guide-ad-hoc-command/> blog page is a useful reference for some common ad hoc module calls.

We'll use the apt module for an ad hoc package installation on Ubuntu.

> Note that we installed aptitude into the Ubuntu image for lab1, but the apt module will default to using the lower level apt-get package manager if aptitude is not present.

1. Install the _cowsay_ package

    ```bash
    ansible citadel -m apt -a "name=cowsay state=present" -b
    ```

    > Check the [apt module](https://docs.ansible.com/ansible/latest/modules/apt_module.html) page and you will see that the arguments here are a space delimited list of parm=value pairs that match the parameters for the ansible module.

1. Create a simple script

    Another common ad hoc module is copy. Let's create a simple script and push that onto both of the VMs.

    Create a file called myscript.sh containing the following

    ```bash
    #!/bin/bash

    /bin/hostname| /usr/games/cowsay | /usr/games/lolcat
    ```

1. Copy the script to /usr/local/bin as root

    ```bash
    ansible citadel -m copy -a 'src=./myscript.sh dest=/usr/local/bin/myscript.sh owner=root mode=0755' --become
    ```

1. Run the script on both VMs

    ```bash
    ansible citadel -a '/usr/local/bin/myscript.sh'
    ```

    > If you ran the script locally then you notice that lolsay produces rainbow coloured output.  With ansible the colours are all stripped out.

Browse the [modules](http://docs.ansible.com/ansible/modules_by_category.html) and see what other options there were for uploading and then executing a script.

Using modules in this way is a great way for dealing with consistently applying simple ad hoc changes to groups of servers.

We have run through a few examples, but you will commonly see ad hoc commands used to

* add users to the /etc/passwd files,
* start, stop or restart services
* initiate reboots

And Ansible is very useful to do that consistently across groups of virtual machines.

## Getting information via Setup and Debug

You can get an enormous number of ansible _facts_ from your hosts using the [setup](https://docs.ansible.com/ansible/latest/modules/setup_module.html) module.

1. Select a host

    Pick one of the hosts from the list:

    ```bash
    ansible all --list-hosts
    ```

    I will use the host with a public IP of 65.52.158.233 in the following examples.

1. List out the facts

    List out all of the facts for a host:

    ```bash
    ansible 65.52.158.233 -m setup | more
    ```

1. Filter on a string

    ```bash
    ansible 65.52.158.233 -m setup -a "filter=ansible_distribution*"
    ```

1. Get a subset of the output

    ```bash
    ansible 65.52.158.233 -m setup -a 'gather_subset=!all,!min,network'
    ```

    You can also use the [debug](https://docs.ansible.com/ansible/latest/modules/debug_module.html) tool.  This is useful for creating messages, and for showing the list of hostvars available.

1. display the available _hostvars_

    ```bash
    ansible 65.52.158.233 -m debug -a 'var=hostvars'
    ```

    You should see the hostvars information from the host's perspective, but it will include information about both hosts in the inventory, including group information.

1. List out the groups

    ```bash
    ansible localhost -m debug -a 'var=groups.keys()'
    ```

1. List the hosts's group memberships

    See the groups that a host belongs to using:

    ```bash
    ansible localhost -m debug -a 'var=groups'
    ```

* List all groups and host members

    To see which groups every hosts belongs to:

    ```bash
    ansible citadel -m debug -a 'var=group_names'
    ```

## Coming up next

The hostvars available per host includes only a very basic set of information, so it isn't particularly useful just yet. We will be extending this with lots of Azure specific information in the next lab.

We will also move from static to dynamic inventories.

## References

* <https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ansible-install-configure>
* <https://www.ansible.com/resources/get-started>
* <https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html>
* <https://www.howtoforge.com/ansible-guide-ad-hoc-command/>
* <http://docs.ansible.com/ansible/modules_by_category.html>
* <https://docs.ansible.com/ansible/latest/modules/setup_module.html>
* <https://docs.ansible.com/ansible/latest/modules/debug_module.html>
* <https://docs.microsoft.com/azure/virtual-machines/windows/instance-metadata-service>
* <https://ansible-docs.readthedocs.io/zh/stable-2.0/rst/playbooks_variables.html#using-variables-about-jinja2>

[◄ Lab 1: Packer](../lab1){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 3: Dynamic Inventories ►](../lab3){: .btn .btn--primary}
