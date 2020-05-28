---
title: "Finally! WSL2 hits GA with the Windows 10 May 2020 update"
author: "Richard Cheney"
published: true
excerpt: Change up your laptop config for Ubuntu, Docker, Visual Studio Code etc.
---

## Introduction

Those of you using the site know that we are big fans of vscode and running WSL on Windows as we have a strong focus on open source software here. And if you follow Ben Coleman, Jason Cabot, myself or the other Citadel contributors on Twitter then you know we absolutely love the direction the teams are taking in terms of open source support on Windows 10.

We have been using WSL2 for a long time, suffering the frequent OS updates on the insiders fast ring just to get the benefit. WSL1 was a major innovation, but the filesystem was slow and it did not have full system call compatibility, so it was limited for development. WSL2 addressed that by including the full Linux kernel in a lightweight VM. They worked some serious magic here, with usual startup time under a second.

The [Microsoft Build](https://aka.ms/build) event has just finished as a full online event and WSL2 was prominent there, along with some of the other tooling in this post, such as Windows Terminal that has just gone GA. (If you missed [Scott Henselman's keynote](https://mybuild.microsoft.com/sessions/871ef73f-f04a-405b-a0fa-01d7433067d1?source=sessions) then that is recommended.) This post will use winget to install Windows Terminal, and then add in a few customisations. And we'll also configure both Visual Studio Code and Docker Desktop to use WSL2 as the backend.

Right, let's get on with it!

## WSL2

Update to WSL2

* [Update](https://support.microsoft.com/help/4028685/windows-10-get-the-update) to Windows 10, version 2004 (build 19041)
* Enable [WSL2](https://aka.ms/wslinstall)
* Download a distro from the Windows Store

    ![Windows Store](/images/posts/2020-05-28-distros.png)

> If you are downloading a new distro from the Windows Store and you don't have a preference then I would recommend Ubuntu 20.04. This post will assume Ubuntu from this point; if you have chosen another flavour of Linux then substitute it in.

Here are a few recommended updates for initial config, assuming your distro is Ubuntu 20.04:

* Update the OS

    ```bash
    sudo apt update && sudo apt full-upgrade -y
    ```

* Install git

    ```bash
    sudo apt install git
    ```

    > Needed by vscode for source control when using Remote-WSL

* Install Azure CLI

    ```bash
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    ```

    > From <https://docs.microsoft.com/cli/azure/install-azure-cli-apt>

## Windows Terminal

You could download [Windows Terminal](https://aka.ms/terminal) from the store, but where's the fun in that. Let's use the new winget package manager instead.

* Open either Command Prompt or PowerShell
* Install Windows Terminal

    ```bat
    winget install terminal --rainbow
    ```

Example:

![winget install terminal](/images/posts/2020-05-28-winget.png)

Once it is downloaded then you can close Command Prompt and open Windows Terminal instead.

* Check the drop down next to the default tab and you'll see it has auto-detected Windows PowerShell, Command Prompt, Azure Cloud Shell, plus anything else you have installed such as your WSL Linux distributions and PowerShell Core. It supports multiple tabs and multiple panes. Here's mine:

    ![terminal](/images/posts/2020-05-28-terminal.png)

If you are spending a lot of time in the CLI then your Windows Terminal probably deserves a little customisation, which is covered in the last section of this post.

### Installing vscode and the Remote Development extension pack

You could browse to the [vscode download page](https://aka.ms/vscode) and then follow the [install extensions](https://code.visualstudio.com/docs/editor/extension-gallery) to install the [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) extension pack, but for speed and brevity here are the PowerShell or Command Prompt commands:

* Open Command Prompt or PowerShell

    > Windows Terminal is assumed for all CLI use from this point!

* Install Visual Studio Code

    ```bat
    winget install vscode --rainbow
    ```

* Install Remote Development extension pack

    ```bat
    code --install-extension ms-vscode-remote.vscode-remote-extensionpack
    ```

## Opening vscode from WSL2

My favourite way to open vscode is directly from Windows Terminal.

* Open Ubuntu
* Change to your desired working directory, e.g.

    ```bash
    cd /git/my-repo
    ```

* Open vscode

    ```bash
    code .
    ```

This makes use of the magical integration between WSL and Windows 10 to open the application at the OS level. Note the `>< WSL: Ubuntu` at the bottom left, denoting Remote-WSL use and the distro. You can also remote via SSH, into local Containers, or the hosted containers called CodeSpaces. Check out the extensions

* Open the integrated terminal using `CTRL`+`'`
* Run `lsb_release -a` to show the Ubuntu version

    ![vscode](/images/posts/2020-05-28-vscode.png)

    You are now running the vscode-server backend process in WSL2.

Top tips:

1. Use the local filesystem spaces in preference to anything within /mnt/c as it will run significantly faster
1. In the File Explorer address bar, go to `\\wsl$\Ubuntu` (where Ubuntu is the name of your distro from wsl -l -v), e.g.

    ![File Explorer](/images/posts/2020-05-28-explorer.png)

    You can drag and drop files between and it seems to handle the EOL conversion nicely.

## Docker

Running linux Docker containers on Windows using Docker Desktop has traditionally used a full VM on the Hyper-V subsystem. It has been completely separate from anything with WSL. You can now change Docker Desktop to use the [WSL2 backend](https://docs.docker.com/docker-for-windows/wsl/), which will be a lot quicker and make Docker Desktop more lightweight. This has now moved from experimental to being the default backend on systems that support WSL2.

The Docker Desktop runs in the systray. Hover over the icon to see the status in the tooltip, and right click for the context menu for settings, restart, learn etc.

* Install Docker Desktop
    * You will need to be running the session as Administrator. (Start -> "Terminal" -> Right Click -> Run As Administrator)

    ```bat
    winget install DockerDesktop
    ```

    * _Enable WSL2 Windows Features_ should now be checked by default in the dialog box
    * Close the _Installation succeeded_  dialog box once deployed
* Start Docker Desktop (from the Start Menu)
    * Wait for the systray icon to move from "Docker is starting" to "Docker Desktop is running"
* The Get Started with Docker tutorial will start up
    * Click on Skip Tutorial (you can always restart the tutorial via Learn on the context menu)
* Click on Settings
    * General: Use the WSL2 based engine is checked
    * Resources; WSL Integration: Your default distro should be checked and you can add others

    ![docker](/images/posts/2020-05-28-docker.png)

* Open Command Prompt

    ```bat
    docker run -dp 80:80 docker/getting-started
    ```

* Open a browser and go to <http://localhost:80>

    ![getting-started](/images/posts/2020-05-28-localhost.png)

    The container is running.

* Open Ubuntu

    * Check the container is running within WSL2

    ```bash
    docker ps
    ```

    Example output:

    ```text
    CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                NAMES
    b005a3a10b28        docker/getting-started   "nginx -g 'daemon of…"   5 minutes ago       Up 5 minutes        0.0.0.0:80->80/tcp   priceless_dirac
    ```

OK, it is working. If you want to look at using Visual Studio Code with containers as a next step, then start [here](https://code.visualstudio.com/docs/remote/containers#_quick-start-try-a-dev-container).

## Customising Windows Terminal

Windows Terminal is hugely customisable. See <https://aka.ms/terminal-docs> for full info. There is a setting UI coming in a future version of Terminal, but in the meantime we'll customise the settings.json. (It is recommended to associate JSON files with vscode rather than Notepad.) Note that there is a read only system level settings file and then your settings.json overrides or extends the config.

If you are in Windows Terminal then `CTRL`+`,` will open the settings.

There are four sections:

1. [Global settings](https://docs.microsoft.com/windows/terminal/customize-settings/global-settings)
1. [Profile settings](https://docs.microsoft.com/windows/terminal/customize-settings/profile-settings)
1. [Colour schemes](https://docs.microsoft.com/windows/terminal/customize-settings/color-schemes)
1. [Key bindings](https://docs.microsoft.com/windows/terminal/customize-settings/key-bindings)

I'll give an example or two from each from my settings.json. It is entirely up to you whether you want to add them to your personal settings.json file.

I'll start at the bottom.

### Key Bindings

There are a huge number of default keyboard shortcuts, but much like vscode there is massive scope to customise.

* Scroll to the `"keybindings": []` array
* Paste in the following between the square braces

    ```json
    { "command": "closePane", "keys": [ "ctrl+w" ] },
    { "command": { "action": "splitPane", "split": "horizontal" }, "keys": [ "ctrl+shift+-" ] },
    { "command": { "action": "splitPane", "split": "vertical" }, "keys": [ "ctrl+shift+=" ] },
    { "command": { "action": "splitPane", "split": "horizontal", "profile": "Command Prompt" }, "keys": "ctrl+shift+d" }
    ```

* Press `ALT`+`SHIFT`+`F` to auto-format the file

The first three bindings override existing keyboard shortcuts. The last one is a new custom rule based on Kayla Cinnamon's config.

### Colour Schemes

Almost mandatory for WSL2's default colour scheme...

* Scroll to the `"schemes": []` array
* Paste the following between the square braces

    ```json
    {
        //"background" : "#0C0C0C",
        "background": "#000000",
        "black": "#151515",
        "blue": "#6A8799",
        "brightBlack": "#636363",
        "brightBlue": "#7EAAC7",
        "brightCyan": "#ACBBD0",
        "brightGreen": "#A0AC77",
        "brightPurple": "#B48EAD",
        "brightRed": "#BC5653",
        "brightWhite": "#F7F7F7",
        "brightYellow": "#EBC17A",
        "cyan": "#C9DFFF",
        "foreground": "#D9D9D9",
        "green": "#909D63",
        "name": "Relaxed",
        "purple": "#B06698",
        "red": "#BC5653",
        "white": "#D9D9D9",
        "yellow": "#EBC17A"
    }
    ```

* Press `ALT`+`SHIFT`+`F` to auto-format the file

You can find lots of examples of colour schemes. Visual Studio Code will realise they are hex colour values and display the colour. Hover over a hex code and the colour picker will be displayed.

### Profile Settings

The profiles section has a defaults object and a list array containing the individual profiles.

Most of my config is in the default section to standardise across all of them:

```json
"defaults": {
    "backgroundImageOpacity": 0.5,
    "backgroundImageStretchMode": "none",
    "fontFace": "Cascadia Code",
    "acrylicOpacity": 0.8,
    "cursorColor": "#FFFFFF",
    "cursorHeight": 25,
    "cursorShape": "vintage",
    "fontSize": 14,
    "colorScheme": "Relaxed",
    "useAcrylic": true,
    "closeOnExit": true
}
```

All of these can be overridden per profile in the list. Here are some additional settings I have within my default Ubuntu profile:

```json
{
    "guid": "{2c4de342-38b7-51cf-b940-2309a097f518}",
    "backgroundImage": "%USERPROFILE%/OneDrive/terminal/OS_Ubuntu.png",
    "backgroundImageAlignment": "bottomRight",
    "commandline": "wsl.exe ~",
    "icon": "%USERPROFILE%/OneDrive/terminal/ubuntu.png",
    "name": "Ubuntu 18.04",
    "tabTitle": "Ubuntu",
    "source": "Windows.Terminal.Wsl",
    "hidden": false
},
```

The commandline has been configured to go straight to the home directory.

You can use custom images for your icons and backgrounds. I have a small logo for Ubuntu or Microsoft at the bottom right. Animated gifs are supported if you want to go mad. I created a terminal folder within my personal OneDrive and placed the images there.

Another alternative is to use the roaming profile folder for the UWP app. It is more of a pain to find, but will work across your machines. Amusingly it is easiest to get there from within WSL2.

* In Ubuntu

    ```bash
    (cd /mnt/c/Users/richeney/AppData/Local/Packages/Microsoft.WindowsTerminal_*/RoamingState && explorer.exe .)
    ```

    > This creates a sub shell in Bash, moves to the right directory and then triggers File Explorer.

* Put the files in that folder and you can then use the following pathing format in the profile:

    ```json
    "backgroundImage": "ms-appdata:///roaming/myImage.png"
    ```

### Global Settings

The global settings are at the top of the file. They are for the global application level settings such as theme, tabs, initial size etc.  The most important one is the defaultProfile. If you want to change it from PowerShell to one of your WSL distros then copy the GUID from the list and set it here.

```json
    "defaultProfile": "{2c4de342-38b7-51cf-b940-2309a097f518}",
    "initialCols": 120,
    "initialRows": 30,
    "copyOnSelect": false,
```

## Finishing up

This took longer than I thought to write up, but I know there will be a lot of interest in setting up Windows 10 for OSS development.

We use these tools every day when automating on Azure and it makes it an absolute pleasure. Enjoy!
