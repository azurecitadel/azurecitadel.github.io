---
layout: archive
permalink: /workshops/
title: "Workshops"
---

<div class="tiles">
	{% assign sorted_pages = site.pages | sort:"date" | reverse %}
	{% for page in sorted_pages %}
		{% if page.categories == "workshops" %}
			{% include page-grid.html %}
		{% endif %} 
	{% endfor %}
</div>
