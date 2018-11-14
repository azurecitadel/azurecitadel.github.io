---
layout: article
title: "Terraform Marketplace VM"
categories: null
date: 2018-10-29
tags: [azure, terraform, marketplace, msi]
comments: true
author: Richard_Cheney
published: true
---

## Terraform VM on the Azure Marketplace

> It is assumed that you are now working with Terraform locally on your machine rather than in Cloud Shell and that you are using the service principal to authenticate.  This section on Terraform VM and MSI is for information only - there is no need to run the offering.

If you are only working within one subscription then an easy production alternative to using service principals is to use the new Terraform VM offering on the marketplace.

This is ideal for customers who want to use a single Terraform instance across multiple team members, multiple automation scenarios and shared environments.  It also provides a linux VM in the subscription that can be used for other admin purposes.

Rather than using CLI 2.0 or Service Principals for the authentication, it uses the third possible authentication method, [Managed Service Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-service-identity/overview).  With MSI the whole Terraform service is effectively authorised for access to a subscription.

The Terraform offering in the Marketplace is detailed at <https://aka.ms/aztf>, and is free except for the underlying VM hardware resource costs. The Ubuntu VM will have the following preconfigured:

* Terraform (latest)
* Azure CLI 2.0
* Managed Service Identity (MSI) VM Extension
* unzip
* jq
* apt-transport-https

It features:

* Shared remote state with locking, backed off to Azure Storage
* Shared identity using MSI and RBAC

There is also an Azure Docs page at <https://aka.ms/aztfdoc> which covers how to access and configure the Terraform VM by running the `~/tfEnv.sh` script. Note that if you have multiple subscriptions then you should again make sure that you are in the correct one and then run just the role assignment command within the `tfEnv.sh` file.

One of the nice features of the Terraform VM Marketplace offering is that it will automatically back off the local terraform.tfstate to blob storage, with locking based on blob storage leases. (We will be looking at how to do this manually in the next lab.)

It also creates a remoteState.tf file for you in your home directory. The remoteState.tf has the following format:

```ruby
terraform {
 backend "azurerm" {
  storage_account_name = "storestatelkbfjngsqkyiim"
  container_name       = "terraform-state"
  key                  = "prod.terraform.tfstate"
  access_key           = "6Wbo0IfW3YKRbsjeF9LFxyvlA2dJ8cJQF+ys6ZHIkW8GdBemXB20MGv66E+Nxx5Wi5KjeCXuVF7BcMo1OPAZYw=="
  }
}
```

Note that the "key" is the name of the blob that will be created in the terraform-state container.

### Optional group setting configuration

When you first connect using ssh to your Terraform VM then you'll be in your admin IDs home directory.  You can check the `/etc/passwd` and `/etc/group` files to show your default group.

You could use it like this if you were the only one working on the deployment. But if you were working as a team of Terraform admins for a deployment then you'd probably want to add a group of admins and a shared area for the Terraform files. (And optionally change the default group for your ID.) The code block below shows how thios can be done:

```bash
$ sudo addgroup terraform
Adding group 'terraform' (GID 1001) ...
$ sudo usermod --group terraform richeney
$ sudo mkdir --mode 2775 /terraform
$ sudo chgrp terraform /terraform
$ ll -d /terraform
drwxrwsr-x 2 root terraform 4096 Mar 19 11:19 /terraform/
```

Only members of the new terraform group will be able to create files in the /terraform folder.  The setgid permission ensures that all new files will automatically be assigned terraform as the group rather than the user's default group. You may need to log out of the Terraform VM and then log back in again to reflect the usermod change to the /etc/passwd file.

[◄ Return to Lab 5](../lab5#end-of-lab-5){: .btn-subtle} [▲ Index](../#labs){: .btn-subtle}