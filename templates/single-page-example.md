---
title: Title Of Your Content
author: Your Name
date: YYYY-MM-DD
tags: [tag1, tag2, tag3, tag4]
category: changeme
header:
  teaser: images/teaser/example.png
  overlay_image: images/teaser/example.png
excerpt: Keep this fairly short, no more than two or three sentences
---

## Remove From Here...

Remove everything from this template (below the `---` line above) when you are ready to use it

## Introduction

Note. There is no point making the first heading in your page the same as the title. The title will be shown as part of the page banner header, it just wastes space having it repeated here

## Category

Content can ***only have a single category***, which ***must match the site directory*** it is placed in,
e.g. `category: devops` must go into folder e.g. `/devops/my-guide.md`

Available categories

- `automation`
- `cloud-native`
- `data-ai`
- `devops`
- `fundamentals`
- `infra`
- `iot`
- `prereqs`
- `security`
- `web`

## Teaser & Overlay Images

Both of these are specified under the `header:` in the front-matter

The `teaser` image is shown as a thumbnail when listing your content on the category or other views. It is suggested you use one one of the existing images located in `/images/teaser`. If you are adding your own teaser image please ***make sure it is sized 800x480 and is in PNG format***
If omitted a default placeholder image will be used

The `overlay_image` is optional and shown on the banner of the page, behind the title and excerpt test. If omitted then a simple plain Azure blue background is used. It is suggested you use one one of the existing images located in `/images/header`. If you are adding your own teaser image please ***make sure it is sized at least 1600 pixels wide, and is cropped/sized for a narrow field of view, 1600x900 is a good size. JPEG is recommended***

## Tags

Tags should be be all lower case, no spaces (hyphens only) and limited to a maximum of FOUR per post. Do not use tags that just duplicate the category such as "ai" or "data". People will mostly be looking for azure service names, so try to use those where possible. Check existing tags (<https://azurecitadel.com/tags/>) to make sure you're not unnecessarily introducing new tags, or tags for the same thing but with slightly different name (e.g. "azure-logicapp" vs "logicapp")

## Table of Contents

For very simple content which is pointing to another site or GitHub repo, you might not require the table of contents on the right hand side, you can disable it by placing the following the front-matter

```yaml
toc: false
```

# Including Images

Create a folder with the same name as your .md file, e.g. if you're working on cheese-lab.md create a folder called "cheese-lab". It's recommended to place a sub-folder in there named `images/` and place the image files in there

Then link to it relatively with normal Markdown syntax, e.g.

```md
![This is a picture](images/example.jpg)
```

![This is a picture](images/example.jpg)