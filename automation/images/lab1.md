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

## Install Packer

Follow Hashicorp's instructions for installing the binary if you haven't done so as part of the [prereqs](../prereqs):

  <https://www.packer.io/intro/getting-started/install.html#precompiled-binaries>

(As with all Hashicorp binaries this is an intentionally manual process. Allowing the admin full visibility and control over the versioning throughout the whole configuration management stack is part of the company ethos.)

Run `which packer` and `packer --version` to confirm all is good.

<pre class="language-bash command-line" data-output="2,5" data-prompt="$"><code>
which packer
/usr/local/bin/packer

packer --version
1.4.1
</code></pre>

Personally I use a script to accelerate the installation.  Feel free to download a copy using:

```bash
curl -sSL https://raw.githubusercontent.com/richeney/azure-blueprints/master/scripts/installLatestHashicorpBinary.sh --output installLatestPacker.sh && chmod 755 installLatestPacker.sh
```

## Create the resource group for the image

1. The process needs a pre-existing resource group. We'll name it *packer_image*.

<pre class="language-bash command-line" data-output="2-99" data-prompt="$"><code>
az group create --name packer_images --location westeurope --output yaml
id: /subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62/resourceGroups/packer_images
location: westeurope
managedBy: null
name: packer_images
properties:
  provisioningState: Succeeded
tags: null
type: null
</code></pre>

## Create a folder for your Packer files

2. Create a folder for your lab files.  The commands below will create a subdirectory in your home directory:

```bash
cd ~
mkdir -m 755 packer
cd packer
```

## Create the service principal

You will need a service principal to create the images using Packer.  If you have one already for Terraform then you can reuse it. Capture the output from the following command as the value will transpose directly into the top of the packer template.

The packer image generation process will create a temporary folder so the service principal needs sufficient permissions to do so.

3. Create a service principal for packer to use

<pre class="language-bash command-line" data-output="4-99" data-prompt="$"><code>
subId=$(az account show --output tsv --query id)
name="http://images-${subId}-sp"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subId" --name "$name" --output json
{
  "appId": "6c0c9e20-9541-4591-bd9e-893e21099c72",
  "displayName": "images-2d31be49-d999-4415-bb65-8aec2c90ba62-sp",
  "name": "http://images-2d31be49-d999-4415-bb65-8aec2c90ba62-sp",
  "password": "0858048e-c8c2-4d70-ad28-5fe0dd073201",
  "tenant": "f246eeb7-b820-1971-a083-9e100e084ed0"
}
</code></pre>

You will need the output of that last command in the next step.

## Export environment variables

You can hardcode the tenancy, subscription and service principal details in the JSON files, but we will make use of environment variables instead and put those into a more protected file. This will also make your Packer template reusable in other subscription contexts.

4. Create a secure and empty .image_env file in your home directory

```bash
touch ~/.images_env && chmod 600 ~/.images_env
```

5. Create the export commands within .images_env

Below are example commands based on the returned values from the command output above.

> You will need to change it to the values shown in your output.

```bash
export ARM_TENANT_ID=f246eeb7-b820-1971-a083-9e100e084ed0
export ARM_SUBSCRIPTION_ID=2d31be49-d999-4415-bb65-8aec2c90ba62
export ARM_CLIENT_ID=6c0c9e20-9541-4591-bd9e-893e21099c72
export ARM_CLIENT_SECRET=0858048e-c8c2-4d70-ad28-5fe0dd073201
```

6. Run `source ~/.image_env` to set the environment variables, and view them using `env | grep ARM`.

> Your .bashrc file could also export these directly, or source the .images_env file

## Create the Packer template

7. Create a file called lab1.json with the following template

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
        "apt-get install git jq tree wget lolcat aptitude -y"
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

