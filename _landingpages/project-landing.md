---
layout: archive
permalink: /projects/
title: "Projects and Demos"
---

<div class="tiles">
{% for post in site.categories.projects %}
	{% include post-list.html %}
{% endfor %}
</div>
<!-- /.tiles -->