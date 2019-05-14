---
title: Windows Terminal
date: 2019-05-14
author: Richard Cheney
category: prereq
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

There was a great announcement from Build 2019 for the new Windows Terminal app, that is open sourced and available on [GitHub](https://github.com/microsoft/terminal) and brings with it a host of new features.

Given the runaway success of Visual Studio Code, we are excited about this.  And given the amount of work we do at the CLI then we wanted to see how it compared to using the WSL Ubuntu terminal or Hyper.

Windows Terminal should be coming out later in the year and will be a nice simple download from the Microsoft Store.

Those of you who are a little more technical and a little less patient can try to follow the instructions below.

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
1. `git submodule update --init --recursive`
1. `./dep/nuget/nuget.exe restore OpenConsole.sln`
1. `explorer.exe .`
1. Double click OpenConsole.sln
    1. Release, x64 and CascadiaPackage should already be selected
1. Build --> Build Solution
1. Build --> Deploy Solution

## Customise

One of the great features of the new Terminal project is that it is very customisable, and it is all based on a JSON file called profiles.json. The aim is that you will be able to store it centrally so that you have the same experience wherever you go.

I first installed my preferred Powerline font, [DejaVu Sans Mono](https://github.com/powerline/fonts/tree/master/DejaVuSansMono) and then used the following profiles.json to have WSL as my default profile, with the new font and customised colours based on the Hyper Relaxed theme.

```json
{
    "defaultProfile": "{6691901c-764a-11e9-b9c0-bc838515ccd4}",
    "initialRows": 30,
    "initialCols": 120,
    "alwaysShowTabs": false,
    "showTerminalTitleInTitlebar": false,
    "experimental_showTabsInTitlebar": false,
    "profiles": [
        {
            "startingDirectory": "",
            "guid": "{6691901c-764a-11e9-b9c0-bc838515ccd4}",
            "name": "WSL",
            "colorscheme": "Relaxed",
            "historySize": 9001,
            "snapOnInput": true,
            "cursorColor": "#FFFFFF",
            "cursorShape": "bar",
            "commandline": "wsl.exe ~",
            "fontFace": "DejaVu Sans Mono for Powerline",
            "fontSize": 14,
            "acrylicOpacity": 0.7,
            "useAcrylic": true,
            "closeOnExit": true,
            "padding": "8, 8, 8, 8"
        },
        {
            "startingDirectory": "%USERPROFILE%",
            "guid": "{29191df3-f8f6-41a6-bc50-5f86757e5ef4}",
            "name": "PowerShell",
            "background": "#012456",
            "colorscheme": "Campbell",
            "historySize": 9001,
            "snapOnInput": true,
            "cursorColor": "#FFFFFF",
            "cursorShape": "bar",
            "commandline": "C:\\Program Files\\PowerShell\\6\\pwsh.exe",
            "fontFace": "Courier New",
            "fontSize": 12,
            "acrylicOpacity": 0.5,
            "useAcrylic": false,
            "closeOnExit": true,
            "padding": "0, 0, 0, 0"
        },
        {
            "startingDirectory": "%USERPROFILE%",
            "guid": "{e5c4a7b9-bd87-416d-9506-877ab7c8722b}",
            "name": "cmd",
            "colorscheme": "Campbell",
            "historySize": 9001,
            "snapOnInput": true,
            "cursorColor": "#FFFFFF",
            "cursorShape": "bar",
            "commandline": "cmd.exe",
            "fontFace": "Consolas",
            "fontSize": 12,
            "acrylicOpacity": 0.75,
            "useAcrylic": true,
            "closeOnExit": true,
            "padding": "0, 0, 0, 0"
        }
    ],
    "schemes": [
        {
            "name": "Campbell",
            "foreground": "#F2F2F2",
            "background": "#0C0C0C",
            "colors": [
                "#0C0C0C",
                "#C50F1F",
                "#13A10E",
                "#C19C00",
                "#0037DA",
                "#881798",
                "#3A96DD",
                "#CCCCCC",
                "#767676",
                "#E74856",
                "#16C60C",
                "#F9F1A5",
                "#3B78FF",
                "#B4009E",
                "#61D6D6",
                "#F2F2F2"
            ]
        },
        {
            "name": "Solarized Dark",
            "foreground": "#FDF6E3",
            "background": "#073642",
            "colors": [
                "#073642",
                "#D30102",
                "#859900",
                "#B58900",
                "#268BD2",
                "#D33682",
                "#2AA198",
                "#EEE8D5",
                "#002B36",
                "#CB4B16",
                "#586E75",
                "#657B83",
                "#839496",
                "#6C71C4",
                "#93A1A1",
                "#FDF6E3"
            ]
        },
        {
            "name": "Solarized Light",
            "foreground": "#073642",
            "background": "#FDF6E3",
            "colors": [
                "#073642",
                "#D30102",
                "#859900",
                "#B58900",
                "#268BD2",
                "#D33682",
                "#2AA198",
                "#EEE8D5",
                "#002B36",
                "#CB4B16",
                "#586E75",
                "#657B83",
                "#839496",
                "#6C71C4",
                "#93A1A1",
                "#FDF6E3"
            ]
        },
        {
            "name": "Nord Extra Dark",
            "foreground": "#E7EAF1",
            "background": "#3B4356",
            "colors": [
                "#161920",
                "#4E8FB3",
                "#92B279",
                "#76B3C5",
                "#AF4B57",
                "#A3799D",
                "#E5C078",
                "#DEE3EC",
                "#3B4356",
                "#6E8FB3",
                "#92B279",
                "#7DAEAC",
                "#AF4B57",
                "#A3799D",
                "#E5C078",
                "#E7EAF1"
            ]
        },
        {
            "name": "Relaxed",
            "foreground": "#D9D9D9",
            "background": "#353A44",
            "colors": [
                "#151515",
                "#BC5653",
                "#909D63",
                "#EBC17A",
                "#6A8799",
                "#B06698",
                "#C9DFFF",
                "#D9D9D9",
                "#636363",
                "#BC5653",
                "#A0AC77",
                "#EBC17A",
                "#7EAAC7",
                "#B48EAD",
                "#ACBBD0",
                "#F7F7F7"
            ]
        }
    ]
}
```

It is recommended to have Erik Lynd's JSON Tools extension in vscode so that you can prettify the file (`CTRL` + `ALT` + `V`) so that editing is easier. And don't forget that vscode has a great file compare, which you can find in the Command Palette (`CTRL` + `SHIFT` + `P`).

If you ever mess up your profiles.json then rename it and restart the application and it will regenerate a default version.