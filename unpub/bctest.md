---
layout: article
title: Test
date: 2017-09-29
author: Ben_Coleman
---
<script src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/1.7.1/clipboard.min.js"></script>

# Clipboard.js Test Page

Summary...  
Not a good idea unless you like writing HTML and embedding scripts in the page


## Some HTML

```
<button class="btn" data-clipboard-target="code">
    <img src="assets/clippy.svg" alt="Copy to clipboard">
</button>
```
<button class="btn" data-clipboard-target="code">
Copy HTML to clipboard
</button>

## Some YAML
```
highlighter: rouge
plugins:
  - jekyll-sitemap
  - jekyll-gist
  - jekyll-feed

```
<button class="btn" data-clipboard-target="code">
Copy YAML to clipboard
</button>


<script>
  new Clipboard('.btn');
</script>
