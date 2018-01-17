---
layout: archive
permalink: /tags/
title: "All Content Tags"
---

<!-- THIS PAGE IS NO LONGER USED (BenC 17th Jan 2018) -->

{% assign rawtags = "" %}
{% for p in site.pages %}
	{% assign ttags = p.tags | join:'|' | append:'|' %}
	{% assign rawtags = rawtags | append:ttags %}
{% endfor %}

{% assign rawtags = rawtags | split:'|' | sort %}
{% for tag in rawtags %}
	{% if tag != "" %}
		{% if tags == "" %}
			{% assign tags = tag | split:'|' %}
		{% endif %}
		{% unless tags contains tag %}
			{% assign tags = tags | join:'|' | append:'|' | append:tag | split:'|' %}
		{% endunless %}
	{% endif %}
{% endfor %}

<ul>
	{% for tag in tags %}
		{% if tag != "" %}
		<li><a href="#{{ tag | slugify }}"> {{ tag }} </a></li>
		{% endif %}
	{% endfor %}
</ul>