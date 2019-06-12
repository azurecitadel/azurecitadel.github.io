---
title: "Going deeper with Packer"
date: 2019-06-17
author: Richard Cheney
category:
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
excerpt: Adding additional provisioning steps to Packer
---

## Introduction

The first lab created a basic image, but there was no real value compared to the platform image.  In this lab we will add in some real customisation as we start to build up a more useful jumpbox / configuration management VM.  In this lab we'll add to our Packer file so that it will install Ansible into the image, configure Managed Service Identity, upload a script, update the crontab and remotely run an Ansible playbook to add some roles in.

We will be mainly working with the provisioners block in the Packer file. The block currently looks like this:

{% raw %}

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

{% endraw %}

## Multiple steps

The provisioners block is a JSON array (`[]`) and it currently has just the one shell step within it.  Duplicated that block, and then reduce down the inline array in each version:

1. Just the apt-get commands
1. Only the generalisation (waagent) command

Don't forget the comma between the two JSON objects in the array.  Your section should look like this:

{% raw %}

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
```

{% endraw %}

OK, se have split the original block into two.  We'll start with a few prep commands, and then bookend it with the generalisation.

## Ansible

Ansible could be a (large) set of labs by itself. It is popular for configuration management as it is open source and it is agentless. We could use Ansible to provision the Azure infrastructure, but we will leave that job to Terraform.  We will use Ansible purely for configuring the servers themselves once they have been stood up.

You should be aware that there are many other options in the configuration management space, such as Chef, Puppet, Salt, Octopus, etc.

If you want to learn more about Ansible then I would recommend starting with the Azure Ansible document area at <https://aka.ms/ansible>, and then progressing from there to the wider Ansible documentation and playbook examples.

## Install Ansible using the shell

If you are doing simple package installations then you can add commands to that first inline array.

The following will add another apt repository to the list, install a few pre-reqs and then uses the Python pip installer to install the Azure variant of Ansible.

```yaml
   "inline": [
      "apt-add-repository -y ppa:ansible/ansible",
      "apt-get update",
      "apt-get install -y libssl-dev libffi-dev python-dev python-pip",
      "apt-get upgrade -y",
      "pip install ansible[azure]"
   ]
```

The Hashicorp documentation has more information on the [Packer shell provisioner](https://www.packer.io/docs/provisioners/shell.html).

## File uploads

File uploads are very simple, copying files from the local machine to the remote.

Create a file in your current working directory called *credentials*, in the following format:

```ini
[default]
tenant=<tenantId>
subscription_id=<subId>
client_id=<clientId>
secret=<clientSecret>
```

Make sure that your local copy is protected using `chmod 600 credentials`.  This .ini file is one way of handling [Azure credentials for Ansible](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html#authenticating-with-azure).

Now add a new step in your provisioners, in the middle:

```json
    {
      "type": "file",
      "source": "./credentials",
      "destination": "/tmp/credentials"
    },
```

This will copy the credentials file you've just created and put it into the /tmp folder.  The file provisioner does not allow you to write using sudo, or change permissions, so it is common to follow it with a script step to move it correctly to the right place.

Add the following step to move the credentials file to the correct location:

{% raw %}

```json
    {
      "type": "shell",
      "inline": [
        "test -d ~/.azure || mkdir -m 700 ~/.azure",
        "chmod 600 /tmp/credentials && mv /tmp/credentials ~/.azure/credentials"
      ],
      "inline_shebang": "/bin/sh -x",
      "execute_command": "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    },
```

{% endraw %}

> Note that the execute commands run using sudo for elevated privileges, and use the lightweight sh (Dash) shell as opposed to bash. Ansible only runs the next entry in the inline array if the previous one had a zero return code.

## Create an Ansible role for Azure CLI installation

Create an area to put your Ansible config files.  For example, I did the following on my Ubuntu WSL distribution:

```bash
umask 022
mkdir /mnt/c/ansible
sudo ln -s /mnt/c/ansible /ansible
cd /ansible
```

We could have large Ansible YAML files containing all of the required functionality.  Instead we'll get into good habits and create some roles, which are Ansible's reusable playbook modules.  The ansible-galaxy command can pre-create the are for us:

<pre class="language-bash command-line" data-output="3-4,6-99" data-prompt="$"><code>
cd /ansible
ansible-galaxy init az
- az was created successfully

tree /ansible
/ansible
└── az
    ├── README.md
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml
</code></pre>

[◄ Lab 1: Packer](../lab1){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 3: Shared Image Gallery ►](../lab3){: .btn .btn--primary}
