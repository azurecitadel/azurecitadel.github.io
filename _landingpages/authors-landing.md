---
layout: archive
permalink: /contrib
title: "Contributors"
---

<div class="tiles">
   {% for auth in site.data.authors %}
      {% if auth[1].email != 'ignore@microsoft.com' %}
         <div class="tile"> 
            <h4>{{ auth[1].name }}</h4>
            {% if auth[1].avatar %}
            <img src="{{ site.url }}/images/{{ auth[1].avatar }}" width="120px"/>
            {% else %}
            <img src="{{ site.url }}/images/bio-photo.jpg" width="120px"/>
            {% endif %}
         </div>
      {% endif %}
   {% endfor %}
</div>