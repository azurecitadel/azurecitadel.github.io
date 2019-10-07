---
title: "Packer and Ansible labs"
author: "Richard Cheney"
published: true
excerpt: New set of labs for creating VM images with Packer and managing VMs at scale with Ansible.
---

## Introduction

The team behind this site does a lot of work with partners who are looking to automate as much as possible with the cloud. This has been the catalyst for a lot of the content creation for this site, but we see major benefits in making that publicly available for the greater good!

We do have a number of partners who work purely on Azure, we the reality is that most of us live in a multi-cloud world. On Azure Citadel we intentionally focus on Linux rather than Windows and have a love of all things open source whilst working on Azure. The same open source and multi cloud viewpoint has driven the choice of tooling used by some of our partners and by a number of customers.

A good example is Hashicorp's Terraform, used for infrastructure as code deployments as a multi-cloud alternative to the native ARM templates that can only be used on Azure. The [Terraform labs](/automation/terraform) are some of the most popular on this site. Over 15% of all Linux VMs on Azure are deployed via Terraform, and that number is growing.

## Images and Declarative Management

One area that the site has not focused on to date is virtual machines. This is understandable given the modernisation direction towards containers, serverless, micro services and PaaS. Having said that, the reality is that an enormous percentage of the compute on the platform is still VM based and should not be neglected, particularly given the number of customer migrations onto Azure. Migrations may be straight lift and shift, porting a VMware or Hyper-V VM straight into a vNet, or may be a clean VM deployment with software installation and migration of the application data.

VMs are then often managed individually rather than as groups. If a VM gets an issue then it is common for an admin to log on and try to fix the problem as that is (usually) faster than having to rebuild that system from scratch.

There is a notable contrast when compared to the management of containers. If we look at the Azure Kubernetes Service (AKS), which is one of the fastest growing technologies on Azure, then everything is geared towards the creation and deployment of container images, and the management of those at scale using declarative templates.  If a container errors then it is unceremoniously killed and another is generated from the image in the container registry, using the definitions in the YAML files.

Many of you will have seen articles using the analogy of pets v cattle with regard to the management of virtual machines and containers. A quick web search throws up a number of blog posts discussing the merits of the various approaches and tooling.

So, can we apply some of that management approach to our old school VMs?

## Packer and Ansible

Packer is another product from the Hashicorp stable, and is the default image creation software for Azure.  (Packer also underpins the preview Azure Image Builder service, but we will use it natively to stay aligned with the multi-cloud tooling standpoint.) Packer has a number of builders (including Azure) and several provisioners, including two for Ansible.

Ansible can be used for infrastructure deployment - there is an azurerm provider - but is better known for config management. (Chef, Puppet, Salt, Octopus etc. also play in this area.) It is popular as it is open source, manages VMs agentlessly and has a significant community contributing useful roles into Ansible Galaxy.

And the two technologies play together very nicely.

## Packer and Ansible labs

So here we are.  A set of labs for Packer and Ansible that build on each other and include a number of Azure specific integration points.

If you work through the full set of labs then you will:

* build simple VM images with **Packer**
* deploy a few VMs from your custom image
* manage static groups of VMs using ad hoc **Ansible** CLI commands
* dynamically generate groups of VMs based on information from the **Instance Metadata Service**
* declaratively manage your VMs using **Ansible playbooks**
* search the **Ansible Galaxy** for roles to install and include in playbooks
* create and publish your own **custom roles**
* deploy a **Shared Image Gallery** and create an image definition
* combine Packer and Ansible and create a baseline Ubuntu image published to the Shared Image Gallery
* add a **custom RBAC role** to enable role assignment write action for the service principal
* use the baseline image as a source with both Ansible (remote) and Ansible Local
* deploy a config management server (with Managed Identity) from the Shared Image Gallery image using **Terraform**
* use a combination of **cloud-init** and **custom script extension** to illustrate last mile VM configuration options
* include an RBAC role assignment for the VM's **Managed Identity** so that it is ready to manage VMs in that subscription

## Finishing Up

The labs cover a lot of ground and if you have always been interested in how Packer and Ansible could change how you deploy and manage VMs then take a look. Please make use of the Disqus comments areas to give us feedback and to let us know how you use Packer and Ansible with your customers.

One of the blog articles talks about pets v cattle v chickens, where cattle are VM images and software managed VMs, and chickens are container images / Kubernetes, and I think that these labs help towards making that a reality.
