---
layout: archive
permalink: /videos/
title: "Videos"
---

<div class="tiles">
	{% for page in site.pages  %}
		{% if page.categories == "videos" %}
			{% include page-grid.html %}
		{% endif %} 
	{% endfor %}
</div>