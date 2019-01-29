---
title: Adding Authors
date: 2019-01-18
author: Richard Cheney
comments: true
hidden: true
published: true
permalink: /contributing/authors/
header:
  overlay_image: /images/site/main.png
excerpt: How to add yourself as a new author on the site.
sidebar:
  nav: "contributing"
---

# Image

First things first.  You will need an image of yourself.  The image may be png or jpg, and **must** be square. Size is less important, but aim for a sensible resolution.  Nothing pixellated or an unnecessarily high resolution.

The author pictures should be placed in `/images/authors/`.

# Author info

Author info is added as a section in the YAML file `/_data/authors.yml`.

Copy the example block and then customise:

```yaml
Dave Placeholder:
    name     : Dave Placeholder
    bio      : Goat Herder.<br/>Cheese, goats cheese, other types of cheese, mostly cheese
    avatar   : images/authors/dave.jpg
    email    : dave.placeholder@microsoft.com
    twitter  : Coffee_Dad
    github   : monsieurfromage
    linkedin : daveplaceholder
    links:
      - label: "Blogsite"
        icon : "fas fa-fw fa-link"
        url  : "http://monsieurfromageblog.com"
```

Indentation is important with YAML.

Note that you can incorporate multiple website links. Just repeat the three lines and customise. The icon uses the free [Font Awesome 5](https://www.w3schools.com/icons/fontawesome5_intro.asp) set if you want to use something other than the link icon.  Only link to blog sites particular to the author, rather than general company sites.

[◄ Cloning](../cloning){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Content ►](../content){: .btn .btn--primary}