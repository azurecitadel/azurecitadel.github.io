---
title: Cloning the repo locally
date: 2019-01-18
author: Richard Cheney
comments: true
hidden: true
published: true
permalink: /contributing/cloning/
header:
  overlay_image: /images/site/main.png
excerpt: Fork and clone the repo to start contributing.
sidebar:
  nav: "contributing"
---

## Introduction

This guide will walk you through the first few steps of the GitHub workflow, forking the repository to your laptop, ready to create content within vscode.

Git veterans can freely skip this page!

## Prerequisites

You will need to have met the core [vscode prereqs](/prereqs/vscode) to be able to upload:

* Visual Studio Code
* Git
* Bash on Ubuntu configured as the Integrated Console (Terminal)

## 1. Fork the repo

You will need to create your own [GitHub](https://github.com/join) ID if you do not already have one.

> If you create a new GitHub ID then there is no need to add a new repository as we will be forking the Citadel repo in the next step.

1. Go to <https://github.com/azurecitadel/azurecitadel.github.io>
1. Click on the **fork** button at the top right of the screen
    * This will copy the main repository into your GitHub account
    * It will also retain a link back to the main repo
1. You will now be in your fork- if you look at the browser address bar then the URL will be in the format `https://github.com/yourGitHubId/azurecitadel.github.io`
1. Copy the URL in the address bar (`CTRL`+`L`, `CTRL`+`C`)

We will use this in the next step.

## 2. Clone within vscode

You can then clone the repository:

1. Open vscode
1. Open the Command Palette (`CTRL`+`SHIFT`+`P`)
1. Type `git clone`
    1. Hit `Enter` to select `Gi: Clone`
1. You will be prompted to enter the **Repository URL**
    1. Paste in the URL for your fork of the repo that you copied from the address bar
1. You will be prompted to choose the destination directory
   1. It is common to have one git folder for your repos
   1. E.g. `C:\git` or `%USERPROFILE%\git`
1. Wait until the repo has cloned
1. You will see a toast notification once the cloning has completed
    1. You'll be prompted to either Open or Open in New Windows
    1. Click **Open**

## 3. Add azurecitadel as the upstream

You'll need to add azurecitadel as your upstream to request your changes to be pulled into the main repo later.

We'll run a few commands in the Terminal (which used to be called the integrated console). You can open the Terminal from the menu using _Terminal --> New Terminal_, or use the `CTRL`+`'` keyboard shortcut.

1. See that your current git remote is the origin using the following command:

```bash
git remote -v
```

Example output:

```bash
origin  https://github.com/richeney/azurecitadel.github.io (fetch)
origin  https://github.com/richeney/azurecitadel.github.io (push)
```

2. Add the main repo as the upstream:

```bash
git remote add upstream http://github.com/azurecitadel/azurecitadel.github.io
```

3. Check it is now in the list of remotes:

```bash
git remote -v
```

Example output:

```bash
origin    https://github.com/richeney/azurecitadel.github.io (fetch)
origin    https://github.com/richeney/azurecitadel.github.io (push)
upstream  https://github.com/azurecitadel/azurecitadel.github.io (fetch)
upstream  https://github.com/azurecitadel/azurecitadel.github.io (push)
```

You now have both the origin (to your fork) and the upstream (to the azurecitadel repo itself).

> Before working on files, it is always a good idea to pull down any updates in the upstream.   Click on the ellipsis (**...**) in the Source Control sidebar (CTRL-SHIFT-G) and select **Pull from...**. Select the upstream, and then the master branch.

You are now ready to create content. If this is the first time you have contributed then you should add yourself as an author first, so click that link.

(If you are already listed in the authors.yml then you can fast forward to the Content page.)

[◄ GitHub](../github){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Authors ►](../authors){: .btn .btn--primary} [Content ►►](../content){: .btn .btn--primary}
