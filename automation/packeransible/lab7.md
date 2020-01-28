---
title: "Deploying a Config Management VM"
date: 2019-10-07
author: Richard Cheney
category:
comments: true
featured: false
hidden: true
published: false
tags: [ image, packer, linux ]
header:
  overlay_image: images/header/gherkin.jpg
  teaser: images/teaser/packeransible.png
sidebar:
  nav: "packeransible"
excerpt: Example image creation and deployment, showcasing Ansible and Ansible Local, cloud init and custom script extensions, plus managed identity
---

## Introduction

<<< WORK IN PROGRESS!! >>>

At the end of the last lab we had published an image called ubuntu_standard to the Shared Image Gallery. We will use that baseline Ubuntu image as the starting point for a new image definition.

Ansible will be installed into new image definition, with a new role that allows us to specify lists of files, playbooks and roles. When we run a  playbook calling the role then it will set up a production /etc/ansible area in the VM image, closely following the set of steps you did manually on your own laptop.

The lab will then use Terraform to deploy a VM from the new image. The VM will have Managed Identity assigned as Contributor to the Azure subscription, and a configurable list of users added to the ansible group.

The pretext for this example is a central managed services team deploying config management VMs to multiple subscriptions. This is common in large organisations and with managed services partners (MSPs) who are managing multiple tenants.

Most of the technologies used in this lab are covered in the preceding labs, or in other material available on Citadel. We'll link to those where appropriate.

This lab is a good example to highlight the difference in the Ansible provisioner in Packer compared to the Ansible Local provisioner. Ansible will be installed using the standard Ansible provisioner. The Ansible Local provisioner will then be invoked, using playbooks and roles that only exist on the temporary VM and not on your local machine.

We'll dig into custom RBAC roles so that the hashicorp service principal has the ability to assign a role for the VM's managed identity .  Finally, the simple Terraform config will show how to use cloud-init, simple custom script extensions and how to do a role assignment so that VM's managed identity has the required access.

## Set Up

OK, let's get going and create the required lab files.

