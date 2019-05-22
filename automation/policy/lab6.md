---
title: "Automatically deploy Azure Backup using GitHub policies"
date: 2019-03-25
author: [ "Tom Wilde" ]
category: automation
comments: true
featured: false
hidden: false
published: false
tags: [ policy, initiative, compliance, governance ]
header:
  overlay_image: images/header/whiteboard.jpg
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "policy"
excerpt: "Automatically deploy Azure Backup using GitHub policies"
---

## Introduction

All organizations should have a backup strategy but ensuring that backup is actually configured in an ever-changing environment can be easily forgotton. In this lab we'll make sure virtual machines are configured to use Azure Backup automatically.

## Using Policies from GitHub

There isn't a built in Azure Policy for Recovery Vaults or Backup so in this instance we'll use definitions from GitHub.

1. View the Azure Policies [here](https://github.com/towilde/policy) to see that it meets the requirements. In a nut shell, these definitions look at your Recovery Services Vault to see if your in scope VMs have the required backup policy set, if they don't, it will make the change.

1. Let's create resources needed for the policies ()

```bash

# Setting the variables
rg=PolicyLab
loc=uksouth
vault=RecoveryServicesVault

# Create Resource Group if you don't have one
az group create -n $rg -l $loc

# Create Backup Vault
az backup vault create --resource-group $rg \
    --name RecoveryServicesVault \
    --location $loc
```

1. When you create a Recovery Service Vault a Backup Policy for Virtual Machines is automatically created.

```bash
# View the default backup policy
az backup policy list --resource-group $rg --vault-name $vault -o jsonc --query "[? name == 'DefaultPolicy']"
```

1. Let's create a new subdirectory called policy if you don't have one already

    ```bash
    mkdir -m 755 policy
    ```

```bash
# Set the scope variable
  scope=$(az group show --name 'PolicyLab' --output tsv --query id)
```


[◄ Lab 4: Deploy](../lab4){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 6: Tagging ►](../lab6){: .btn .btn--primary}