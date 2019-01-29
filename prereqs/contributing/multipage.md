---
title: Multi Page Content
date: 2019-01-18
author: Richard Cheney
comments: true
hidden: true
published: true
permalink: /contributing/multipage/
header:
  overlay_image: /images/site/main.png
excerpt: Larger content is easier to navigate when you have multiple pages, especially when you add custom navigation.
sidebar:
  nav: "contributing"
---

# Multi page content

## Introduction

Much of the content you'll find on Citadel will exist on only one page, but some of the deeper content more naturally fits a multi page format.  Some of the most popular content on the site are the deeper labs.

This guide will cover

* how to structure content across multiple pages
* how to link to images
* how to link to other pages
* how to create navigation buttons at the end of each pages
* how to create custom navigation

To make life easier, there is a multi-page template (in /templates). Feel free to copy this as a starting point.

This guide will use the Terraform lab as a reference.

## Structure

The Terraform lab is in `/automation`:

```text
📁automation/
 ├── terraform.md
 └── 📁terraform/
     ├── createTerraformBackend.sh
     ├── createTerraformServicePrincipal.sh
     ├── lab1.md
     ├── lab2.md
     ├── lab3.md
     ├──   :
     ├── lab9.md
     ├── terraform.vsdx
     └── 📁images/
         ├── accessControl.png
         ├── clouddrive-terraform.tfstate.png
         ├── dashboard.png
         ├──   :
         └── webappsperloc.png

```

**💬 Note.** Only selected files have been shown.

The main page is /automation/terraform.md.  This includes an overview of the lab, a set of pre-requisites (linking to external guides and those in the /prereqs area) and in index of the various labs.

The additional files are in the /automation/terraform folder. This contains all of the individual lab files. Note that small additional files such as these shell scripts and Office files can also be included here. Having said that, we aim to keep the size of the site as low as possible.  Larger lab specific content should be held in a separate repository and linked to from within the markdown documents.

## Linking to images

Images are always kept within the images subfolder. It is recommended to absolutely path them, e.g. `![Dashboard](/automation/terraform/images/dashboard.png)`.

## Linking to other labs

The safest way is to always use absolute paths, e.g.

* `[Main Page](/automation/terraform)`
* `[Lab One](/automation/terraform/lab1)`
* `[Lab Two](/automation/terraform/lab2)`

You can also relatively path.  If you were in the main page then you could link to `[Lab One](lab1)`.  From lab one you could link to `[Lab Two](../lab2)`. And from there you could go back up using `[Main Page](..)`.

It is best to think of the pathing in terms of the pretty links enabled once the HTML pages have been generated.

Generated files:

```text
📁_site/
 └── 📁automation/
     └── 📁terraform/
         ├── index.html
         └── 📁lab1/
             └── index.html
         └── 📁lab2/
             └── index.html
```

Pretty links:

* <https://azurecitadel.com/automation/terraform>
* <https://azurecitadel.com/automation/terraform/lab1>
* <https://azurecitadel.com/automation/terraform/lab2>

## Navigation buttons

These are entirely optional, but can be very useful.  The markdown for the buttons as the bottom of the page are:

```markdown
[◄ Markdown](../markdown){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Reviewing ►](../reviewing){: .btn .btn--primary}
```

The links use a combination of relative links and header anchor id links. It is a little manual to get it set up, and when reviewing it is important to test out the button navigation.

The supported button colours can be found in the /_sass/minimal-mistakes/_buttons.scss file.

## Custom navigation

All of the Terraform lab pages have the following Front Matter:

```yaml
sidebar:
  nav: "terraform"
```

This lets Jekyll know to look in the **_data/navigation.yml** file to find the custom navigation definition. Here is the terraform definition:

```yaml
terraform:
  - title: "Main Page"
    url: "automation/terraform"

  - title: "Labs"
    children:
    - title: "Basics"
      url: "automation/terraform/lab1"
    - title: "Variables"
      url: "automation/terraform/lab2"
    - title: "Core Environment"
      url: "automation/terraform/lab3"
    - title: "Meta Parameters"
      url: "automation/terraform/lab4"
    - title: "Multi Tenancy"
      url: "automation/terraform/lab5"
    - title: "State"
      url: "automation/terraform/lab6"
    - title: "Modules"
      url: "automation/terraform/lab7"
    - title: "Extending beyond ARM"
      url: "automation/terraform/lab8"
```

The first level name must match that used in the Front Matter.  You can then have multiple sections, with the hyphens bulleting each row with both title and url. ANd you can create a hierarchy using `children`. Browse the file for other examples.

[◄ Markdown](../markdown){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Reviewing ►](../reviewing){: .btn .btn--primary}
