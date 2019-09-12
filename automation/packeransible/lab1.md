---
title: "Image creation with Packer"
date: 2019-08-19
author: Richard Cheney
category: automation
comments: true
featured: false
hidden: true
published: true
tags: [ image, packer, linux ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "images"
excerpt: Generate a simple Ubuntu image and then deploy VMs from it
---

## Introduction

In this lab you will create a custom image using Packer, and then use it to deploy two VMs. These will be used in the next lab.

If you already have Packer installed then skip to the [working environment](#create-a-working-environment-for-packer) step.

If you do no have Packer installed then you can either [install Packer manually](#install-packer-manually) or using a [script](#scripted-packer-installation).

## Install Packer manually

If installing Packer manually

1. Follow Hashicorp's instructions for installing the binary if you haven't done so as part of the [prereqs](../prereqs):

    <https://www.packer.io/intro/getting-started/install.html#precompiled-binaries>

    (As with all Hashicorp binaries this is an intentionally manual process. Allowing the admin full visibility and control over the versioning     throughout the whole configuration management stack is part of the company ethos.)

1. Check the location and version

    ```bash
    which packer
    packer --version
    ```

## Scripted Packer installation

Alternatively you may use my script to accelerate the installation.

1. Download the script

    ```bash
    curl -sSL https://raw.githubusercontent.com/richeney/azure-blueprints/master/scripts/installLatestHashicorpBinary.sh --output     installLatestPacker.sh && chmod 755 installLatestPacker.sh
    ```

1. Run the script

    ```bash
    ./installLatestPacker.sh
    ```

## Create a working environment for Packer

In this section you'll create:

* a resource group where Packer will store the generated images
* a secure folder for your Packer config files
* a service principal for Packer to access your Azure subscription
* an env file in your home directory with the required environment variables

> You can hardcode the tenancy, subscription and service principal details in the JSON files, but we will make use of environment variables instead and put those into a more protected file. This will also make your Packer template reusable in other subscription contexts.

1. Create a resource group

    ```bash
    az group create --name packer_images --location westeurope --output yaml
    ```

    Example output:

    ```yaml
    id: /subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62/resourceGroups/packer_images
    location: westeurope
    managedBy: null
    name: packer_images
    properties:
      provisioningState: Succeeded
    tags: null
    type: null
    ```

1. Create a folder for your lab files.  The commands below will create a subdirectory in your home directory:

    ```bash
    mkdir -m 755 ~packer && cd packer
    ```

1. Create a service principal for packer to use

    You will need a service principal to create the images using Packer.  If you have one already for Terraform then you can reuse it. Capture     the output from the following command as the value will transpose directly into the top of the packer template.

    The packer image generation process will create a temporary folder so the service principal needs sufficient permissions to do so.

    ```bash
    subId=$(az account show --output tsv --query id)
    name="http://images-${subId}-sp"
    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subId" --name "$name" --output json
    ```

    Example output:

    ```json
    {
      "appId": "6c0c9e20-9541-4591-bd9e-893e21099c72",
      "displayName": "images-2d31be49-d999-4415-bb65-8aec2c90ba62-sp",
      "name": "http://images-2d31be49-d999-4415-bb65-8aec2c90ba62-sp",
      "password": "0858048e-c8c2-4d70-ad28-5fe0dd073201",
      "tenant": "f246eeb7-b820-1971-a083-9e100e084ed0"
    }
    ```

    Take a copy of the screen output for that last command. You will need some of the values in the next step.

1. Create an .image_env file in your home directory

    ```bash
    touch ~/.images_env && chmod 600 ~/.images_env
    ```

    The file has secure permissions to protect the service principal credentials.

1. Edit the .images_env file in your preferred editor

    E.g. vscode, vi, or nano.

1. Add the export commands for the environment variables

    Packer can use environment variables for authentication: ARM_TENANT_ID, ARM_SUBSRIPTION_ID, ARM_CLIENT_ID and ARM_CLIENT_SECRET.

    Below are example commands based on the returned values from the command output above.

    ```bash
    export ARM_TENANT_ID=f246eeb7-b820-1971-a083-9e100e084ed0
    export ARM_SUBSCRIPTION_ID=2d31be49-d999-4415-bb65-8aec2c90ba62
    export ARM_CLIENT_ID=6c0c9e20-9541-4591-bd9e-893e21099c72
    export ARM_CLIENT_SECRET=0858048e-c8c2-4d70-ad28-5fe0dd073201
    ```

    **Ensure your values are modified to match those shown in the output of your `az ad sp create-for-rbac` command.**

1. Source the environment file

    ```bash
    source ~/.image_env
    ```

1. Check the environment variables are set

    ```bash
    env | grep ARM
    ```

    Example output:

    ```text
    ARM_SUBSCRIPTION_ID=2d31be49-d959-4415-bb65-8aec2c90ba62
    ARM_TENANT_ID=f246eeb7-b820-4971-a083-9e100e084ed0
    ARM_CLIENT_SECRET=0858048e-c8c2-4d70-ad28-5fe0dd073201
    ARM_CLIENT_ID=6c0c9e20-9541-4591-bd9e-893e21099c72
    ```

    > Your .bashrc file could also explicitly export the or it could include the source command above.

## Create the Packer template

1. Create a file called lab1.json with the following template

    {% raw %}

    ```json
    {
      "variables": {
        "subscription_id": "{{env `ARM_SUBSCRIPTION_ID`}}",
        "client_id": "{{env `ARM_CLIENT_ID`}}",
        "client_secret": "{{env `ARM_CLIENT_SECRET`}}"
      },
      "builders": [{
        "type": "azure-arm",

        "client_id": "{{user `client_id`}}",
        "client_secret": "{{user `client_secret`}}",
        "subscription_id": "{{user `subscription_id`}}",

        "managed_image_resource_group_name": "packer_images",
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
    az image list --resource-group packer_images --output table
    ```

    Example output:

    ```text
    Location    Name    ProvisioningState    ResourceGroup
    ----------  ------  -------------------  ---------------
    westeurope  lab1    Succeeded            packer_images
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
    imageId=$(az image show --resource-group packer_images --name lab1 --output tsv --query id)
    ```

    > Note: if you are deploying VMs into the same resource group as the image then `az vm create` command can use the far shorter image name (e.g. lab1) rather than the full ID

1. Create a VM from the lab1 image

    ```bash
    az vm create --name vm1 \
      --resource-group ansible_vms \
      --image $imageId \
      --ssh-key-values "@~/.ssh/id_rsa.pub" \
      --vnet-name vnet \
      --subnet subnet \
      --tags owner=citadel managed_by=ansible \
      --output jsonc \
      --no-wait
    ```

1. Create a second VM from the image

    Modify the last command to create a VM named vm2.

    We will use the two VMs in the next lab. Note the tags we added; we'll be using those for dynamic inventories in a later lab.

Additional notes:

* The `--ssh-key-values` switch will take a space delimited list of public key files, so you can add a few user IDs in one go.
* Also check out the manual pages for `ssh-agent` and `ssh-add`
* For those of you using Azure Key Vault, look at the help using `az vm create --help`. There is also a PowerShell based tutorial, which at least shows the process.

## Connect to the VM

Working ssh access to deployed VMs is critical to making use of Ansible. In this section you will check that the VM deployments have completed, connecting using SSH and then check that the packages were installed successfully.

1. Check the status of the VM deployments

    ```bash
    az group deployment list --resource-group ansible_vms --output table
    ```

    > The two VMs were deployed with `--no-wait`.

1. Repeat the last command until both have succeeded

1. List out the IP addresses

    ```bash
    az vm list-ip-addresses --resource-group ansible_vms --output table
    ```

1. SSH into the first of the two VMs

    Connect using `ssh <userid>@<publicIpAddress>`.

    Example SSH command below. Your public IP address will be different.

    ```bash
    ssh richeney@65.52.158.233
    The authenticity of host '65.52.158.233 (65.52.158.233)' can't be established.
    ECDSA key fingerprint is SHA256:ODtHkhERTQx+bUc3ZEL1LBW41VxtGf9JboqYtXe6Dc4.
    Are you sure you want to continue connecting (yes/no)? yes
    ```

    > Answering yes will add the server to the `~/.ssh/authorized_keys` file. Future ssh session will go straight in.

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

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: Ansible Basics ►](../lab2){: .btn .btn--primary}
