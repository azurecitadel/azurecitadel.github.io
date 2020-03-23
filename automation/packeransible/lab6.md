---
title: "Publishing to a Shared Image Gallery"
date: 2019-10-07
author: Richard Cheney
category:
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
excerpt: Use Packer and Ansible roles to publish images to a Shared Image Gallery
---

## Introduction

We have had a few labs in a row that have focused on Ansible. We have generated dynamic inventories based on tags and other instance metadata information, used Ansible Galaxy roles and published custom roles. You're in a better place to start declaratively managing your dynamic inventories at scale.

These labs started with Packer, and we're going to loop back round to that now.  One of the benefits of custom images is that you can baseline on a standard set of tooling and you can bake your bespoke applications directly into the images.  This makes a lot of sense in many scenarios, such as

* defining centre of excellence standards for improved supportability
* accelerating deployments of pre-configured VMs for virtual machine scale sets
* ISVs defining base images for software deployment scenarios outside of the Azure Marketplace

In this lab we will:

* look at the differences in how Packer uses Ansible in both the local and remote context
* create a production Ansible environment for the packer service principal to use
* deploy a Shared Image Gallery
* add an image definition called ubuntu_standard
* create a new Packer file that uses Ansible
* build the image
* deploy a new VM from the new baseline image in the Shared Image Gallery

## Ansible Local v Ansible Remote in Packer

There are two different provisioners in Packer that run Ansible:

