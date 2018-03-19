---
layout: article
title: Azure Node Bot Prerequisites
date: 2018-02-28
tags: [bot, node, team services]
comments: true
author: Matt_Biggs
image:
  feature: 
  teaser: 
  thumb: 
---

# Prerequisites

## Azure

You will need access to an Azure account, either your own subscription, MSDN or a free account.

If you are unsure, **login** at **portal.azure.com** to confirm access. If this is free trial account you should get a message to say how much credit is available, this won't need much at all.

Install locally:

- Azure Bot Framework Emulator - [https://emulator.botframework.com/](https://emulator.botframework.com/)
- Azure Storage Explorer – [https://azure.microsoft.com/en-us/features/storage-explorer/](https://azure.microsoft.com/en-us/features/storage-explorer/)

Setup of the above will be handled in the lab.

## Team Services - VSTS

[https://www.visualstudio.com/team-services/](https://www.visualstudio.com/team-services/)

Check access, click the **Sign in** link in the top right – if you have the Azure portal logged in, you should SSO in on the same browser.

If you do not have a Team Services account create one using your Microsoft Azure credentials.
You will be asked for a name to host your projects, **<something>.visualstudio.com** – this has to be globally unique, and will stay with you, so make a name to keep and not just something for this project.

**Select the options** :

- Manage code using: Git
- Region: West Europe

**Create a new project** for this Bot – call it &quot;citadelbot&quot;. Once you have the basic shell of the project, leave it and we&#39;ll come back to it in a little while.

Go to the **Azure portal** , click **All Services** and **search &quot;Team&quot;** , from there select _Team Services accounts_ and link to your VSTS account – if you have used Team Services previously, it will be setup. My account was in place when this service was released, so I do not have a walkthrough, but there is a link to a how to, if you get stuck.

## VS Code

[https://code.visualstudio.com/](https://code.visualstudio.com/)

Hopefully you have this already – it&#39;s a great, lightweight text editor, but if not, please install (for free) from the page above page – use the **Stable Build**.

**Open VS Code**. On left, vertical toolbar, select **Extensions** , the fourth icon from the top, install the following:

- Visual Studio Team Services
- Node.js Modules Intellisense

Click **CTRL-'** to open the terminal window. If the dropdown to the right does not read &#39;1: bash&#39; click on the **settings icon** , the cog, bottom left. In the right panel there are two options, USER SETTINGS and WORKPLACE SETTINGS, if you want Bash as your default for all projects use USER pane, if you just want Bash for this project use the WORKPLACE pane – you can start with WORKPLACE and change the USER settings later.

Enter the following between the brackets {} – if there is a line of code already, enter a comma at the end of that line.

```
\"terminal.integrated.shell.windows\": \"C:\\Program Files\\Git\\bin\\bash.exe\" 
```

## Node.js

[https://nodejs.org/en/](https://nodejs.org/en/)

This allows you to run Node locally – if you think you may have this already, skip the check below. If you need to install, use the link and select the **LTS version** (the more stable).

Check the install.

Open the Command Prompt – **type CMD in the W10 search box** , bottom left. In the terminal:

 `node --version`

Check the Node Package Manager (NPM) install:

 `npm --version`

Finally, install Nodemon:

 `npm install --g nodemon`

## Git

[https://git-scm.com/download/win](https://git-scm.com/download/win)
This if your local source repository.

Click through the default and ensure the following:

Choose &quot;Use Git from the Windows Command Prompt&quot;
Enable  &quot;Git Credential Manager&quot;

Check in CMD again:

 `git --version`

And set variables, to track changes – this is more relevant when working on joint projects – by typing:

 `git config --global user.email "alias@email.com"`

 `git config --global user.name "Your Name"`
   

## Cognitive Services

### QnA Maker

[https://qnamaker.ai](https://qnamaker.ai)
Go to the URL above and sing in using your **Azure account credentials** , or, if you have an account already, using those credentials.

If you do not have a service listed, create a new service using the link on the ribbon. Call it something relevant.

### LUIS – Language Understanding

[https://eu.luis.ai](https://eu.luis.ai) – this is the European region service
Go to the URL above and sing in using your **Azure account credentials** , or, if you have an account already, using those credentials.

Create a new app using the obvious blue button, giving it a relevant name.

Next: [Initial setup – end to end environment](./environment.md)