> This is very similar to the template in the [Packer documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer#define-packer-template).
>
> If you want a different location, size, or platform image then you may find the following example commands useful:
>
> ```bash
> az account list-locations --output table
> az vm list-sizes --location westeurope --output table
> az vm image list-publishers --location westeurope --output table
> az vm image list-offers --publisher SUSE --location westeurope --output table
> az vm image list-skus --publisher SUSE --offer SLES --location westeurope --output table
> ```

## Run the build

8. Run packer locally to build the image:

```bash
source .env
packer build lab1.json
```

The command will show progress with output to screen.  Once complete, it will be an image resource type, ready to use for a deployment. Standard VM images use the `Microsoft.Compute/images` provider type.

<pre class="language-bash command-line" data-output="2-" data-prompt="$"><code>
az image list --resource-group packer_images --output table
Location    Name    ProvisioningState    ResourceGroup
----------  ------  -------------------  ---------------
westeurope  lab1    Succeeded            packer_images
</code></pre>

## Deploy virtual machines from standard images

In this section we will deploy a couple of VMs from our image, using your ssh keys.

### SSH Keys

If you have never generated ssh keys then run `ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""` and it will create an ssh key pair in the default location and with the default names.

You can list the files (and see their permissions) using `ls -l ~/.ssh`.

The -N switch defines a new passphrase which is empty. This isn't very security aware, so if you are creating ssh keys for production then look at `man ssh-keygen`.

### Create a Virtual Network

A lot of the example deploy VMs from the images that create public IP addresses, and create a virtual networks and subnets.  This is great for quickly spinning something up, but most of the time you will deploy VMs and attach them to existing subnets.

For the sake of the lab we will create a resource group, vNet and subnet and then attach the deployed VMs to the subnet.

9. Create a resource group and virtual network

```bash
az group create --name ansible_vms --location westeurope
az network vnet create --resource-group ansible_vms --name vnet --address-prefix 10.0.0.0/16 --subnet-name subnet --subnet-prefix 10.0.0.0/24
```

### Deploy the VM

10. Set a variable for the full resource ID of your image.

```bash
imageId=$(az image show --resource-group packer_images --name lab1 --output tsv --query id)
```

> Note: if you are deploying VMs into the same resource group as the image then `az vm create` command can use the far shorter image name (e.g. lab1) rather than the full ID

11. Use the following commands to create a VM from your lab1 image

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

12. Repeat the command to create a vm2 VM

We will use the two VMs in the next lab. Note the tags we added; we'll be using those for dynamic inventories in a later lab.

> We would normally use `--public-ip-address ""` on the CLI to avoid creating a public IP address, and would connect across S2S VPN or Express Route to the private IP addresses. For this lab we'll keep it simple and use the public IP addresses.

The `--ssh-key-values` switch will take a space delimited list of public key files, so you can add a few user IDs in one go.

Also check out `ssh-agent` and `ssh-add`. Working ssh access to deployed VMs is critical to making use of Ansible.

For those of you using Azure Key Vault, look at the help using `az vm create --help`. There is also a PowerShell based tutorial, which at least shows the process.

## Connect to the VM

13. Confirm the deployment jobs for the two VMs have succeeded:

```bash
az group deployment list --resource-group ansible_vms --output table
```

14. You can list out the IP addresses for the VMs in a resource group:

```bash
az vm list-ip-addresses --resource-group ansible_vms --output table
```

15. SSH into one of the two VMs

Connect using `ssh <userid>@<publicIpAddress>`.

Example SSH command below. Your public IP address will be different.

```bash
ssh richeney@65.52.158.233
The authenticity of host '65.52.158.233 (65.52.158.233)' can't be established.
ECDSA key fingerprint is SHA256:ODtHkhERTQx+bUc3ZEL1LBW41VxtGf9JboqYtXe6Dc4.
Are you sure you want to continue connecting (yes/no)? yes
```

> Answering yes will add the server to the `~/.ssh/authorized_keys` file. Future ssh session will go straight in.

16. Run the following command to test that the additional packages were installed correctly into the image.

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

17. Type `exit` to close the ssh session.

Don't delete the VMs just yet as we will make use of them over the next few labs!

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: Ansible Basics ►](../lab2){: .btn .btn--primary}
