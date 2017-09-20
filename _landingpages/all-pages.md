---
layout: archive
permalink: /all/
title: "All Pages"
---

<div class="tiles">
{% for post in site.categories %}
	{{ post.date }}
{% endfor %}
</div>
<!-- /.tiles -->