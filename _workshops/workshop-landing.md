---
layout: category
permalink: /workshops/
title: "Workshops"
---

<div class="tiles">
{% for post in site.categories.workshops %}
 <li><span>{{ post.date | date_to_string }}</span> &nbsp; <a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</div><!-- /.tiles -->