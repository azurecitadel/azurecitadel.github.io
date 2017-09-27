![banner](images/AzureCitadelBanner.png)

# OCP CSA Site - aka Azure Citadel
This is the Github repo for the site, which is based on Jekyll and the [Skinny Bones](https://github.com/mmistakes/skinny-bones-jekyll) theme. Do not link to this page but to the published site!

### The site is published here - [https://azurecitadel.github.io/](https://azurecitadel.github.io/)

# Contributing Guidelines
There are four main locations for content (pages)
- demos
- labs
- workshops
- guides

These exist as folders at the top level of this repo and for each folder, pages within should be assigned a **single** matching category in their front matter

Example of some content in the labs section, for a page called cheese-lab.
```
labs/
 ├── cheese-lab.md
 ├── cheese-lab/
     ├── prepguide.md
     ├── images/
         ├── cheddar.jpg
```
This will create a new URL on the site under the labs top level e.g. `https://azurecitadel.github.io/labs/cheese-lab/` (Note the .md is not included)
This top level page should have a category set in the front matter e.g. `categories: labs` 

**IMPORTANT!** Placing a category on page means it will be picked up by the auto-indexing landing pages (one for each of the categories)

Any sub-pages are placed in a sub folder with the **same name** as the .md. These sub pages **should not** have category assigned (so they don't show up on the auto index) you link to these from the parent .md  
In this example the prepguide sub-page would be linked to from the main page as follows: `[Prep Guide][./prepguide]`
and has the following full URL `https://azurecitadel.github.io/labs/cheese-lab/prepguide/`


### Disclaimer Boilerplate
This is suggested boilerplate to add to pages for demos, apps or labs


#### Disclaimer
The information contained here was correct and validated at the time of publishing. Azure and other Microsoft cloud services are subject to rapid change and development. Reasonable efforts are made to keep the technical details here (links, commands, names etc) up to date but they may drift out of sync.  

Any code published here should be considered POC quality only, and exists to demonstrate technical principals rather than representing any best practice or production grade code

