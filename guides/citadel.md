---
layout: article
title: Contributing to Azure Citadel
date: 2018-01-08
categories: guides
tags: [citadel, markdown, git, github, jekyll]
comments: true
author: Richard_Cheney
image:
  teaser: cloud-tools.png
excerpt: Want to contribute content to Azure Citadel?  Read our guide. 
---

{% include toc.html %}


## Introduction

The Azure Citadel site is hosted in GitHub pages.  This allows contributors to  documentation using standard markdown.  

Once committed to the main repository then the [Jekyll](https://jekyllrb.com/docs/github-pages/) engine takes the markdown and then renders it as the static HTML you see on [Azure Citadel](https://aka.ms/citadel).

These instructions have assumed Windows 10, but the workflow is also applicable to MacOS or Linux.  

## Content

The content is split into four main areas:

**Folder** | **Description**
/demos | Instructions for demos used to show functionality of Azure services  
/guides | Tech Primers for supporting technologies
/labs | Guided hands-on Azure labs, usually ranging from 15-120 minutes
/workshops | Full or multi-day sessions, often including multiples labs

This guide will assume that you are creating new lab content, rather than making changes to how Jekyll can be configured to render the pages differently.

## Structure

There are no enforced rules, but here are some examples:

### Single page

```
/labs
├── cosmosdb.md
└── cosmosdb/
    └── images/
        ├── cosmosDBImage.png
        └── cosmosVideo.mp4
```

There is no requirement for the /labs/cosmosdb and /labs/cosmosdb/images folders if you are using a single markdown page with no images.

### Multi-page with additional file(s)

```
/labs
├── containers.md
└── containers/
    ├── acs.md                  
    ├── aci.md
    ├── aks.md
    ├── containersOnAzure.pptx
    ├── vms.md
    ├── webapps.md
    └── images/
        ├── aksImage.png
        ├── aksImage2.png
        ├── webapp.png
        └── aciVideo.mp4
```

Note that in the second example the /labs/containers page will usually be just a description of the lab with a list of prereqs and an index of the sub-pages.

Sometimes the contributors have content on separate blog sites or GitHub repos, and the single page is used as a link to that external content.

Feel free to explore the existing files to see how they are named and structured.

## Front Matter

The [Front Matter](https://jekyllrb.com/docs/frontmatter/) is the small section of YAML at the start of the articles.  Here is the Front Matter for this file:

```yaml
---
layout: article
title: Contributing to Azure Citadel
date: 2018-01-08
categories: guides
tags: [citadel, markdown, git, github, jekyll]
comments: true
author: Richard_Cheney
image:
  teaser: cloud-tools.png
excerpt: Want to contribute content to Azure Citadel?  Read our guide. 
---
```

Here is a quick rundown of the properties:

Property | Description
layout | The type of HTML layout to be used - leave as article
title | The H1 header used at the top of the page
date | The article date. If set to a future date then the page will not be rendered until that date is reached.
categories | These dictate the landing page that the article appears on.  Choose from workshops, demos, labs, guides or videos.
tags | A list (or array) or tags to be used in searches.  (Search is not yet implemented.) 
author | Key for the /_data/authors.yml file.  You will need a section in here and a mugshot in /images/authors.
image: | Three image sizes can be used - feature, teaser and logo.  You only need to specify teaser for the picture used on the grid landing pages, and these images will be located in /images.
excerpt: | This is the brief descriptive text shown under the teaser image and title on the landing pages

The easiest thing to do is to copy one of the existing articles as a starting point.

You can also prevent your articles being published by setting `published: false`.  And if you are doing a series of linked pages, then there is some additional Front Matter that you can use to add in to manually set previous and next links at the bottom of the pages.  See the /workshops/arm/*.md files. 

Finally, you will also see some articles using small pieces of Liquid text, denoted by curly braces and percentage signs.  The most common example is ```{% include toc.html %}```, which will automatically insert a table of contents.    

## Markdown

Markdown is an internet standard designed to be very simple to use when creating internet documentation.

There are plenty of excellent guides [online](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet), but here are some of the common markdowns:

* \# Heading 1
* \#\# Heading 2
* \#\#\# Heading 3
* \*\*Bold\*\*
* \_Italics\_ 
* \[Link Description\](http://www.webaddress.com/webpage)
* \!\[Image Description\]
(/labs/cosmosdb/images/cosmosDBImage.png)
* Inline \`code\` box, e.g. `command --switch parameters`
* Multi-line code box:

```bash
```                                                                                                   <- Opening triple backticks
az group create --name myRG --location westeurope
az group deployment create --name job1 --resource-group myRG --template-file azuredeploy.json
```                                                                                                   <- Closing triple backticks
```

Note that the images for your individual article are usually stored alongside, i.e. the /labs/cosmosdb.md file uses images in /labs/cosmosdb/images/. 

The system also supports syntax highlighting for a number of languages.  You can add the language or format name (i.e. html, bash, powershell, json) immediately after the opening triple backticks.  If supported then the Rouge plugin will apply colour highlighting based on the syntax.

Tables can also be used, using vertical pipes between the columns.

The markdown format also allows html tags to be inserted, so these can be used to open links in new tabs, or to loop videos.

## GitHub Workflow

The diagram below show the overall flow we follow with GitHub.  Most contributors do not have write access to the main azurecitadel copy of the repo, so the process makes a fork of that under your own ID, so that you can then clone that version locally and work on new content.  Once you want to save that content it can then be committed and pushed back up to your fork.

If you then want to make those changes active on the main website then subnmit a pull request and one of the admins wil then merge the changes into the main repo.  

Jekyll then regenerates the static HTML site and your changes will be live on [Azure Citadel](https://aka.ms/citadel). 

![Git Workflow](/guides/citadel/images/gitWorkflow.png)

> These workflow steps need to be tested. Note that the recommended workflows introduce branches and privatee repositories (PRs), but this is a level of complexity that is not required for the repo whilst the number of contributors and rate of change are both low.

### 1. Fork the repo

You will need to create your own [GitHub](https://github.com/join) ID if you do not already have one.

1. Go to https://github.com/AZURECITADEL/azurecitadel.github.io
1. Click on the **fork** button at the top right of the screen 
    * You will now have your working copy of the master repo in GitHub: `https://github.com/yourGitHubId/azurecitadel.github.io`
1. Copy the URL in the address bar (CTRL-L, CTRL-C)

### 2. Clone within vscode

You will need to have met the core [vscode prereqs](/guides/vscode) to be able to upload:
* Visual Studio Code
* Git
* Bash on Ubuntu configured as the Integrated Console

You can then clone the repository:
1. Open vscode
1. Open the Command Palette (CTRL-SHIFT-P)
1. Type `git clone`
    1. Paste in the URL for your fork of the repo
    1. Choose which local directory will be used (defaults to C:\Users\<windowsID>)

> Before working on files, it is always a good idea to pull down any updates in the upstream.   Either select Pull from the ellipsis (**...**) in the SCM screen (CTRL-SHIFT-G), or click on the sync button (![sync](/guides/citadel/images/sync.png)) at the bottom left of vscode. (Note that a resysnc does the same but also pushes up from your side.)

### 3. Add azurecitadel as the upstream

If you run `git remote -v` in the integrated terminal then you'll see your GitHub fork as the 'origin'.  You'll need to add azurecitadel as your upstream to request your changes to be pulled into the main repo later.

Run the following in the integrated console: 
1. `git remote add upstream http://github.com/azurecitadel/azurecitadel.github.io`
2. `git remote -v`

You now have both the origin (to your fork) and the upstream (to the azurecitadel repo itself).

### 4. Run Jekyll locally

It is highly recommended to also locally install Jekyll within Bash on Ubuntu 
* Note that your version of Ruby should be no newer than 2.4
* Install [Jekyll](https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/) locally

Once installed then you can run Jekyll as a local process.  As you make changes then the static HTML files will be regenerated locally and you can view them in the browser.
1.  cd to the local repo directory
    * `cd /mnt/c/Users/userid/azurecitadel.github.io`
2.  run Jekyll
    * `bundler exec jekyll serve --config _config.yml,_config_local.yml --incremental --unpublished --future`
    * if you get a timezone error on Windows then add the following line to your Gemfile
    `a.	gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]`(for 64 bit Ruby - see the [tzinfo help page](http://tzinfo.github.io/datasourcenotfound) for other versions
3.  Open https://localhost:4000
    * Note that some of the landing pages do not update locally if you have previously generated, e.g. https://localhost:4000/labs/
    * You can fully path to a lab or guide within a section e.g. https://localhost:4000/guides/citadel  
    * Or you can remove the _site directory (which should be greyed out), and the `jekyll serve` will regenerate it correctly
    * Or you can remove the --incremental switch to do a full regeneration each time rather than the faster partial regen

>It is useful to have an alias in your Bash profile to run this quickly:
>```bash
>echo "alias jk='cd /mnt/c/Users/yourId/azurecitadel.github.io; bundler exec jekyll serve --config _config.yml,_config_local.yml --incremental --unpublished --future'" >> ~/.bashrc
>```
>You can then type `jk` to kick off the local Jekyll process.

This will allow you to view your content locally by refreshing the browser as you make and save changes.  
w
### 5. Stage and commit and push your changes to GitHub

Once you are happy with the new content then you can stage and commit them to the local copy of the repo:
* Stage your changed files
    * Go to the Git (SCM) pane (CTRL-SHIFT-G)
    * Click the **+** icon on the changes line to stage the modified files
* Commit the staged files
    * Type in a message to describe your changes
    * Click on CTRL+Enter to commit (or select Commit Staged from the ellipsis (**...**))

### 6. Push the commit up to your fork

Push those commited changes up to your GitHub repo:
* Select Push from the SCM ellipsis, or
* Click on the sync button (![sync](/guides/citadel/images/sync.png))

### 7. Make a pull request

Once you have changes that you would like to see added to the main repo then 
1. Open <a href="https://github.com/" target="_blank">GitHub</a>
1. Navigate to azurecitadel.github.io in the list of your repositories
1. Click on the Pull Request button

The admins for the main Azure Citadel repo will then receive the pull request, review the additions / changes and will then approve.  If there are issues then they may request modifications before repeating the loop.

Once approved, the Jekyll engine will rebuild the static HTML site and your page(s) will go live.