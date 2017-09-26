---
layout: archive
permalink: /workshops/
title: "Workshops"
---

<div class="tiles">
{% for page in site.pages  %}
	{% if page.categories == "workshops" %}
	   {% include page-list.html %}
	{% endif %} 
{% endfor %}
</div>
