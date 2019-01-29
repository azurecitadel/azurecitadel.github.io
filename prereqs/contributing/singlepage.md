---
title: Single Page Content
date: 2019-01-18
author: Richard Cheney
comments: true
hidden: true
published: true
permalink: /contributing/singlepage/
header:
  overlay_image: /images/site/main.png
excerpt: Recommended configuration and template for single page content.
sidebar:
  nav: "contributing"
---

# Organising files

Here is a fictional cheese lab in the IOT category.

```text
📁iot/
 ├── cheese-lab.md
 └── 📁cheese-lab/
     ├── prepguide.md
     └── 📁images/
         ├── camembert.png
         ├── cheddar.png
         ├── roquefort.png
         └── stilton.png
```

The main page is `/iot/cheese-lab.md`. Jekyll will render this as `https://azurecitadel.com/iot/cheese-lab/index.html`, and you'll be able to reach it at `https://azurecitadel.com/iot/cheese-lab`.

If you have no screenshots or other linked content, then this is the only file that you need. This is a common approach for those who have their own repositories.  (Also if the linked content is not within the Citadel repo.) For a good example, see Ben's [Demo Web Apps](/web/demo-apps) page, which is generated from the `/web/demo-apps.md` file.

# Additional files

If you need to host additional content then you'll need to create a folder with the same name, e.g. `/iot/cheese-lab`. To link to the example prep guide, either link absolutely using `/iot/cheese-lab/prepguide`, or relatively using `./prepguide`. To link back from the prepguide to the main cheese lab, the link would be `/iot/cheese-lab/` or just `..` to go up one level.

Images that are only used within the lab (such as screenshots) should be placed in an images folder within the lab specific folder, so the links to the stilton file would be `/iot/cheese-lab/images/stilton.png` or `images/stilton.png`.

# Template

Take a look at the **/templates** folder for an example single page template.  You can copy this for use.  At the top of the template you'll see a Front Matter section followed by some useful reminders.

The next page will go through how to configure the Front Matter.

[◄ Content](../content){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse} [Front Matter ►](../frontmatter){: .btn .btn--primary}
