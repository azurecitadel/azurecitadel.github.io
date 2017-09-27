---
layout: archive
permalink: /demos/
title: "Demos"
---

<div class="tiles">
{% for page in site.pages  %}
	{% if page.categories == "demos" %}
	   {% include page-grid.html %}
	{% endif %} 
{% endfor %}
</div>
