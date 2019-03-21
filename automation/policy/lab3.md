---
title: "Inbuilt Policies and Policy Initiatives"
date: 2019-03-25
author: [ "Tom Wilde", "Richard Cheney" ]
category: automation
comments: true
featured: false
hidden: false
published: false
tags: [ policy, initiative, compliance, governance ]
header:
  overlay_image: images/header/whiteboard.png
  teaser: images/teaser/blueprint.png
sidebar:
  nav: "policy"
excerpt: Using a policy initiative DeployIfNotExist for automatic agent deployment.
---

## Introduction

All organizations should have a monitoring strategy but ensuring that monitoring is actually set up correctly in an ever-changing environment can be tricky task. In this lab we'll make sure resources are set up to use Azure Monitor automatically.

## Initiatives

An initiative is basically a collection of policy definitions that are tailored towards achieving a singular overarching goal, i.e. Deploy Azure Monitor for Virtual Machines. 

1. Azure Monitor relies on log analytics to store all its data, so first we need a [create a Log Anlaytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace) if you don't have one.

![Policy Definition](/automation/policy/images/lab3-create-la.png)
**Figure 1:** Create Log Analytics Workspace

2. There are various agents that need to be installed on Windows and Linux to get the full functionality of Azure Monitor, you can read about them [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agents-overview). 

Handily Azure Policy already has an initiative which contains the relevant definitions each deploying an agent. 
Navigate to Definitions in Azure Policy, set the definition type to Initiative and open "Enable Azure Monitor for VMs"

Notice the definitions do not have a "deny" effect type like labs 1 and 2, we have DeployIfNotExists and AuditIfNotExists. Explore each definition and click Assign.

![Policy Definition](/automation/policy/images/lab3-view-monitor-initiative.png)
**Figure 2:** Enable Azure Monitor for VMs initiative

3. Keep the same scope as the previous labs, Subscription/PolicyLab and choose the Log Analytics workspace you just created. 

The optional parameters are if you had your own Windows/Linux images (that support the agents), you could add them to the scope of this initiative.

Under Managed Identity, you can see the check box is selected, this is because the initiative being assigned includes a policy with the deployIfNotExists effect. A Managed Identity is required because permissions will be needed to deploy the agents to the virtual machines and instead of adding a username and password, Azure will manage this for you. See [here](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) for more details on Managed Identities.

Click Assign.

![Policy Definition](/automation/policy/images/lab3-assign-monitor-initiative.png)
**Figure 3:** Assign Azure Monitor for VMs initiative

4. Let's deploy some VM's using Azure CLI to test.

```bash
# Deploy UbuntuLTS VM
az vm create -n Lab3UbuntuLTS -g PolicyLab --image UbuntuLTS --admin-username policyuser --size Standard_D2s_v3 --no-wait

# Deploy Windows 2016 VM
az vm create -n Lab3Windows2016 -g PolicyLab --image Win2016Datacenter --admin-username policyuser --size Standard_D2s_v3 --no-wait
```

That takes care of deploying VM's that support the agents, let's deploy a VM that can't yet.

```bash
# Deploy Core VM
az vm create -n Lab3Core -g PolicyLab --image CoreOS --admin-username policyuser --size Standard_D2s_v3 --no-wait
```

Now go and have a cup of tea, seriously, because Azure Policy is not instant. It can take 30mins or more to finish evaluating/installing/etc.

5. After a while Azure Policy will have finished evaluating the VM's and installing the agents where possible. Open Compliance in Azure Policy, set the scope to be Subscription/PolicyLab, you can also do this by opening "Policies" directly from your resource group. You should see we have compliant and non-compliant resources and all your policies/initiatives assigned. 

6. Open up the "Enable Azure Monitor for VMs" initiative and open the policy definitions for more details. 

![View Azure Monitor for VMs initiative](/automation/policy/images/lab3-view-monitor-initiative-compliance.png)
**Figure 4:** View Azure Monitor for VMs initiative 

You should see the policies for log analytics and dependency agents on Windows VMs as compliant, that's Azure Monitor enabled automatically for the VM Lab3Windows2016. 
The policies with unsupported images will show Lab3Core as it's running an OS that doesn't support Azure Monitor. 
The policies for linux will show some VM's as compliant and some as not compliant. This is because the VM Lab3UbuntuLTS automatically got the agent but the VM's deployed before the policy was applied didn't.

![View Log Analytics for Linux policy](/automation/policy/images/lab3-view-la-policy-linux.png)
**Figure 5:** View Log Analytics for Linux policy 

7. Click create remediation task and then click remediate.

![New remediation task](/automation/policy/images/lab3-new-remediation-task.png)
**Figure 6:** New remediation task 

Repeat this for both linux policies.

![Remediating in progress](/automation/policy/images/lab3-remediating.pngg)
**Figure 7:** Remediating in progress

8. After the tasks have completed you can validate the agents have all been installed.

```bash
az vm extension list -g PolicyLab --vm-name PolicyLabVM -o table

az vm extension list -g PolicyLab --vm-name Lab2VM -o table

az vm extension list -g PolicyLab --vm-name Lab3UbuntuLTS -o table

az vm extension list -g PolicyLab --vm-name Lab3Windows2016 -o table

az vm extension list -g PolicyLab --vm-name Lab3Core -o table
```

You should see the MMAExtension and DependencyAgent extensions have been installed on all VM's apart from Lab3Core. 


That concludes this lab, where we've learnt how to use a policy initiative to automatically deploy the Azure Monitor agents for new VM's and remediated existing VM's.

Keep the PolicyLab resource group but you can delete all the VM's.

```bash
az vm delete --ids $(az vm list -g MyResourceGroup --query "[].id" -o tsv)
```

Next we'll create some policies to ensure a resource naming policy


[◄ Lab 2: Audit](../lab2){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 4: Deploy ►](../lab4){: .btn .btn--primary}