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

# Introduction

This guide will walk you through the first few steps of the GitHub workflow, forking the repository to your laptop, ready to create content within vscode.

Git veterans can freely skip this page!

# Process

## 1. Fork the repo

You will need to create your own [GitHub](https://github.com/join) ID if you do not already have one.

1. Go to <https://github.com/azurecitadel/azurecitadel.github.io>
1. Click on the **fork** button at the top right of the screen
    * You will now have your working copy of the master repo in GitHub: `https://github.com/yourGitHubId/azurecitadel.github.io`
1. Copy the URL in the address bar (CTRL-L, CTRL-C)

## 2. Clone within vscode

You will need to have met the core [vscode prereqs](/prereqs/vscode) to be able to upload:

* Visual Studio Code
* Git
* Bash on Ubuntu configured as the Integrated Console

You can then clone the repository:

1. Open vscode
1. Open the Command Palette (CTRL-SHIFT-P)
1. Type `git clone`
    1. Paste in the URL for your fork of the repo
    1. Choose which local directory will be used

## 3. Add azurecitadel as the upstream

If you run `git remote -v` in the integrated terminal then you'll see your GitHub fork as the 'origin'.  You'll need to add azurecitadel as your upstream to request your changes to be pulled into the main repo later.

Run the following in the integrated console:

1. `git remote add upstream http://github.com/azurecitadel/azurecitadel.github.io`
2. `git remote -v`

You now have both the origin (to your fork) and the upstream (to the azurecitadel repo itself).

> Before working on files, it is always a good idea to pull down any updates in the upstream.   Either select Pull from the ellipsis (**...**) in the SCM screen (CTRL-SHIFT-G), or click on the sync button (![sync](/prereqs/contributing/images/sync.png)) at the bottom left of vscode. (Note that a sync does the same but also pushes up from your side.)

You are now ready to create content. If this is the first time you have contributed then you should add yourself as an author first.  If you are already in there then you can fast forward to the Content page.

[◄ GitHub](../github){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Authors ►](../authors){: .btn .btn--primary} [Content ►►](../content){: .btn .btn--primary}
