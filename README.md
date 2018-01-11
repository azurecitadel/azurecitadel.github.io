![banner](images/banner.png)

# OCP CSA Site - aka Azure Citadel
This is the Github repo for the site, which is based on Jekyll and the [Skinny Bones](https://github.com/mmistakes/skinny-bones-jekyll) theme. Do not link to this page but to the published site!

Note. This is a **live site**, keep that in mind when creating content and submitting changes. See the section on "Drafts & WIP" when creating your content that is not finished.

### The site is published here - [https://azurecitadel.github.io/](https://azurecitadel.github.io/)

# Contributing Guidelines
There are five main locations for content (pages)
- demos
- labs
- workshops
- guides
- videos

These exist as folders at the top level of this repo and for each folder, pages within should be assigned a **single** matching category in their front matter

## Example
Example of some content in the labs section, for a page called cheese-lab.
```
📁labs/
 ├── cheese-lab.md
 └── 📁cheese-lab/
     ├── prepguide.md
     └── 📁images/
         └── cheddar.jpg
```
This will create a new URL on the site under the labs top level e.g. `https://azurecitadel.github.io/labs/cheese-lab/` (Note the .md is not included)
This top level page should have a category set in the front matter e.g. `categories: labs`. If the category set here doesn't match the folder the page is in, then the fabric of space time will warp and the entire site will disappear from existence (maybe)

**IMPORTANT NOTES!** 
- Placing a category on page means it will be picked up by the auto-indexing landing pages (one for each of the categories)
- Do not put more than one category in the `categories` list
- Do not put a permalink in your front-matter

Any sub-pages are placed in a sub folder with the **same name** as the .md. These sub pages **should not** have category assigned (so they don't show up on the auto index) you link to these from the parent .md  
In this example the prepguide sub-page would be linked to from the main page as follows: `[Prep Guide][./prepguide]`
and has the following full URL `https://azurecitadel.github.io/labs/cheese-lab/prepguide/`

## Images
Images specific for the content should be placed in an `images` sub-directory inside the sub-directory named after your main page. This makes linking to the images easy.

- On the parent page link as follows `![picture](./images/cheddar.jpg)`
- On sub-pages link like this `![picture](../images/cheddar.jpg)`


# Home Page
The content of the home page can be customised as follows

## Carousel 
The carousel is populated from pages that have `featured: true` set in their front matter. Simply adding that will make it appear. Three things are picked up by the carousel:
- Title.
- Text excerpt from the `excerpt` specified in the page front matter.
- The `feature` image, again specified in the page front matter. Note. In many cases this will be different from the `teaser` image which is used on the auto index pages

## Link Grid
The grid of icons and links is populated from [hometiles.yml in the data folder](_data/hometiles.yml). The format should be self explanatory

Further customization can be carried out, by modifying [home.html in the _layouts folder](_layouts/home.html)

# Drafts & WIP

#### *!REMEMBER THIS IS A LIVE PUBLIC SITE - PARTERS AND CUSTOMERS ARE LOOKING AT THESE PAGES!*
#### *Do not stick up test or half finished content, it makes the site look unprofessional*

- If you want to work on something and not have it published **at all**, then place it into `_drafts` folder
- If you want to work on something as a work in progress and have it published but hidden, put your page(s) into the `unpub` folder and **don't assign a category**. You can then view it on the site, but it will not appear under any of the sections


# Disclaimer Boilerplate
This is suggested boilerplate to add to pages for demos, apps or labs


### Disclaimer
The information contained here was correct and validated at the time of publishing. Azure and other Microsoft cloud services are subject to rapid change and development. Reasonable efforts are made to keep the technical details here (links, commands, names etc) up to date but they may drift out of sync.  

Any code published here should be considered POC quality only, and exists to demonstrate technical principals rather than representing any best practice or production grade code

