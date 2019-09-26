---
title: "Azure Tips and Tricks"
author: "Richard Cheney"
published: true
excerpt: Ben Coleman's vscode extension - ARM Template Viewer
---

## ARM Template Viewer

You can normally tell when our very own Ben Coleman is going to pull something amazing out, as he goes a little bit radio silent for a couple of weeks.  This month he's done just that, and brought out a fabulous new extension for Visual Studio Code called ARM Template Viewer.

![screenshot](https://github.com/benc-uk/armview-vscode/raw/master/assets/readme/screen1.png)

The extension displays a graphical preview of Azure Resource Manager (ARM) templates. The view will show all resources with the official Azure icons and also linkage between the resources.  You can drag and move icons as you wish, zoom in and out with the mouse wheel and drag the canvas to pan around. Clicking on a resource will show a small infobox with extra details.

You can search on either `bencoleman.armview` or _'ARM Template Viewer'_ in the Extensions view (`CTRL`+`SHIFT`+`X`) to install. Or go to the [ARM Template Viewer](https://marketplace.visualstudio.com/items?itemName=bencoleman.armview) marketplace page and click on Install from there. Once installed then click on the eye symbol whenever your editor is focused on an ARM template.

Expect this to be added to the list of recommended extensions for the Creating ARM Templates labs. I plan to  refresh those labs with screen grabs in time, but I think I will wait for WSL2 to go GA, plus confirmation of some ARM enhancements such as zero count loops plus sections for the subscription level and management group level ARM templates.

Fantastic work on the extension Ben, and it is great to see the number of installs rising each day!