---
layout: archive
permalink: /videos/
title: "Videos"
---

<div class="tiles">
	{% assign sorted_pages = site.pages | sort:"date" | reverse %}
	{% for page in sorted_pages %}
		{% if page.categories == "videos" %}
			{% include page-grid.html %}
		{% endif %} 
	{% endfor %}
</div>