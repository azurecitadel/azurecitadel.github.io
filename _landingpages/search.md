---
layout: archive
permalink: /search/
title: "Site Search"
---

<script>
function preSubmit() {
	document.getElementById('q').value = document.getElementById('term').value + " site:azurecitadel.github.io"
}
</script>

<h3>Powered by <img style="width:150px" src="https://www.underconsideration.com/brandnew/archives/bing_2016_logo.png"/></h3>
<form action="https://www.bing.com/search" method="GET">
  <input type="text" name="term" id="term">
  <input type="hidden" name="q" id="q" value="">
  <button type="submit" onclick="preSubmit()">SEARCH</button>
</form>

