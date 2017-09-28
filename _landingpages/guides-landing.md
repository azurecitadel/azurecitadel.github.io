---
layout: archive
permalink: /guides/
title: "Guides"
---

<div class="tiles">
{% for page in site.pages  %}
	{% if page.categories == "guides" %}
	   {% include page-grid.html %}
	{% endif %} 
{% endfor %}
</div><!-- /.tiles -->