1. Create the Packer file

    We'll start with the Packer file. Create a file called `~/packer/lab7.json` containing the following:

    {% raw %}

    ```json
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
                "managed_image_resource_group_name": "packer_images",
                "managed_image_name": "lab7",
                "shared_image_gallery": {
                    "subscription": "{{user `subscription_id`}}",
                    "resource_group": "images",
                    "gallery_name": "sharedImageGallery",
                    "image_name": "ubuntu_standard",
                    "image_version": "1.0.0"
                },
                "shared_image_gallery_destination": {
                    "resource_group": "images",
                    "gallery_name": "sharedImageGallery",
                    "image_name": "ubuntu_ansible",
                    "image_version": "1.0.0",
                    "replication_regions": [
                        "westeurope",
                        "uaenorth",
                        "southafricanorth"
                    ]
                },
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
                "location": "westeurope",
                "vm_size": "Standard_B1s"
            }
        ],
        "provisioners": [
            {
                "type": "ansible",
                "user": "packer",
                "playbook_file": "/etc/ansible/install_ansible.yml",
                "ansible_env_vars": [
                    "ANSIBLE_HOST_KEY_CHECKING=False",
                    "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s'",
                    "ANSIBLE_NOCOLOR=True",
                    "ANSIBLE_NOCOWS=1"
                ]
            },
            {
                "type": "ansible-local",
                "playbook_files": "/etc/ansible/config_mgmt.yml",
                "galaxy_file": "/etc/ansible/config_mgmt.requirements.yml"
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

    OK, the builders section looks familiar, except that we have a `shared_image_gallery` JSON object for the source rather than `image_publisher`, `image_offer` and `image_sku` for the platform images.  So our baseline image will include all of the common packages, the Azure CLI and will have had a full upgrade and reboot prior to being deprovisioned and generalised.

    The first step in the provisioners array is a standard playbook call using the standard Ansible provisioner.  We don't have an `/etc/ansible/install_ansible.yml` so we'll create that next.

    The second step is an Ansible Local call. This is not used as often as the main Ansible provisioner. It requires Ansible on the target host so that it can then run locally as opposed to running ansible on your laptop and using SSH to run against the target. (It is a slightly confusing and ambiguous naming convention...)

    Take a look at the [Ansible Local provisioner](https://www.packer.io/docs/provisioners/ansible-local.html) documentation page to see the option. You'll notice that it uses a temporary staging_folder, defaulting to `/tmp/packer-provisioner-ansible-local/<uuid>`. It will upload files or whole folders and can install roles from Ansible Galaxy. It then runs the playbooks using ansible on the target machine against the files that are now local to that machine.

    The step is included purely to show how it can be called.  We'll need to create the `config_mgmt.yml` and `config_mgmt.requirements.yml` files after we have created the `install_ansible.yml` used in the first step.

1. Create the Ansible Playbook

    Create a file called `/etc/ansible/install_ansible.yml` containing the following:

    ```yaml
    ---
    # Master playbook to test custom role to install Ansible
    - hosts: all
      become: yes
      roles:
          - role: ansible_azure
      vars:
        files:
          - ansible.cfg
          - example_playbook.yml
          - inventory.azure_rm.yml

        required_roles:
          - src: https://github.com/richeney/ansible-role-common
            name: common
          - src: https://github.com/richeney/ansible-role-azure-cli
            name: azure_cli
          - src: geerlingguy.pip
            name: pip
          - src: geerlingguy.docker
            name: docker

        playbook_repo: https://github.com/richeney/ansible-playbooks

        required_playbooks:
          - docker.yml
    ...
    ```

    We will look at the custom role in more depth whilst the Packer image build is running, but you can see that the playbook specifies a number of variables for the role.

    The **files** list is used by the role to copy files from the role's `./files` sub-folder to /etc/ansible. The list of **required_roles** will be used to generate a requirement.yml file from the `./templates` sub-folder. The list of **required_playbooks** will use the get_url module to grab those playbook files from the **playbook_repo**.

    You'll need the custom ansible_azure role in your /etc/ansible/roles before you can build the image so we'll add a new entry to the requirements.yml and install it.

1. Update requirements.yml

    Add a new element to the `/etc/ansible/requirements.yml`:

    ```yaml
    - src: https://github.com/richeney/ansible-role-ansible-azure
      name: ansible_azure
    ```

1. Install the ansible_azure role

    ```bash
    ansible-galaxy install --roles-path /etc/ansible/roles --role-file /etc/ansible/requirements.yml
    ```

    Expected output:

    ```yaml
    - common is already installed, skipping.
    - azure_cli is already installed, skipping.
    - extracting ansible_azure to /etc/ansible/roles/ansible_azure
    - ansible_azure was installed successfully
    ```

1. Add the config_mgmt files for Ansible Local

    The Ansible Local provisioner specifies two files. Those files must exist on your laptop otherwise the packer build will error. (This is true even if the two files exist on the target VM due to a previous provisioner step.)

    Create the `/etc/ansible/config_mgmt.requirements.yml` file:

    ```yaml
    ---
    - src: darkwizard242.terraform
      name: terraform
    - src: darkwizard242.packer
      name: packer
    ...
    ```

    Create `/etc/ansible/config_mgmt.yml`:

    ```yaml
    ---
    ## Install additional configuration management software
    ## You would probably do this in the image, but we'll use to prove ansible_local
    # Call with
    #  `ansible-playbook -i 127.0.0.1, config_mgmt.yml`
    #  `ansible-playbook -i localhost, config_mgmt.yml`
    #  `ansible-playbook -i 10.2.3.4, config_mgmt.yml`
    #  `ansible-playbook -i host.suffix.com, config_mgmt.yml`

    - hosts: localhost
      connection: local
      become: yes
      gather_facts: no
      roles:
        - packer
        - terraform
      vars:
        terraform_version: 0.12.9

    ...
    ```

    This playbook is designed to only work on the localhost. Specifying `hosts: localhost` and `connection: local` makes that a clean operation as otherwise it would look to generate the dynamic inventory, and our managed identity does not have any access into the subscription at this point. Using `gather_facts: no` speeds up the playbook.

1. Create the image definition

    Final requirement before we can run the job is to create the image definition in our Shared Image Gallery. Here's a reminder of the shared_image_gallery_destination JSON object in the lab7.json Packer file:

    ```json
    "shared_image_gallery_destination": {
        "resource_group": "images",
        "gallery_name": "sharedImageGallery",
        "image_name": "ubuntu_ansible",
        "image_version": "1.0.0",
        "replication_regions": [
            "westeurope",
            "uaenorth",
            "southafricanorth"
        ]
    }
    ```

    The sharedImageGallery already exists, so you only have to create the `ubuntu_ansible` image definition.

    ```bash
    sigId=$(az sig show --resource-group images --gallery-name sharedImageGallery --query id --output tsv)
    az sig image-definition create --gallery-image-definition ubuntu_ansible --publisher "AzureCitadel" --offer Ansible --sku Ubuntu_18.04 --os-type linux --resource-group images --gallery-name sharedImageGallery
    ```

1. Run the Packer build

    ```bash
    packer build lab7.json
    ```

    Whilst that is running through, let's finally take a proper look at that custom role.

## The ansible_azure custom role

Open the repo - <https://github.com/richeney/ansible-role-ansible-azure> - in a new window.

The defaults, meta file and README.md shouldn't need explaining.  Let's look at what's new and interesting in the `tasks/main.yml` as it includes a number of techniques that you might want to incorporate into your own custom roles.

### Summary of Tasks

{% raw %}

* **Wait for any possibly unattended upgrade to finish** This is a good safety step for Ubuntu roles that use apt as Ubuntu has some default apt services that will automatically update security patches. It used the raw module, which is a low level module that doesn't even use python to execute. Useful complement to the command and shell modules.
* **Add the Ansible software repository**
* **Get packages needed for the install process** The apt module uses the full list variable `{{ packages }}` as the value to `name`. Also there is a conditional statement checking the Linux kernel family from the facts.
* **Install Azure version of Ansible via pip**
* **Add ansible group**
* **Create /etc/ansible directory**
* **Set default ACL on /etc/ansible** Loops over a simple list and references `{{ item }}`.
* **Copy files to /etc/ansible** Loops over the `{{ files }}` list variable, copying from files/ to /etc/ansible.
* **Check existence of requirements.yml to avoid overwrite** Uses the stat module and registers (stores) the result into a variable
* **Requirements.yml** block
    * Blocks are used to group tasks together
    * The whole block has a compound conditional, checking to see if the required_roles variable is defined and that it contains elements and that the requirements.yml file doesn't already exist
        * The last condition prevents overwrites if the playbook is run when the file has been manually updated
    * If the condition is passed then the **template** module is used to generate the requirement.yml file
        * See below for more info on templates
    * The roles directory is then created and the roles installed
* **Download required_playbooks to /etc/ansible**
    * Another compound conditional that checks the variables, this time expressed as a list of conditions
    * The `{{ raw_url_path }}` shows how to manipulate variables with the URL getting a sed style regex change, and then appending `/master` at the end (see [pretty](https://github.com/richeney/ansible-playbooks/blob/master/docker.yml) v [raw](https://raw.githubusercontent.com/richeney/ansible-playbooks/master/docker.yml) example URIs)
    * Another loop through the `{{ required_playbooks }}` list to then download the raw files to /etc/ansible using the get_url module
* **Add environment variable for Managed Identity to the skeleton files**
    * Use the lineinfile module to ensure `export ANSIBLE_AZURE_AUTH_SOURCE=msi` is in the /etc/skel/.profile and /etc/skel/.bashrc files
    * All new users will then have that set so ansible will use the VM's managed identity - more on that later

### Template files

The template file used to generate the requirements.yml is `./templates/requirements.j2`:

```yaml
{# Generate standard requirements.yml file based on list of requirements #}
---
{% for role in required_roles %}
  - src: {{ role.src }}
    name: {{ role.name }}
{% endfor %}
...
```

It uses the Jinja2 templating standard for dynamic content and using variables. This is a simple example that loops through the `{{ required_roles }}`` list. Each element in that list has src and name keys and the values are used in the loop.

See the[ Templating (Jinja2)](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html) documentation for more information and examples. The templating is very powerful. Read through the documentation page until the image deployment has succeeded.

{% endraw %}

## Deploying the config management VM

OK, so we now have a new ubuntu_ansible image, based on the ubuntu_standard image, but with added Ansible goodness installed.  It also has bother Terraform and Packer installed via Ansible Local so that you can see that provisioner in action.

> In reality I would have installed the Hashicorp binaries into the image by creating a config_mgmt.yml playbook that called the custom ansible_azure role as well as the packer and terraform roles installed from Ansible Galaxy. Cleaner and simpler.

We'll now deploy that image into a packer_test resource group. We'll use Terraform for the deployment as Packer, Terraform and Ansible are a naturally complementary set of products. The deployment will create a virtual network, subnet and then attach a simple VM from the image. There are four things of interest in the deployment:

1. a managed identity is created for the VM
1. cloud-init is used to invoke a simple command line
1. the CustomScript VM extension is used to download a playbook file and then run (to add additional users)
1. the managed identity is assigned the Contributor roles for the subscription

## Service Principals and Managed Identity

So, what is Managed Identity?

### Short(er) answer

The short answer is that it is a special kind of service principal which is linked with an Azure compute resource instance. (Virtual Machine, VMSS, App Plan host, etc.) The managed identity is removed if the resource is deleted.

Rather than using a secret or cert as part of the oauth2 token process, it gets the token from the instance metadata service.

One application pattern is to use Managed Identity to grant a compute instance access to Key Vault and then the application gets the secrets and certs it needs to access resources.

Here we are using managed instance to grant Ansible access from the VM to the subscription as Contributor.

We'll first need to extend the API permissions for the http[]()://hashicorp service principal to allow it to assign roles.

### Longer answer

This section is a bit tl;dr, so feel free skip straight to skip to the [next section](#rbac-custom-role-for-role-assignment)!

Azure AD (AAD) is a complex and confusing area that meets an incredibly diverse range of business requirements. This section may help you to understand it a little more, or it may have exactly the opposite effect. I only have a tentative grasp on this area so please contact me to correct any errors. OK, you've been warned. Let's go.

Managed Instance is a variant on a service principals. Managed Instance used to be called Managed Service Instance or MSI. Let's go back a step and describe app objects, service principals and managed identity.

The top level object for a service principal is an app object. You can see this if you go into the portal's [app registrations blade](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade) and filter names on _hashicorp_.

App developers create app registrations at this level, choosing single tenant (default) or multi tenant. At this object level there are lots of configuration options for branding, authentication, certificates, secrets, API permissions, exposing APIs, replyURLs, etc. There is control over who can access an app, how they authenticate to it, how the token authorisation works and what that app can do in terms of Microsoft Graph and other APIs. As well as the display name, an app object will be linked to the owner's home tenantId and will have its own objectId. It will also have an appId, which is used to link it to the service principal(s).

If single tenant has been selected then only one service principal will be created. If you look at the app registration blade's overview page then you will see Managed Application in Local Directory. Click on that link and it will show a special kind of Enterprise Application and that is your service principal. Now Enterprise Applications covers a wider area including integration with third party apps (such as Salesforce) or on premise applications.  (If you look at [Enterprise Applications](https://portal.azure.com/#blade/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/AllApps) then you won't even see your service principal listed, as it is effectively hidden.) At this service principal level you can see the appId is consistent with the app object, but there is a different objectId.

So the app object is a global construct, whilst the service principals are local to each tenantId. So, by default you will have two AAD objects and therefore two objectIds, linked by a common appId. If it is a multi-tenanted app then there will be one app object and several service principals. Lots of objectIds, but only one appId to link them.

We talked about API permissions at the app object level. Access control to Azure resource is handled via security principals, which can either be a user (user principal) or an application (service principal).

The service principals are then granted the appropriate role assignments for the access they require, with a role assignment being a combination of who (AAD objectId), what (RBAC role) and where (ARM scope point).

In the early labs you use the CLI to create service principals. The `az ad sp create-for-rbac` defaults the scope to the subscriptionId and the role to Contributor, but we specified them for clarity.  We also specified the name (e.g. `http://hashicorp`), but the command will also generate a name if you do not specify one, so `az ad sp create-for-rbac` is a complete command. The JSON output for the command shows the name, displayName tenantId, appId and password.

If you run `az ad sp show --id http://hashicorp --output jsonc` then hopefully some of the output makes a little more sense now.

What you don't see from this point onwards is that these values are used by the application against a REST API to get the token required for access.  The token is then included in the resultant headers for subsequent calls to the https://management.azure.com REST API. If the token expires then the application goes and gets another.

Managed Identity is a variant of a service principal and its lifecycle is linked to that of the associated compute resource. Managed Identity uses the instance metadata service to get its token, so there is no need for the application to store any password or secret for a service principal.

We can create the managed identity when the VM is created, but it will have no access to the subscription and so the Ansible dynamic inventories will fail. To overcome this we will assign Contributor role to the subscription. However we will be running Terraform using the http[]()://hashicorp service principal which currently has Contributor.  We will need to add the ability to assign roles. Let's do that now.

## RBAC Custom Role for Role Assignment

The http[]()://hashicorp service principal already has the Contributor role. We'll add the ability to assign roles.

1. Create a custom role JSON file

    Create a file called `~/packer/terraform.roleassignment.json`:

    ```json
    {
        "Name":  "RoleAssignment",
        "IsCustom":  true,
        "Description":  "Secondary role. Allows Terraform to assign and remove Managed Identity via azurerm_role_assignment.",
        "Actions":  [
            "*/read",
            "Microsoft.Authorization/roleAssignments/*"
            ],
        "NotActions":  [],
        "DataActions": [],
        "NotDataActions": [],
        "AssignableScopes":  [
            "/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc"
            ]
    }
    ```

1. Create the custom role

    ```bash
    az role definition create --role-definition terraform.roleassignment.json
    ```

1. Assign the additional role

    ```bash
    scope=/subscriptions/$(az account show --query id --output tsv)
    az role assignment create --role RoleAssignment --assignee http://hashicorp --scope $scope
    ```

The http[]()://hashicorp service principal should now be able to use the Terraform azurerm_role_assignment resource.

![Role Assignments](/automation/packeransible/images/iam.png)

## Use Terraform to deploy a test config mgmt server

We won't explain Terraform in this lab.  If you want to learn more then please use the [Terraform labs](/automation/terraform) on this site.

1. Create a simple Terraform config

    Create a file called `~/packer/packer_test.tf`:

    ```hcl
    provider "random" {}

    provider "azurerm" {
      version   = "=1.34.0"
    }

    locals {
        name = "configmanagement"
        admin = "richeney"
    }

    data "azurerm_subscription" "current" {}

    data "azurerm_role_definition" "contributor" {
      name = "Contributor"
    }

    data "azurerm_shared_image" "ubuntu_ansible" {
      name                = "ubuntu_ansible"
      gallery_name        = "sharedImageGallery"
      resource_group_name = "images"
    }

    resource "azurerm_resource_group" "test" {
      name     = "packer_test"
      location = "West Europe"
    }

    resource "azurerm_public_ip" "test" {
      name                = "test"
      location            = azurerm_resource_group.test.location
      resource_group_name = azurerm_resource_group.test.name
      allocation_method   = "Static"
    }

    resource "azurerm_virtual_network" "test" {
      name                = "test"
      address_space       = [ "10.0.0.0/16" ]
      location            = azurerm_resource_group.test.location
      resource_group_name = azurerm_resource_group.test.name
    }

    resource "azurerm_subnet" "test" {
      name                 = "test"
      resource_group_name  = azurerm_resource_group.test.name
      virtual_network_name = azurerm_virtual_network.test.name
      address_prefix       = "10.0.1.0/24"
    }

    resource "azurerm_network_interface" "test" {
      name                = "test"
      location            = azurerm_resource_group.test.location
      resource_group_name = azurerm_resource_group.test.name

      ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = azurerm_subnet.test.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.test.id
      }
    }

    resource "azurerm_virtual_machine" "test" {
      name                  = local.name
      location              = azurerm_resource_group.test.location
      resource_group_name   = azurerm_resource_group.test.name
      network_interface_ids = [ azurerm_network_interface.test.id ]
      vm_size               = "Standard_B1s"

      storage_image_reference {
        id = data.azurerm_shared_image.ubuntu_ansible.id
      }

      os_profile {
        computer_name  = local.name
        admin_username = local.admin
        custom_data    = "/usr/sbin/usermod -a -G ansible ${local.admin}"
      }

      os_profile_linux_config {
        ssh_keys {
          key_data = file("~/.ssh/id_rsa.pub")
          path      = "/home/${local.admin}/.ssh/authorized_keys"
        }
        disable_password_authentication = true
      }

      identity {
          type = "SystemAssigned"
      }

      storage_os_disk {
          name              = "${local.name}-os"
          create_option     = "FromImage"
          os_type           = "linux"
          managed_disk_type = "StandardSSD_LRS"
      }
    }

    resource "azurerm_virtual_machine_extension" "test" {
      name                 = local.name
      location             = azurerm_resource_group.test.location
      resource_group_name  = azurerm_resource_group.test.name
      virtual_machine_name = azurerm_virtual_machine.test.name
      publisher            = "Microsoft.Azure.Extensions"
      type                 = "CustomScript"
      type_handler_version = "2.0"

      settings = <<SETTINGS
        {
            "fileUris": [
                "https://raw.githubusercontent.com/richeney/ansible-playbooks/master/additional_ansible_users.yml"
            ],
            "commandToExecute": "/usr/local/bin/ansible-playbook additional_ansible_users.yml"
        }
    SETTINGS

    }

    resource "random_uuid" "test" { }

    resource "azurerm_role_assignment" "test" {
      name               = random_uuid.test.result
      scope              = data.azurerm_subscription.current.id
      role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.contributor.id}"
      principal_id       = lookup(azurerm_virtual_machine.test.identity[0], "principal_id")
    }
    ```

    > Don't forget to change local.admin to your own ID so that it will find your ssh keys.

1. Install Terraform binary

    If you already have the current Terraform binary then skip to the next step. If not then we'll use a script to install it quickly. (You might already have the script from when you installed packer; if so then just run the last command.)

    ```bash
    script=installLatestHashicorpBinary.sh
    curl -sSL https://raw.githubusercontent.com/richeney/arm/master/scripts/$script --output ~/$script && chmod 755 $script
    ~/installLatestHashicorpBinary.sh terraform
    ```

1. Deploy using Terraform

    We'll get it running and then you can move onto the next section and we'll run through some key sections in the Terraform config.

    First, run through the Terraform workflow to deploy:

    ```bash
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

## Terraform Config

Let's look at some of that Terraform config.

### Shared Image Gallery image

We use a data to get info on the image:

```hcl
data "azurerm_shared_image" "ubuntu_ansible" {
  name                = "ubuntu_ansible"
  gallery_name        = "sharedImageGallery"
  resource_group_name = "images"
}
```

This is then referenced in the azurerm_virtual_machine block:

```hcl
storage_image_reference {
  id = data.azurerm_shared_image.ubuntu_ansible.id
}
```

### cloud-init

The os_profile block in the VM has a custom_data value:

```hcl
os_profile {
  computer_name  = local.name
  admin_username = local.admin
  custom_data    = "/usr/sbin/usermod -a -G ansible ${local.admin}"
}
```

For Linux VMs this is run automatically as a [cloud-init](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init). This is great for small scripts or single commands. It is common to do "final mile" configuration for your images, and this is one of the control points that you can use. Here we are adding the admin user to the ansible group.

### Managed Identity

The following block in the VM creates a system assigned managed identity:

```hcl
identity {
    type = "SystemAssigned"
}
```

It also supports user assigned managed identity if you want to reuse an existing user created service principal across multiple VMs.

The penultimate resource generates a GUID. This is then used for the role assignment, as well as data blocks for the Contributor role and current subscription.

```hcl
resource "random_uuid" "test" { }

resource "azurerm_role_assignment" "test" {
  name               = random_uuid.test.result
  scope              = data.azurerm_subscription.current.id
  role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.contributor.id}"
  principal_id       = azurerm_virtual_machine.test.identity.0.principal_id
}
```

The principal_id value is pulled from the attributes exported from the virtual machine.

### CustomScript extension

This is the second control point for last mile configuration, and is more complicated but also more powerful and flexible.

The azurerm_virtual_machine_extension resource is type `CustomScript`, and has the following settings JSON heredoc:

```json
{
    "fileUris": [
        "https://raw.githubusercontent.com/richeney/ansible-playbooks/master/additional_ansible_users.yml"
    ],
    "commandToExecute": "/usr/local/bin/ansible-playbook additional_ansible_users.yml"
}
```

This extension allows you to upload a set of files or scripts and then execute a command. The [Terraform documentation](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html) is a little sparse, so use the [Azure documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux) to see the full schema and options. The protectedSettings is good if you need to hide details of the script and command from the Terraform state or ARM deployments history.

## Test the configmanagement VM

Once the Terraform apply has completed then you should have the following resources:

![packer_test](/automation/packeransible/images/packer_test.png)

1. Find the public IP address

    ```bash
    az vm list-ip-addresses --resource-group packer_test --output table
    ```

    Example output:

    ```text
    VirtualMachine    PublicIPAddresses    PrivateIPAddresses
    ----------------  -------------------  --------------------
    configmanagement  40.91.238.227        10.0.1.4
    ```

1. SSH on to the configmanagement VM

    Example command:

    ```bash
    ssh richeney@40.91.238.227
    ```

1. Check the Managed Identity

    Use curl to access the Instance Metadata Service to show that it is getting the token.

    ```bash
    curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' -H Metadata:true | jq .
    ```

    > Note that you don't need to do this step; it is included to illustrate how MSI authenticates.

1. Check ansible

    ```bash
    ansible --version
    tree /etc/ansible
    set | grep -i ^ansible
    ansible list --all -hosts
    ```

Ansible is using MSI to access the VMs in the subscription. Note the `auth_source: msi` setting in the `/etc/ansible/inventory.azure_rm.yml`.

1. Create a small playbook

    If you remember, the required_roles list we had for the install_ansible.yml playbook included docker and pip.

<<< Did not download the required check the image creation >>>
<<< Also ssh >>>

## Finishing Up

Clean up the resource groups.

[◄ Lab 6: Shared Image Gallery](../lab6){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse}
