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

# Introduction
See `single-page-example.md` for general guidance and example for creating your content

# Multi Page Content
For larger more complex topics it's generally worth splitting across multiple sections and pages. Linkage and navigation between pages is currently the authors responsibility 

With multi page content you will have a "top level" master or main page, which links to the various subsections.  

Create a folder with the same name as your .md file, e.g. if you're working on cheese-guide.md create a folder called "cheese-guide"  
Place .md files for your sub-pages or sub-sections into this folder

E.g. if you have a file called `part-1.md` in your sub-folder, you can link to that page as follows, note you do not need the full path or .md extension

```md
[Go to Part 1](./part-1)
```

[Go to Part 1](./part-1)