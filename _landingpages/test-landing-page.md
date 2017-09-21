---
layout: archive
permalink: /test/
title: "Test Page"
---
IGNORE THIS. TESTING :)
<ul>
  {% for page in site.pages %}
    <li><a href="{{ page.url }}">CAT:{{ page.categories  }} - TITLE:{{ page.title }}</a></li>
  {% endfor %} 
</ul>


