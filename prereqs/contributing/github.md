---
title: GitHub Workflow
date: 2019-01-18
author: Richard Cheney
comments: true
hidden: true
published: true
permalink: /contributing/github/
header:
  overlay_image: /images/site/main.png
excerpt: New to Git? Learn some basics and the workflow we use for Citadel contributions.
sidebar:
  nav: "contributing"
---

## Workflow

The site is hosted in a GitHub repository, so if you wish to contribute then it is a good idea to have a foundational knowledge of how to use Git. The main Git site has some useful [videos](https://git-scm.com/videos).

Most contributors do not have write access to the main azurecitadel copy of the repo, so you cannot clone it directly, make changes and push them up. You have to create a fork of the repo and commit changes there.  You can then create a pull request (or PR) to then request that the changes in your fork are then pulled into the main <https://github.com/azurecitadel/azurecitadel.github.io> repository.

The diagram below show the overall flow we follow with GitHub.

![Git Workflow](/prereqs/contributing/images/gitWorkflow.png)

1. The first step in the process is to create a fork of the repository under your own ID.  You will have read write access to your fork
1. You can then clone that fork locally ready to work on new content.
1. Your GitHub fork will be the "origin" remote.  Add the main repo as the "upstream" remote.  You can keep your clone up to date by pulling down any other changes to the main repo. (Or indeed your fork if there are multiple authors.)  (the "origin"can update other changes made to your fork (the "origin"). Once you want to save that content it can then be committed and pushed back up to your fork.
1. You can create and edit content locally and view it using the markdown preview or by running Jekyll locally on your laptop.
1. Once you are happy with the content then you can stage and commit your new and modified files.  They are now committed to the master branch in your local clone.
1. Once committed, the changes can be pushed, which will send that commit up into your fork hosted on GitHub. Or use sync, which will push and pull changes in both directions.)
1. You can then create a Pull Request.  The Azure Citadel admins will then review the request.  You may get comments and requests to modify content before the PR is merged into the main repository.

Jekyll then regenerates the static HTML site and your changes will be live on [Azure Citadel](https://azurecitadel.com).

Please be patient with the admins.  We will often be busy with partner engagements, on training or on well earned holidays, but we welcome contributions so endeavour to get to the pull requests in a reasonable timeframe.

## Branches

Note that we currently make all commits directly into the master branch.

Most of the contributions do not create any level of conflict with other authors' contributions. Therefore creating branches is considered an unnecessary complication for Azure Citadel.

If that approach changes then we will add a news page and update this guide.

[◄ Categories](../categories){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Cloning ►](../cloning){: .btn .btn--primary}
