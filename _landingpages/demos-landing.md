---
layout: archive
permalink: /demos/
title: "Demos"
---

<div class="tiles">
	{% assign sorted_pages = site.pages | sort:"date" | reverse %}
	{% for page in sorted_pages %}
		{% if page.categories == "demos" %}
			{% include page-grid.html %}
		{% endif %} 
	{% endfor %}
</div>
