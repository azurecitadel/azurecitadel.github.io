---
title: Configuring the Front Matter
date: 2019-01-18
author: Richard Cheney
comments: true
hidden: true
published: true
permalink: /contributing/frontmatter/
header:
  overlay_image: /images/site/main.png
excerpt: The Front Matter section configures your page in the site. Here's a quick guide.
sidebar:
  nav: "contributing"
---

# Front Matter

The Jekyll software makes use of Front Matter when generating the static HTML. This is the section at the top of the markdown files that starts and finishes with three hyphens.

## Example

Here is the Front Matter for this Contributing guide's main page:

```yaml
---
title: Contributing to Azure Citadel
date: 2019-01-10
author: Richard Cheney
tags: [citadel, markdown]
comments: true
header:
  overlay_image: /images/site/main.png
  teaser: /images/teaser/cloud-tools.png
excerpt: Want to contribute content to Azure Citadel?  Read our guide.
hidden: true
published: true
sidebar:
  nav: "contributing"
permalink: /contributing/
---
```

## Defaults

There are a number of [defaults](https://mmistakes.github.io/minimal-mistakes/docs/configuration/#front-matter-defaults) that can be seen in the [_config.yml](https://raw.githubusercontent.com/azurecitadel/azurecitadel.github.io/master/_config.yml) file.

Key defaults for the pages:

**Key** | **Default** | **Type** | **Description**
read_time | true | boolean | Estimates the time to read, based on 100 words per minute
share | true | boolean | Show the "Share On" buttons for Twitter, Facebook and LinkedIn
comments | true | boolean | Whether to allow Disqus comments at the bottom of the page
toc | true | boolean | Show the table of contents on the right
toc_sticky | true | boolean | Keep the table of contents visible after  scrolling
toc_depth | 2 | integer | Number of header levels to include in the table of contents

## Categories

Normally your Front Matter will also include a **category**.  This should be a single value matching the directory, e.g. a file called `/devops/my-guide.md` would have `category: devops`, and therefore appear in the DevOps category page.

Jekyll will take that my-guide.md and generate a page available at `https://azurecitadel.com/devops/my-guide`. (It actually creates an index.html within the my-guide folder in order to provide this "pretty" link.)

Permalinks can also be used to hardcode the generated pathing.  In general, the use of **permalink** in pull requests will be discouraged. (These Contributing files are an exception as the generated pages are within `https://azurecitadel.com/contributing/` but they are located in `/prereqs`.)

You cannot use the older **categories** array, which used to allow content in multiple categories.

## Titles, excerpts and banner images

The **title** will go across the banner, which is plain blue by default.

You can customise the image by using the **header:overlay_image** and then path to one of the larger images in either /images/site or /images/header.  If you wish to add your own then it should go into /images/header.  Check the [readme](https://github.com/azurecitadel/azurecitadel.github.io/blob/master/images/header/README.md) file for current guidance on the image files.

If you specify an **excerpt** then this will be the additional text that goes across the page header underneath the title.

## Dates

The **date** field is pretty self explanatory, and always required.

Note that the date is used on the grid pages to determine order, but the date should not be updated to "bump" content up when there are only minor changes or fixes.  Only change the date if there is a significant content update.  We will normally use this to dictate if there should be a news post update, so if it isn't newsworthy, it should retain the original date.

Note that future dates are permitted.  This can be useful to release content at the same time as a service goes GA.

If you are running Jekyll locally on your machine (see [reviewing](../reviewing)), then you can use the `--future` switch to generate the content locally for reviewing purposes.

## Tags

Specify **tags** as an array.  No more than four tags are allowed. Keep to lower case and hyphenate where there are multiple words, e.g. cognitive-services.

Check the [Tags page](aka.ms/customerusageattribution) and use existing tags where possible. New tags will be inevitable, but if there is an existing synonym then use that. E.g. use security-center, rather than creating azure-security-center or security-centre.

Please do not use tags that are already in the title of the lab as that will already be included in the search.

## Publishing

The following are not required but can be used to control visibility:

```yaml
published: true
hidden: false
```

Use **published** to control whether the page will be generated on the main site. This is useful for controlling the release of work in progress content.

You can use the `--unpublished` switch when running Jekyll locally to see content that has `published: false` set.

The **hidden** boolean dictates whether content will be listed on a category page. The markdown file for the contributing main page is `/prereqs/contributing.md`, and would normally show in the pre-reqs category.

## Teaser

The **header:teaser:** value should path to a valid teaser image within /images/teaser.  These are the smaller images used on the main page and the category pages.

Check the [readme](https://github.com/azurecitadel/azurecitadel.github.io/blob/master/images/teaser/README.md) file for current guidance on the images.

## Custom navigation

You can create custom navigation to go across multiple pages and external links.  These pages have one on the left, denoted by:

```yaml
sidebar:
  nav: "contributing"
```

More on these when you get to [multi page labs](../multipage).

In the meantime, here is a quick guide to markdown.

[◄ Single Page](../singlepage){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Markdown ►](../markdown){: .btn .btn--primary}
