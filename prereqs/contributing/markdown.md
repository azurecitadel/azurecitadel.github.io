---
title: Markdown
date: 2019-01-18
author: Richard Cheney
comments: true
hidden: true
published: true
permalink: /contributing/markdown/
header:
  overlay_image: /images/site/main.png
excerpt: This guide will show you the basics of using markdown.  And some html tricks to use outside of standard markdown support.
sidebar:
  nav: "contributing"
---

# Introduction

Markdown is an internet standard designed to be very simple to use when creating internet documentation.

There are plenty of excellent guides [online](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).

If you are using Visual Studio Code to author, then `CTRL`+`SPACE` should bring up the markdown language basics.

## Headers

Use leading hashes for headers, up to Header 9. Always have an empty line after a header.

```markdown
# Heading 1

## Heading 2

### Heading 3
```

Here is how those headers will look:

-----------------------

# Heading 1

## Heading 2

### Heading 3

-----------------------

Note that the table of contents on the right will include headers up to level 2. You can modify this behaviour to include the level 3 headers by using `toc_depth: 3` in the Front Matter.

## Formatting

Use either asterisks or underscores to format text.

```markdown
Use double asterisks for **bold** text.
And single asterisks for *italicised* text.
```

Use double asterisks for **bold** text.
And single asterisks for *italicised* text.

Note that the two lines formed one paragraph.  If you want separate paragraphs then you would need a blank line between the two lines.

## Links

Links use the following format.

```markdown
This is the [Azure Citadel](http://azurecitadel.com) site.
```

This is the [Azure Citadel](http://azurecitadel.com) site.

Bare urls should strictly be surrounded by angled braces, e.g. `<https://azurecitadel.com>` would show as <https://azurecitadel.com>.

The format for absolute links within the site context is `[Kubernetes](/cloud-native/kubernetes)`.

Use relative links to descend into a sub-page, e.g. `[Module 1 - Deploying Kubernetes](part1)` and to go to a sibling page e.g. `Now go to [module 2](../part2) to continue.`.

You can also link to header sections within a lab as anchor ids are generated for you. Example links to sections of this page are `[images](#images)` or `[inline code](/contributing/markdown#inline-code)`. The text after the # must be the exact header text in lowercase, any punctuation will be dropped, and multiple words should be hyphenated such as the inline code example.

> Please remove the localisation for links to the Azure Docs area.  For example, do not use `[Linux VMs](https://docs.microsoft.com/en-gb/azure/virtual-machines/linux/)`, instead use `[Linux VMs](https://docs.microsoft.com/azure/virtual-machines/linux/)`. We get traffic from around the world, so removing `en-us` or `en-gb` will redirect to the localisation page for that user if localisation is available. Don't forget to test any manually edited links before committing!

## Images

Images use the following format.

```markdown
![Application Architecture](/cloud-native/kubernetes/images/arch.png)
```

![Application Architecture](/cloud-native/kubernetes/images/arch.png)

The text in the square braces is the alt text for the image.

Note that the images for your individual article are usually stored alongside your main markdown page, i.e. the /cloud-native/kubernetes.md file uses images in /cloud-native/kubernetes/images/.

## Inline code

Use single backticks to show commands in the middle of a paragraph.

```markdown
Use the command `ls -Al` to list the files in the current working directory.
```

Use the command `ls -Al` to list the files in the current working directory.

## Code blocks

Code blocks are opened and closed with triple backticks. The system also supports syntax highlighting in the code blocks for a number of languages.  You can add the language or format name (i.e. html, bash, powershell, yaml, json) immediately after the opening triple backticks.  If supported then the Rouge plugin will apply colour highlighting based on the syntax.

````markdown
```yaml
Dan Baker:
    name     : Azure Dan
    bio      : Dan Baker (aka Azure Dan) is the UK Azure regional skills evangelist
    avatar   : images/authors/dan-b.jpg
    email    : dan.baker@microsoft.com
    twitter  : azuredan
    github   :
    linkedin :
```
````

```yaml
Dan Baker:
    name     : Azure Dan
    bio      : Dan Baker (aka Azure Dan) is the UK Azure regional skills evangelist
    avatar   : images/authors/dan-b.jpg
    email    : dan.baker@microsoft.com
    twitter  : azuredan
    github   :
    linkedin :
```

{% raw %}

> Note that Jekyll also uses [Liquid](https://jekyllrb.com/docs/liquid/) to process templates.  This guide will not go into that in any great detail but feel free to read around.  SomeLiquid uses double curly braces.  If you find this conflicts (such as with Packer) then make use of the [{% raw %}](https://shopify.github.io/liquid/tags/raw/) controls.  This note does exactly that!

{% endraw %}

## Tables

Tables are officially outside of the markdown standard but are supported by Jekyll.  Use vertical pipes between the columns.

```text
**Name** | **Description**
Front Matter | Jekyll specific controls at the top of a file
Markdown | Simple documentation standard that is converted to generated HTTP markup
```

**Name** | **Description**
Front Matter | Jekyll specific controls at the top of a file
Markdown | Simple documentation standard that is converted to generated HTTP markup

Note the use of asterisks to make the headers bold.

## HTML

Jekyll also allows HTML to be included in the files. This is useful for including embedded items such as YouTube videos as an iframe. For example:

```html
<iframe width="560" height="315" src="https://www.youtube.com/embed/ePxAH5YBKP4?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
```

> Note the use of `?rel=0` after the generated URI. With YouTube you can no longer stop it from showing suggested videos once the video has finished, but adding `?rel=0` does mean that the suggested videos only come from that channel.

<iframe width="560" height="315" src="https://www.youtube.com/embed/ePxAH5YBKP4?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

The buttons at the bottom of the page use HTML classes. For example the button below to go back to the Front Matter page is `[◄ Front Matter](../frontmatter){: .btn .btn--inverse}`.

Note that standard HTML files can also be included with a standard .html extension, and are used as is without additional processing by Jekyll.

[◄ Front Matter](../frontmatter){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Multi Page ►](../multipage){: .btn .btn--primary}
