---
title: Windows Terminal
date: 2019-05-14
author: Richard Cheney
category: prereqs
comments: true
featured: false
hidden: false
tags: [terminal]
header:
  overlay_image: images/header/terminal.png
  teaser: images/teaser/cloud-tools.png
excerpt: Build and deploy the new open sourced Windows Terminal
---

## Windows Terminal

One of the most unexpected announcements from Build 2019 was for the new Windows Terminal app.  This will run as a separate project alongside the existing console host used by Command Prompt, PowerShell and WSL distros, although they will use some shared components. The whole project is open sourced and you can find it  on [GitHub](https://github.com/microsoft/terminal).  If you want to know more about the new Terminal and how it differs from an architectural perspective then watch the excellent [Build session](https://mybuild.techcommunity.microsoft.com/sessions/77004) from Rich Turner and Michael Niksa.

Here is the launch video, showing the direction for the project and some of the ideas they are looking to incorporate:

<iframe width="560" height="315" src="https://www.youtube.com/embed/8gw0rXPMMPE?rel=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Given the runaway success of Visual Studio Code, we are excited about this.  And given the amount of work we do at the CLI then we naturally wanted to see how the current work in progress compares to using the standard WSL Ubuntu terminal, or one of our other third party favourites, such as [Hyper](https://hyper.is/) or [Terminus](https://eugeny.github.io/terminus/).

Windows Terminal should be coming out later in the year and at that point it will be a nice simple download from the Microsoft Store. At that point I can delete this guide!

If you are a little more technical and a little less patient then you can build and deploy the new Terminal from the source code by following the instructions below.

## Pre-reqs

* Windows 10 1903 minimum
    * Use Settings --> About your PC
    * Also note the version using `ver` in the Command Prompt
* [Visual Studio 2019](https://visualstudio.microsoft.com/vs/)
    * Tested with Professional
    * Select Desktop development with C++
        * Check the MSVC x64/x86 Build Tools
    * Universal Windows Platform Development
        * Check the C++ UWP tools
        * Check the Windows 10 SDK that matches the version
* Git, i.e. [Git for Windows](../git) (or use git within wsl)

## Initial build

1. Settings --> For Developers
    1. Ensure Developer Mode is selected
1. Clone the Git repo down and update
    1. `cd /git` (or your default Git cloning directory)
    1. `git clone https://github.com/microsoft/terminal`
    1. `git submodule update --init --recursive`
1. Run the included version of nuget
    1. `./dep/nuget/nuget.exe restore OpenConsole.sln`
1. Open the OpenConsole.sln file with Visual Studio 2019
    1. Select the correct SDK version to match `ver`
    1. Select No Upgrade in Platform Toolset
    1. Install the required libraries
1. Build the application
    1. Change architecture to x64 and the build to release
    1. Select the CascadiaPackage solution
    1. Build --> Build Solution (`CTRL` + `SHIFT` + `B`)
1. Deploy the application
    1. Build --> Deploy Solution

## Rebuild

There will be frequent updates to the code base.  Instructions to rebuild:

1. `cd /git/terminal`
1. `git pull`
1. `explorer.exe .`
1. Double click OpenConsole.sln to open Visual Studio 2019
    * Release, x64 and CascadiaPackage should already be selected
1. Build --> Build Solution
1. Build --> Deploy Solution

## Customise

One of the great features of the new Terminal project is that it is very customisable, and it is all based on a JSON file called profiles.json. The aim is that you will be able to store it centrally so that you have the same experience wherever you go.

I first installed my preferred Powerline font, [DejaVu Sans Mono](https://github.com/powerline/fonts/tree/master/DejaVuSansMono).

I also installed the experimental [azshell](https://github.com/yangl900/azshell) project twice over, using Chocolatey at the Windows level and the curl command at the WSL level. I can jump in and out of Cloud Shell from Ubuntu using `azshell`, or use the Windows `"C:\ProgramData\chocolatey\bin\azshell.exe --shell bash"` command to start a new Terminal session straight into the Cloud Shell.

Here is my the following profiles.json to have WSL as my default profile, with the new font and customised colours based on the Hyper Relaxed theme.

```json
{
    "globals" :
    {
        "alwaysShowTabs" : false,
        "defaultProfile" : "{6691901c-764a-11e9-b9c0-bc838515ccd4}",
        "initialCols" : 120,
        "initialRows" : 30,
        "keybindings" :
        [
            {
                "command" : "closeTab",
                "keys" :
                [
                    "ctrl+w"
                ]
            },
            {
                "command" : "newTab",
                "keys" :
                [
                    "ctrl+t"
                ]
            },
            {
                "command" : "newTabProfile0",
                "keys" :
                [
                    "ctrl+shift+1"
                ]
            },
            {
                "command" : "newTabProfile1",
                "keys" :
                [
                    "ctrl+shift+2"
                ]
            },
            {
                "command" : "newTabProfile2",
                "keys" :
                [
                    "ctrl+shift+3"
                ]
            },
            {
                "command" : "newTabProfile3",
                "keys" :
                [
                    "ctrl+shift+4"
                ]
            },
            {
                "command" : "newTabProfile4",
                "keys" :
                [
                    "ctrl+shift+5"
                ]
            },
            {
                "command" : "newTabProfile5",
                "keys" :
                [
                    "ctrl+shift+6"
                ]
            },
            {
                "command" : "newTabProfile6",
                "keys" :
                [
                    "ctrl+shift+7"
                ]
            },
            {
                "command" : "newTabProfile7",
                "keys" :
                [
                    "ctrl+shift+8"
                ]
            },
            {
                "command" : "newTabProfile8",
                "keys" :
                [
                    "ctrl+shift+9"
                ]
            },
            {
                "command" : "nextTab",
                "keys" :
                [
                    "ctrl+tab"
                ]
            },
            {
                "command" : "prevTab",
                "keys" :
                [
                    "ctrl+shift+tab"
                ]
            },
            {
                "command" : "scrollDown",
                "keys" :
                [
                    "ctrl+shift+down"
                ]
            },
            {
                "command" : "scrollDownPage",
                "keys" :
                [
                    "ctrl+shift+pgdn"
                ]
            },
            {
                "command" : "scrollUp",
                "keys" :
                [
                    "ctrl+shift+up"
                ]
            },
            {
                "command" : "scrollUpPage",
                "keys" :
                [
                    "ctrl+shift+pgup"
                ]
            },
            {
                "command" : "switchToTab0",
                "keys" :
                [
                    "alt+1"
                ]
            },
            {
                "command" : "switchToTab1",
                "keys" :
                [
                    "alt+2"
                ]
            },
            {
                "command" : "switchToTab2",
                "keys" :
                [
                    "alt+3"
                ]
            },
            {
                "command" : "switchToTab3",
                "keys" :
                [
                    "alt+4"
                ]
            },
            {
                "command" : "switchToTab4",
                "keys" :
                [
                    "alt+5"
                ]
            },
            {
                "command" : "switchToTab5",
                "keys" :
                [
                    "alt+6"
                ]
            },
            {
                "command" : "switchToTab6",
                "keys" :
                [
                    "alt+7"
                ]
            },
            {
                "command" : "switchToTab7",
                "keys" :
                [
                    "alt+8"
                ]
            },
            {
                "command" : "switchToTab8",
                "keys" :
                [
                    "alt+9"
                ]
            }
        ],
        "requestedTheme" : "system",
        "showTabsInTitlebar" : false,
        "showTerminalTitleInTitlebar" : false
    },
    "profiles" :
    [
        {
            "acrylicOpacity" : 0.60000002384185791,
            "closeOnExit" : true,
            "colorScheme" : "Relaxed",
            "commandline" : "wsl.exe ~",
            "cursorColor" : "#FFFFFF",
            "cursorHeight" : 25,
            "cursorShape" : "vintage",
            "fontFace" : "DejaVu Sans Mono for Powerline",
            "fontSize" : 14,
            "guid" : "{6691901c-764a-11e9-b9c0-bc838515ccd4}",
            "historySize" : 9001,
            "name" : "Ubuntu",
            "padding" : "8, 8, 8, 8",
            "snapOnInput" : true,
            "startingDirectory" : "",
            "useAcrylic" : true
        },
        {
            "acrylicOpacity" : 0.60000002384185791,
            "closeOnExit" : true,
            "colorScheme" : "Relaxed",
            "commandline" : "C:\\ProgramData\\chocolatey\\bin\\azshell.exe --shell bash",
            "cursorColor" : "#FFFFFF",
            "cursorHeight" : 25,
            "cursorShape" : "vintage",
            "fontFace" : "DejaVu Sans Mono for Powerline",
            "fontSize" : 14,
            "guid" : "{6691901c-764a-11e9-b9c0-bc838515ccd5}",
            "historySize" : 9001,
            "name" : "Cloud Shell",
            "padding" : "8, 8, 8, 8",
            "snapOnInput" : true,
            "startingDirectory" : "",
            "useAcrylic" : true
        },
        {
            "acrylicOpacity" : 0.80000001192092896,
            "closeOnExit" : true,
            "colorScheme" : "Solarized Dark",
            "commandline" : "wsl.exe -d openSUSE-42",
            "cursorColor" : "#FFFFFF",
            "cursorShape" : "bar",
            "fontFace" : "Consolas",
            "fontSize" : 12,
            "guid" : "{6691901c-764a-11e9-b9c0-bc838515ccd7}",
            "historySize" : 9001,
            "name" : "openSUSE",
            "padding" : "8, 8, 8, 8",
            "snapOnInput" : true,
            "startingDirectory" : "~",
            "useAcrylic" : true
        },
        {
            "acrylicOpacity" : 0.5,
            "background" : "#012456",
            "closeOnExit" : true,
            "colorScheme" : "Campbell",
            "commandline" : "C:\\Program Files\\PowerShell\\6\\pwsh.exe",
            "cursorColor" : "#FFFFFF",
            "cursorShape" : "bar",
            "fontFace" : "Courier New",
            "fontSize" : 12,
            "guid" : "{29191df3-f8f6-41a6-bc50-5f86757e5ef4}",
            "historySize" : 9001,
            "name" : "PowerShell",
            "padding" : "0, 0, 0, 0",
            "snapOnInput" : true,
            "startingDirectory" : "%USERPROFILE%",
            "useAcrylic" : false
        },
        {
            "acrylicOpacity" : 0.75,
            "closeOnExit" : true,
            "colorScheme" : "Campbell",
            "commandline" : "cmd.exe",
            "cursorColor" : "#FFFFFF",
            "cursorShape" : "bar",
            "fontFace" : "Consolas",
            "fontSize" : 12,
            "guid" : "{e5c4a7b9-bd87-416d-9506-877ab7c8722b}",
            "historySize" : 9001,
            "name" : "Command Prompt",
            "padding" : "0, 0, 0, 0",
            "snapOnInput" : true,
            "startingDirectory" : "%USERPROFILE%",
            "useAcrylic" : true
        }
    ],
    "schemes" :
    [
        {
            "background" : "#0C0C0C",
            "black" : "#0C0C0C",
            "blue" : "#0037DA",
            "brightBlack" : "#767676",
            "brightBlue" : "#3B78FF",
            "brightCyan" : "#61D6D6",
            "brightGreen" : "#16C60C",
            "brightPurple" : "#B4009E",
            "brightRed" : "#E74856",
            "brightWhite" : "#F2F2F2",
            "brightYellow" : "#F9F1A5",
            "cyan" : "#3A96DD",
            "foreground" : "#F2F2F2",
            "green" : "#13A10E",
            "name" : "Campbell",
            "purple" : "#881798",
            "red" : "#C50F1F",
            "white" : "#CCCCCC",
            "yellow" : "#C19C00"
        },
        {
            "background" : "#073642",
            "black" : "#073642",
            "blue" : "#268BD2",
            "brightBlack" : "#002B36",
            "brightBlue" : "#839496",
            "brightCyan" : "#93A1A1",
            "brightGreen" : "#586E75",
            "brightPurple" : "#6C71C4",
            "brightRed" : "#CB4B16",
            "brightWhite" : "#FDF6E3",
            "brightYellow" : "#657B83",
            "cyan" : "#2AA198",
            "foreground" : "#FDF6E3",
            "green" : "#859900",
            "name" : "Solarized Dark",
            "purple" : "#D33682",
            "red" : "#D30102",
            "white" : "#EEE8D5",
            "yellow" : "#B58900"
        },
        {
            "background" : "#FDF6E3",
            "black" : "#073642",
            "blue" : "#268BD2",
            "brightBlack" : "#002B36",
            "brightBlue" : "#839496",
            "brightCyan" : "#93A1A1",
            "brightGreen" : "#586E75",
            "brightPurple" : "#6C71C4",
            "brightRed" : "#CB4B16",
            "brightWhite" : "#FDF6E3",
            "brightYellow" : "#657B83",
            "cyan" : "#2AA198",
            "foreground" : "#073642",
            "green" : "#859900",
            "name" : "Solarized Light",
            "purple" : "#D33682",
            "red" : "#D30102",
            "white" : "#EEE8D5",
            "yellow" : "#B58900"
        },
        {
            "background" : "#3B4356",
            "black" : "#161920",
            "blue" : "#AF4B57",
            "brightBlack" : "#3B4356",
            "brightBlue" : "#AF4B57",
            "brightCyan" : "#E5C078",
            "brightGreen" : "#92B279",
            "brightPurple" : "#A3799D",
            "brightRed" : "#6E8FB3",
            "brightWhite" : "#E7EAF1",
            "brightYellow" : "#7DAEAC",
            "cyan" : "#E5C078",
            "foreground" : "#E7EAF1",
            "green" : "#92B279",
            "name" : "Nord Extra Dark",
            "purple" : "#A3799D",
            "red" : "#4E8FB3",
            "white" : "#DEE3EC",
            "yellow" : "#76B3C5"
        },
        {
            "background" : "#353A44",
            "black" : "#151515",
            "blue" : "#6A8799",
            "brightBlack" : "#636363",
            "brightBlue" : "#7EAAC7",
            "brightCyan" : "#ACBBD0",
            "brightGreen" : "#A0AC77",
            "brightPurple" : "#B48EAD",
            "brightRed" : "#BC5653",
            "brightWhite" : "#F7F7F7",
            "brightYellow" : "#EBC17A",
            "cyan" : "#C9DFFF",
            "foreground" : "#D9D9D9",
            "green" : "#909D63",
            "name" : "Relaxed",
            "purple" : "#B06698",
            "red" : "#BC5653",
            "white" : "#D9D9D9",
            "yellow" : "#EBC17A"
        }
    ]
}
```

It is recommended to have Erik Lynd's JSON Tools extension in vscode so that you can prettify the file (`CTRL` + `ALT` + `V`) so that editing is easier. And don't forget that vscode has a great file compare, which you can find in the Command Palette (`CTRL` + `SHIFT` + `P`).

If you ever mess up your profiles.json file then rename it and restart the application and it will regenerate a default version. If you right click on a tab in vscode then you can Reveal in Explorer to find the roaming profile folder for the application.

## References

Here are the sources I used as a reference:

* [Build 2019 Windows Terminal session](https://mybuild.techcommunity.microsoft.com/sessions/77004)
* [GitHub README.md](https://github.com/microsoft/terminal/blob/master/README.md)
* [YouTube: Build Windows Terminal application with Visual Studio 2019](https://www.youtube.com/watch?v=4N1Ils4cDYo)
* [Scott Hanselman's Blog Post](https://www.hanselman.com/blog/ANewConsoleForWindowsItsTheOpenSourceWindowsTerminal.aspx)
