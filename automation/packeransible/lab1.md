---
title: "Basic image creation with Packer"
date: 2019-10-07
author: Richard Cheney
category: automation
comments: true
featured: false
hidden: true
published: true
tags: [ image, packer, linux ]
header:
  overlay_image: images/header/gherkin.jpg
  teaser: images/teaser/packeransible.png
sidebar:
  nav: "packeransible"
excerpt: Generate a simple Ubuntu image and then deploy VMs from it
---

## Introduction

In this lab you will create a custom image using Packer, and then use it to deploy two VMs. These will be used in the next lab.

If you already have Packer installed then skip to the [working environment](#create-a-working-environment-for-packer) step.

If you do not have Packer installed then you can either [install Packer manually](#install-packer-manually) or using a [script](#scripted-packer-installation).

## Install Packer manually

If installing Packer manually:

1. Follow Hashicorp's instructions for installing the binary if you haven't done so as part of the [prereqs](../prereqs):

    <https://www.packer.io/intro/getting-started/install.html#precompiled-binaries>

    (As with all Hashicorp binaries this is an intentionally manual process. Allowing the admin full visibility and control over the versioning     throughout the whole configuration management stack is part of the company ethos.)

1. Check the location and version

    ```bash
    which packer
    packer --version
    ```

## Scripted Packer installation

Alternatively you may use a scripted installation:

1. Download the script

    ```bash
    script=installLatestHashicorpBinary.sh
    curl -sSL https://raw.githubusercontent.com/richeney/arm/master/scripts/$script --output $script && chmod 755 $script
    ```

1. Run the script

    ```bash
    ./installLatestHashicorpBinary.sh packer
    ```

## Create a working environment for Packer

In this section you'll create:

* a resource group where Packer will store the generated images
* a secure folder for your Packer config files
* a service principal for Packer to access your Azure subscription
* extend your .bashrc file with the required environment variables

> You can hardcode the tenancy, subscription and service principal details in the JSON files, but we will make use of environment variables instead.

1. Create a resource group

    ```bash
    az group create --name images --location westeurope --output jsonc
    ```

    Example output:

    ```json
    {
      "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/images",
      "location": "westeurope",
      "managedBy": null,
      "name": "images",
      "properties": {
        "provisioningState": "Succeeded"
      },
      "tags": null,
      "type": "Microsoft.Resources/resourceGroups"
    }
    ```

1. Create a folder for your lab files.  The commands below will create a subdirectory in your home directory:

    ```bash
    mkdir -m 755 ~/packer && cd ~/packer
    ```

1. Create a service principal for packer to use

    You will need a service principal to create the images using Packer.  We will call is `http://hashicorp` as we will also use it for Terraform in a later lab. The packer image generation process will create a temporary resource group so the service principal needs sufficient permissions to create one. We'll use Contributor.

    Capture the output from the `az ad sp create-for-rbac` command as you will need the values for some environment variables.

    ```bash
    name="http://hashicorp"
    subId=$(az account show --output tsv --query id)
    az ad sp create-for-rbac --name $name --role="Contributor" --scopes="/subscriptions/$subId" --output json
    ```

    > If you are in a shared environment and `http://hashicorp` has been taken by someone else then set `name="http://hashicorp-${subId}-sp"` and then retry the `az ad sp create-for-rbac` command above..

    Example output:

    ```json
    {
      "appId": "19704041-8953-47f5-9b58-45c58f7fb9be",
      "displayName": "hashicorp",
      "name": "http://hashicorp",
      "password": "5ddd8baf-4780-41c9-b7a0-6e23f242d275",
      "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
    }
    ```

    Take a copy of the screen output for that last command. You will need some of the values in the next step.

1. Extend your ~/.bashrc file with your preferred editor

    E.g. vscode, vi, or nano.

1. Add the export commands for the environment variables

    Packer can use environment variables for authentication:

    **Environment variable** | **`az ad sp create-for-rbac` value**
    **ARM_TENANT_ID** | **tenant**
    **ARM_SUBSCRIPTION_ID** | **_Use your existing $subId value_**
    **ARM_CLIENT_ID** | **appId**
    **ARM_CLIENT_SECRET** | **password**

    Example lines added to .bashrc, based on the values returned in the command output above:

    ```bash
    # Environment variables for Packer and Terraform
    export ARM_TENANT_ID=72f988bf-86f1-41af-91ab-2d7cd011db47
    export ARM_SUBSCRIPTION_ID=2ca40be1-7e80-4f2b-92f7-06b2123a68cc
    export ARM_CLIENT_ID=19704041-8953-47f5-9b58-45c58f7fb9be
    export ARM_CLIENT_SECRET=5eee8baf-4780-41c9-b7a0-6e23f242d275
    ```

    **Ensure your values are modified to match those shown in the output of your `az ad sp create-for-rbac` command.**

    > You can always rerun the `az ad sp create-for-rbac` command above which will also change the password value.

1. Source the .bashrc file

    ```bash
    source ~/.bashrc
    ```

1. Check the environment variables are set

    ```bash
    env | grep ARM
    ```

    Example output:

    ```text
    ARM_SUBSCRIPTION_ID=2ca40be1-7e80-4f2b-92f7-06b2123a68cc
    ARM_TENANT_ID=72f988bf-86f1-41af-91ab-2d7cd011db47
    ARM_CLIENT_ID=19704041-8953-47f5-9b58-45c58f7fb9be
    ARM_CLIENT_SECRET=5eee8baf-4780-41c9-b7a0-6e23f242d275
    ```

    OK, you're set.

## Create the Packer template

1. Create a file called lab1.json with the following template

    {% raw %}

    ```json
    {
      "variables": {
        "tenant_id": "{{env `ARM_TENANT_ID`}}",
        "subscription_id": "{{env `ARM_SUBSCRIPTION_ID`}}",
        "client_id": "{{env `ARM_CLIENT_ID`}}",
        "client_secret": "{{env `ARM_CLIENT_SECRET`}}"
      },
      "builders": [{
        "type": "azure-arm",

        "client_id": "{{user `client_id`}}",
        "client_secret": "{{user `client_secret`}}",
        "subscription_id": "{{user `subscription_id`}}",
        "tenant_id": "{{user `tenant_id`}}",

        "managed_image_resource_group_name": "images",
        "managed_image_name": "lab1",

        "os_type": "Linux",
        "image_publisher": "Canonical",
        "image_offer": "UbuntuServer",
        "image_sku": "18.04-LTS",

        "azure_tags": {
            "created_by": "packer",
            "source_template": "~/packer/lab1.json"
        },

        "location": "westeurope",
        "vm_size": "Standard_B1s"
      }],
      "provisioners": [
        {
          "execute_command": "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'",
          "inline": [
            "apt-get update",
            "apt-get upgrade -y",
            "apt-get install git jq tree wget lolcat aptitude stress -y"
          ],
          "inline_shebang": "/bin/sh -x",
          "type": "shell"
        },
        {
          "execute_command": "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'",
          "inline": [
            "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
          ],
          "inline_shebang": "/bin/sh -x",
          "type": "shell"
        }
      ]
    }
    ```

    {% endraw %}

    Look at the provisioners array near the bottom of the file.  It has two steps, both running a shell command with an inline array.  The first step has a few commands in that array will update the operating system and then install a few packages. The second step has a single command that will generalise the virtual machine into an image.

    > If you need to use a different location, size, or platform image then you may find the following example commands useful:
    >
    > ```bash
    > az account list-locations --output table
    > az vm list-sizes --location westeurope --output table
    > az vm image list-publishers --location westeurope --output table
    > az vm image list-offers --publisher SUSE --location westeurope --output table
    > az vm image list-skus --publisher SUSE --offer SLES --location westeurope --output table
    > ```

## Run the build

1. Run packer to build the image

    ```bash
    packer build lab1.json
    ```

    The command will show progress with output to screen.  Once complete, it will be an image resource type, ready to use for a deployment. Standard VM images use the `Microsoft.Compute/images` provider type.

1. List the resulting image

    ```bash
    az image list --resource-group images --output table
    ```

    Example output:

    ```text
    HyperVgeneration    Location    Name    ProvisioningState    ResourceGroup
    ------------------  ----------  ------  -------------------  ---------------
    V1                  westeurope  lab1    Succeeded            images
    ```

## SSH Keys

You will need SSH keys in the following steps. If you already have SSH keys then skip to the [deploy](#deploy) steps.

1. Generate SSH keys

    ```bash
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
    ```

    The SSH key pair will be created in a default location and with default names.

1. List the files

    ```bash
    ls -l ~/.ssh
    ```

    Example output:

    ```text
    total 12
    -rw------- 1 richeney richeney 1675 Aug  6 13:24 id_rsa
    -rw-r--r-- 1 richeney richeney  405 Aug  6 13:24 id_rsa.pub
    ```

    Note the file permissions. The -N switch defines a new passphrase which is empty. This isn't very security aware, so if you are creating ssh keys for production then look at `man ssh-keygen`.

## Deploy

Many of the Azure docs examples will deploy VMs from the images, but will also create public IP addresses, virtual networks and subnets per VM.  This is very useful for quickly spinning up a test VM. In production you are more likely to deploy VMs without any of these and attach them to existing subnets.

In this section we will create a resource group, vNet and subnet and then attach the deployed VMs to the subnet.

> We would normally use `--public-ip-address ""` on the CLI to avoid creating a public IP address, and would then connect across S2S VPN or Express Route to the private IP addresses. For this lab we'll keep it simple and use the public IP addresses.

1. Create a resource group for the VMs

    ```bash
    az group create --name ansible_vms --location westeurope
    ```

1. Create a virtual network

    ```bash
    az network vnet create --resource-group ansible_vms --name vnet --address-prefix 10.0.0.0/16 --subnet-name subnet --subnet-prefix 10.0.0.0/24
    ```

1. Set a variable to your image's resource ID

    ```bash
    imageId=$(az image show --resource-group images --name lab1 --output tsv --query id)
    ```

    > Note: if you are deploying VMs into the same resource group as the image then `az vm create` command can use the far shorter image name (e.g. lab1) rather than the full ID

1. Create vm1 from the lab1 image

    ```bash
    az vm create --name vm1 \
      --resource-group ansible_vms \
      --image $imageId \
      --ssh-key-values "@~/.ssh/id_rsa.pub" \
      --vnet-name vnet \
      --subnet subnet \
      --tags owner=citadel docker=true \
      --output jsonc \
      --no-wait
    ```

    The command returned immediately as we specified `--no-wait`. The job will be visible in the Deployments screen within the ansible_vms resource group.

1. Create vm2

    ```bash
    az vm create --name vm2 \
      --resource-group ansible_vms \
      --image $imageId \
      --ssh-key-values "@~/.ssh/id_rsa.pub" \
      --vnet-name vnet \
      --subnet subnet \
      --tags owner=citadel docker=true \
      --output jsonc \
      --no-wait
    ```

    Both are now deploying. We will use the two VMs in the next lab. Note the tags we added; we'll be using those for dynamic inventories in a later lab.

## Connect to the VM

Working ssh access to deployed VMs is critical to making use of Ansible. In this section you will check that the VM deployments have completed, connecting using SSH and then check that the packages were installed successfully.

1. Check the status of the VM deployments

    ```bash
    az group deployment list --resource-group ansible_vms --output table
    ```

    > Repeat this command until both show a state of succeeded.

1. List out the IP addresses

    ```bash
    az vm list-ip-addresses --resource-group ansible_vms --output table
    ```

1. SSH into the public IP address for vm1

    Connect using `ssh <userid>@<publicIpAddress>`.

    Example SSH command below. Your public IP address will be different.

    ```bash
    ssh richeney@13.95.141.87
    The authenticity of host '13.95.141.87 (13.95.141.87)' can't be established.
    ECDSA key fingerprint is SHA256:ODtHkhERTQx+bUc3ZEL1LBW41VxtGf9JboqYtXe6Dc4.
    Are you sure you want to continue connecting (yes/no)? yes
    ```

    > Answering yes will add the server to the `~/.ssh/authorized_keys` file. Future ssh connections will go straight in.

1. Test that the additional packages were installed correctly into the image

    ```bash
    tree /usr/local | lolcat
    ```

    Example output:

    ```text
    /usr/local
    ├── bin
    ├── etc
    ├── games
    ├── include
    ├── lib
    │   ├── python2.7
    │   │   ├── dist-packages
    │   │   └── site-packages
    │   └── python3.6
    │       └── dist-packages
    ├── man -> share/man
    ├── sbin
    ├── share
    │   ├── ca-certificates
    │   └── man
    └── src

    16 directories, 0 files
    ```

1. Close the ssh session

    ```bash
    exit
    ```

## Finishing up

Don't delete the VMs. We will make use of them over the next few labs! Click on the Ansible Basics link below to move onto the next lab.

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: Ansible ►](../lab2){: .btn .btn--primary}
