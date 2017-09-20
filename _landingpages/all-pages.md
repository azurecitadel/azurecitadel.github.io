---
layout: archive
permalink: /all/
title: "All Pages"
---

<ul>
  {% for page in site.pages %}
    <li><a href="{{ page.url }}">CAT:{{ page.categories  }} - TITLE:{{ page.title }}</a></li>
  {% endfor %} 
</ul>


