---
title: "Going deeper with Packer"
date: 2019-03-18
author: Richard Cheney
category: automation
comments: true
featured: false
hidden: false
published: true
tags: [ image, packer, linux ]
header:
  overlay_image: images/header/whiteboard.png
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "linux"
excerpt: Adding additional provisioning steps to Packer
---

## Introduction

The first lab created a basic image, but there was no real value compared to the platform image.  In this lab we will add in some real customisation as we start to build up a more useful jumpbox / configuration management VM.  In this lab we'll add to our Packer file so that it will install Ansible into the image, configure Managed Service Identity, upload a script, update the crontab and remotely run an Ansible playbook to add some roles in.

We will be mainly working with the provisioners block in the Packer file. The block currently looks like this:

```json
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
```

## Multiple steps

The provisioners block is a JSON array (`[]`) and it currently has just the one shell step within it.  Duplicated that block, and then reduce down the inline array in each version:

1. Just the apt-get commands
1. Only the generalisation (waagent) command

Don't forget the comma between the two JSON objects in the array.  Once done thew section should look like this:

```json
  "provisioners": [
    {
      "execute_command": "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'",
      "inline": [
        "apt-get update",
        "apt-get upgrade -y",
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

OK, se have split the original block into two.  We'll start with a few prep commands, and then bookend it with the generalisation.

## Install Ansible

If you are doing simple package installations then you can add commands to that first inline array.

The following will add another apt repository to the list, install a few pre-reqs and then uses the Python pip installer to install the Azure variant of Ansible.

```yaml
   "inline": [
      "apt-add-repository -y ppa:ansible/ansible",
      "apt-get update",
      "apt-get upgrade -y",
      "apt-get install -y libssl-dev libffi-dev python-dev python-pip",
      "pip install ansible[azure]"
   ]
```

## File uploads

File uploads are very simple.  Let's create a simple YOU ARE HERE

## Deleteme

<pre class="language-bash command-line" data-output="2-5,7-99" data-prompt="$"><code>
az resource list --resource-group packer_images --output table
Name                ResourceGroup    Location    Type                      Status
------------------  ---------------  ----------  ------------------------  --------
configManagementVm  packer_images    westeurope  Microsoft.Compute/images

az image list --resource-group packer_images --output table
Location    Name                ProvisioningState    ResourceGroup
----------  ------------------  -------------------  ---------------
westeurope  configManagementVm  Succeeded            packer_images
</code></pre>

[▲ Index](../#labs){: .btn .btn--inverse} [Lab 2: Audit ►](../lab2){: .btn .btn--primary}