1. [Ansible](https://www.packer.io/docs/provisioners/ansible.html) (Remote)
1. [Ansible Local](https://www.packer.io/docs/provisioners/ansible-local.html)

The first is the most common, and the one we'll use first. To date we have been effectively executing Ansible from our laptops.  In a production system you would usually execute those commands from a configuration management servers.  The normal Ansible provisioner will use the Ansible binaries on the config management server, plus locally installed roles and playbooks.  It then uses the standard SSH connectivity to apply the playbook.

For the Ansible Local provisioner, it actually runs the playbook on the target host. Therefore the target host needs to have the binaries, playbooks and roles.

In this lab we will only use the standard Ansible provisioner to create the baseline image in a Shared Image Gallery. We will then make use of the Ansible Local provisioner in the next lab.

## Create a production Ansible area

OK, so far we have been working in our `~/ansible` folder, which has been our personal test and development area.

We will now create an `/etc/ansible` area as a production area.

This area will be writable for members of a new group called ansible, and readable for everyone else including our hashicorp service principal. This would be close to what you might do if you were manually configuring an Ansible area on a config management host.

> If you want to see more information on any of the following Linux commands then use `man <command>`.

1. Create an ansible group and add yourself to it

    ```bash
    sudo groupadd ansible
    sudo usermod -a -G ansible $(whoami)
    ```

    Note that you will need to log out and back in again to see changes to your `groups` list.  You will need to do this before you can create files in `/etc/ansible`.

1. Create the ansible folder with setgid and group ansible

    ```bash
    mkdir /etc/ansible
    chgrp ansible /etc/ansible
    chmod 2775 /etc/ansible
    ```

    These permissions will show as rwxrwsr-x. Any files created in the folder should have their group ID set to the same as the directory, i.e. they will be group ansible.

1. Add directory ACLs to force default permissions

    ```bash
    sudo setfacl -d -m g::rwX,o::r-X /etc/ansible
    ```

    The upper case X will force new directories to also have the setgid bit set.  Note that ACLs are not available by default on older versions of Ubuntu.

    > If setfacl does not exist or does not work on your distro then continue with the next step.

1. Update permissions for existing files and directories

    You can use these two commands to standardise permissions for existing files and directories.  The commands will also correct file permissions for anything you create if you cannot use setfacl.

    ```bash
    sudo chown -R root:ansible /etc/ansible/*
    sudo chmod -R g+rwX,o+rX,o-w /etc/ansible/*
    ```

## Add standard set of files and folders for Ansible

You should be able to do all of the following commands as yourself rather than using sudo, but only if you have logged back in to refresh your groups.

1. Update /etc/ansible/ansible.cfg

    Edit /etc/ansible/ansible.cfg and replace the contents with:

    ```ini
    [defaults]
    inventory = ~/ansible/inventory.azure_rm.yml
    roles_path = ~/ansible/roles
    deprecation_warnings=False
    nocows = 1
    ```

1. Copy the inventory file

    ```bash
    sudo cp ~/ansible/inventory.azure_rm.yml /etc/ansible/
    ```

1. Test

    ```bash
    ansible --version
    ansible all --list-hosts
    ansible localhost -m debug -a 'var=groups'
    ```

    Running these commands outside of your `~/ansible` folder should show that ansible is now pulling in the /etc/ansible/ansible.cfg file, and that the dynamic inventory is working as expected.

1. Create a simple requirement.yml file

    ```yaml
    ---
    - src: https://github.com/richeney/ansible-role-common
      name: common
    - src: https://github.com/richeney/ansible-role-azure-cli
      name: azure_cli
    ...
    ```

    The common role is a simple one that updates the apt cache, does a full upgrade and installs a set of packages.

1. Install the roles

    ```bash
    ansible-galaxy install -r /etc/ansible/requirements.yml -p /etc/ansible/roles
    ```

    This will also create the /etc/ansible/roles directory if it doesn't already exist.

1. Create a standard playbook

    Create a file called /etc/ansible/standard.yml:

    ```yaml
    - hosts: all
      become: yes
      roles:
        - common
        - azure_cli
    ```

1. Check it works based on our three VMs

    ```bash
    ansible-playbook /etc/ansible/standard.yml
    ```

    The playbook should run successfully against the three test VMs.

## Shared Image Gallery

The Shared Image Gallery is a great service designed for storing images. It has a number of key advantages over the standard images we created in the first lab:

* image replication to multiple Azure regions
* support for duplicates for faster deployment of in-demand images (e.g. faster VMSS scale out)
* uses the standard publisher, offer, sku taxonomy used by platform images and Marketplace images
* support for versioning (including different replication configurations per version)
* standard RBAC controls to allow sharing of images across subscriptions in the same tenancy
* multi-tenant app registration support to enable image sharing in multi-tenant scenarios

## Create a Shared Image Gallery

1. Define variables

    We'll define a few variables to shorten the CLI commands.

    ```bash
    rg=images
    loc=westeurope
    sig=sharedImageGallery
    pub=AzureCitadel
    ```

    You may customise these if required.

    > You could use `az configure --defaults group=$rg location=$loc` to avoid specifying the `--resource-group` and `--location` switches. Running `az configure --defaults group="" location=""` would unset those defaults.

1. Create the resource group.

    You should still have a resource group for images from the first lab. This command will succeed regardless.

    ```bash
    az group create --resource-group $rg --location $loc
    ```

1. Create the shared image gallery

    ```bash
    az sig create --resource-group $rg --gallery-name $sig
    ```

    Note that the shared image gallery name must be unique within the subscription.

1. Store the resourceId for the shared image gallery in a variable

    ```bash
    sigId=$(az sig show --resource-group $rg --gallery-name $sig --query id --output tsv)
    ```

    We will need the resourceId later.

1. Create the image definition

    ```bash
    az sig image-definition create --resource-group $rg --gallery-name $sig --gallery-image-definition ubuntu_standard --publisher $pub --offer Ubuntu --sku 18.04 --os-type linux
    ```

    The image definitions need to exist within the Shared Image Gallery before you can use Packer to publish an image to that image definition as a target. Also note that the image definitions have the same concepts of publisher, offer and sku that you will all be familiar with from deploying VM images from the platform images (as we have been doing with the latest Ubuntu 18.04 image) or from the many 3rd party offerings that are hosted in the Azure Marketplace.

    What you decide to use as your publisher, offer and sku standards is up to you.

    Note that the Packer config later does not specify these when defining the target.  It will only specify the resource group, shared image gallery name, image definition name and the version number.

## Create the Packer file

OK, so our production Ansible environment is now up and running.  We'll create a new Packer file and then mention the differences between it and the original Packer file from lab1.

1. Go to the Packer working area

    ```bash
    cd ~/packer
    ```

1. Create a lab6.json Packer file

    Create a new lab6.json file containing the following:

    {% raw %}

    ```yaml
    {
        "variables": {
            "tenant_id": "{{env `ARM_TENANT_ID`}}",
            "subscription_id": "{{env `ARM_SUBSCRIPTION_ID`}}",
            "client_id": "{{env `ARM_CLIENT_ID`}}",
            "client_secret": "{{env `ARM_CLIENT_SECRET`}}"
        },
        "builders": [
            {
                "type": "azure-arm",
                "client_id": "{{user `client_id`}}",
                "client_secret": "{{user `client_secret`}}",
                "subscription_id": "{{user `subscription_id`}}",
                "tenant_id": "{{user `tenant_id`}}",

                "image_publisher": "Canonical",
                "image_offer": "UbuntuServer",
                "image_sku": "18.04-LTS",

                "managed_image_resource_group_name": "images",
                "managed_image_name": "lab6",
                "location": "westeurope",
                "vm_size": "Standard_B1s",
                "os_type": "Linux",
                "azure_tags": {
                    "owner": "",
                    "department": "",
                    "application": "",
                    "costcode": "",
                    "managed_by": "ansible",
                    "os": "ubuntu",
                    "platform": "linux"
                },

                "shared_image_gallery_destination": {
                    "resource_group": "images",
                    "gallery_name": "sharedImageGallery",
                    "image_name": "ubuntu_standard",
                    "image_version": "1.0.0",
                    "replication_regions": [
                        "westeurope",
                        "uaenorth",
                        "southafricanorth"
                    ]
                }
            }
        ],
        "provisioners": [
            {
                "type": "ansible",
                "user": "packer",
                "playbook_file": "/etc/ansible/standard.yml",
                "ansible_env_vars": [
                    "ANSIBLE_HOST_KEY_CHECKING=False",
                    "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s'",
                    "ANSIBLE_NOCOLOR=True",
                    "ANSIBLE_NOCOWS=1"
                ]
            },
            {
                "type": "shell",
                "inline": [
                    " /sbin/reboot --reboot --no-wall"
                ],
                "pause_after": "10s",
                "timeout": "100s",
                "expect_disconnect": "true",
                "execute_command": "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
            },
            {
                "type": "shell",
                "inline": [
                    "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
                ],
                "pause_before": "10s",
                "execute_command": "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'",
                "inline_shebang": "/bin/sh -x"
            }
        ]
    }
    ```

    {% endraw %}

    Much of the file is similar to before, so let's concentrate on the differences.

    First of all, in the build section we are now specifying a shared_image_gallery_destination block. The resource group and shared image gallery name match the one we created earlier and the image specifics also match the image definition.  If the gallery and image definition are not pre-configured then the packer build will fail.

    The build will actually have an additional step.  It will still take the platform image and create a simple image file (called lab6) and then it will push that up into the image gallery as ubuntu_standard (sku: 18.04, version: 1.0.0). I intentionally chose a different naming convention so that you can explicitly see the difference between the resources once they are created.

    I have moved around the attributes in this section so they more clearly align with order they are used by Packer:

    1. platform image
    1. temporary simple image
    1. target gallery definition

    The provisioner section now includes three steps.  The standard Ansible provisioner is in there.  A few additional environment variables are being set, otherwise it is a very simple block.  Then there are two shell sections, one to do a quick rebott (with pauses and and expected disconnection) and then the standard deprovisioning.

## Build the Packer image

1. Run the packer build

    ```bash
    packer build lab6.json
    ```

Here are the resulting resources in the resource group:

![lab6](/automation/packeransible/images/lab6.png)

> Note that if you rerun the build then it will error if either the intermediate image or the image version exists.  Run `packer build -force lab6.json` to override that safety feature.  Also note that the builder will error if the intermediate image ID changes, to avoid erroneous overwrites.

## Working with Shared Image Gallery

1. List out all of the images in an image gallery

    ```bash
    az sig image-definition list --resource-group images --gallery-name sharedImageGallery --output table
    ```

    Expected output:

    ```text
    Location    Name             OsState      OsType    ProvisioningState    ResourceGroup
    ----------  ---------------  -----------  --------  -------------------  ---------------
    westeurope  ubuntu_standard  Generalized  Linux     Succeeded            images
    ```

1. List the versions for an image

    ```bash
    az sig image-version list --resource-group images --gallery-name sharedImageGallery --gallery-image-definition ubuntu_standard --output jsonc
    ```

    Expected output:

    ```json
    [
      {
        "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/images/providers/Microsoft.Compute/galleries/sharedImageGallery/images/    ubuntu_standard/versions/1.0.0",
        "location": "westeurope",
        "name": "1.0.0",
        "provisioningState": "Succeeded",
        "publishingProfile": {
          "endOfLifeDate": null,
          "excludeFromLatest": false,
          "publishedDate": "2019-10-04T14:00:58.857021+00:00",
          "replicaCount": 1,
          "source": {
            "managedImage": {
              "id": "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/images/providers/Microsoft.Compute/images/lab6",
              "resourceGroup": "images"
            }
          },
          "storageAccountType": "Standard_LRS",
          "targetRegions": [
            {
              "name": "West Europe",
              "regionalReplicaCount": 1,
              "storageAccountType": "Standard_LRS"
            },
            {
              "name": "UAE North",
              "regionalReplicaCount": 1,
              "storageAccountType": "Standard_LRS"
            },
            {
              "name": "South Africa North",
              "regionalReplicaCount": 1,
              "storageAccountType": "Standard_LRS"
            }
          ]
        },
        "replicationStatus": null,
        "resourceGroup": "images",
        "storageProfile": {
          "dataDiskImages": null,
          "osDiskImage": {
            "hostCaching": "ReadWrite",
            "sizeInGb": 30
          }
        },
        "tags": {
          "application": "",
          "costcode": "",
          "department": "",
          "managed_by": "ansible",
          "os": "ubuntu",
          "owner": "",
          "platform": "linux"
        },
        "type": "Microsoft.Compute/galleries/images/versions"
      }
    ]
    ```

The image version allows you to update the image to a new version.  There is no need to recreate the image definition for this; instead you update the packer file and increment the `1.0.0` before building.

Also note that each version has properties for the replicas in terms of how many in which regions.  You can make sure that the most recent has sufficient replicas to meet the need, whilst saving storage space and therefore money for superseded versions.

## Deploying a VM from a Shared Image Gallery image

You need read access to the image gallery. You can share at either the gallery or at the image level.  There is no problem with having multiple galleries, so the recommendation is to standardise on gallery level access control to keep it simple.

You and your service principals should already have read access to the gallery, inherited from the role assignment at the subscription level.

If you did need to add specific access - and you don't - then:

```bash
sigId=$(az sig show --resource-group images --gallery-name sharedImageGallery --query id --output tsv)
az role assignment create --role "Reader" --assignee <assignee> --scope <gallery ID>
```

> Reference only.

1. Get the image ID

    ```bash
    imageId=$(az sig image-definition show --resource-group images --gallery-name sharedImageGallery --gallery-image-definition ubuntu_standard --query id --output tsv)
    ```

1. Deploy vm4

    ```bash
    az vm create --resource-group ansible_vms --name vm4 \
          --image $imageId \
          --ssh-key-values "@~/.ssh/id_rsa.pub" \
          --vnet-name vnet \
          --subnet subnet \
          --tags owner=citadel \
          --output jsonc
    ```

    The command will not return to the prompt until it has deployed as there is no `--no-wait` switch.

1. Check the dynamic inventory

    ```bash
    ansible all -m debug -a "msg='{{ ansible_host }}'"
    ```

    Example output:

    ```text
    vm1_cf1d | SUCCESS => {
        "msg": "13.95.141.87"
    }
    vm2_1e76 | SUCCESS => {
        "msg": "13.95.143.192"
    }
    vm3_aa09 | SUCCESS => {
        "msg": "52.148.241.98"
    }
    vm4_fe68 | SUCCESS => {
        "msg": "51.144.240.175"
    }
    ```

    The new vm4 should have been added to the inventory dynamically.

1. Check the VM

    SSH on to vm4.

    Remember that we did a full upgrade of all packages in the standard Ansible playbook. Verify that there are no messages saying that the VM requires a reboot, as that was done in the Packer file prior to the deprovisioning.

    Test that the packages are installed:

    ```bash
    az | lolcat
    exit
    ```

## References

* <https://www.packer.io/docs/provisioners/ansible.html>
* <https://www.packer.io/docs/provisioners/ansible-local.html>
* <https://azure.microsoft.com/blog/announcing-the-public-preview-of-shared-image-gallery/>
* <https://docs.microsoft.com/azure/virtual-machines/linux/shared-image-galleries>
* <https://docs.microsoft.com/azure/virtual-machines/linux/share-images-across-tenants>

## Finishing Up

There are many benefits in combining Ansible playbooks and roles with Packer and the Shared Image Gallery. If you need to share the images across tenants then refer to the links above.

You have reached the end of the labs. Don't forget to clean up any resources in your subscription that you no longer need.

We have scratched the surface on what is possible with Azure images, Packer and Ansible, but at least now you know what tooling is available and how to drive it.  Getting good quality build pipelines for container images and putting those artifacts into a registry is a given. With Packer and Ansibled there is no reason not to do exactly the same for your VM deployments. As always, if you can decide if the time savings from automation justify the time to configure.

As a plus, Ansible is massively powerful as a VM management tool. Look out for labs on Azure Arc for Servers as we look to extend that power beyone Azure and into other clouds and on prem locations.

[◄ Lab 5: Custom Roles](../lab4){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse}
