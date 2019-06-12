---
title: "Image creation using Packer"
date: 2019-06-17
author: Richard Cheney
category:
comments: true
featured: false
hidden: true
published: false
tags: [ image, packer, linux ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "images"
excerpt: Use Packer to script the generation of a simple Ubuntu image
---

## Introduction

This is an introductory lab, and is frankly very similar to the one on Azure docs, but it will serve as a good starting point for the group of labs.

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

The process needs a pre-existing resource group. We'll name it *packer_image*.

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
}
</code></pre>

## Create the service principal

You will need a service principal to create the images using Packer.  If you have one already for Terraform then you can reuse it. Capture the output from the following command as the value will transpose directly into the top of the packer template.

The packer image generation process will create a temporary folder so the service principal needs sufficient permissions to do so.

<pre class="language-bash command-line" data-output="4-99" data-prompt="$"><code>
subId=$(az account show --output tsv --query id)
name="http://packer-${subId}-sp"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subId" --name "$name" --output json
{
  "appId": "6c0c9e20-9541-4591-bd9e-893e21099c72",
  "displayName": "packer-2d31be49-d999-4415-bb65-8aec2c90ba62-sp",
  "name": "http://packer-2d31be49-d999-4415-bb65-8aec2c90ba62-sp",
  "password": "0858048e-c8c2-4d70-ad28-5fe0dd073201",
  "tenant": "f246eeb7-b820-1971-a083-9e100e084ed0"
}
</code></pre>

**Capture the output of this command for the next step!**

## Create a Packer area

Create a folder for your lab files.  The commands below will create subdirectory in your home directory:

```bash
cd ~
mkdir -m 755 packer
cd packer
```

## Create the packer template

Create a file called lab1.json with the following template.

{% raw %}

```json
{
  "builders": [{
    "type": "azure-arm",

    "client_id": "<appId>",
    "client_secret": "<password>",
    "tenant_id": "<tenant>",
    "subscription_id": "<subscription_id>",

    "managed_image_resource_group_name": "packer_images",
    "managed_image_name": "lab1",

    "os_type": "Linux",
    "image_publisher": "Canonical",
    "image_offer": "UbuntuServer",
    "image_sku": "16.04-LTS",

    "azure_tags": {
        "dept": "Testing",
        "task": "Image Deployment"
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

        "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
      ],
      "inline_shebang": "/bin/sh -x",
      "type": "shell"
    }
  ]
}
```

{% endraw %}

Configure the correct values for the service principal.

Look at the inline array near the bottom of the file.  The first two commands in that array will update the operating system, and then the last command will generalise the virtual machine into an image.

> This is the essentially the same template in the [Packer documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer#define-packer-template) on Azure docs.)
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

Run packer locally to build the image:

```bash
packer build lab1.json
```

> If you get an error saying `Build 'azure-arm' errored: adal: Refresh request failed. Status Code = '400'. Response body: Bad Request` it is because you forgot to update the fields for the service principal's credentials.

The command will show progress with output to screen.  Once complete, it will be an image resource type, ready to use for a deployment. Standard VM images use the `Microsoft.Compute/images` provider type.

<pre class="language-bash command-line" data-output="2-" data-prompt="$"><code>
az image list --resource-group packer_images --output table
Location    Name    ProvisioningState    ResourceGroup
----------  ------  -------------------  ---------------
westeurope  lab1    Succeeded            packer_images
</code></pre>

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: Ansible ►](../lab2){: .btn .btn--primary}
