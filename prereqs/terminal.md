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

Windows Terminal is now in preview and available from the Windows Store, so the recommendation for most users is to download and install from there.  You can ignore the build steps below and skip straight to [customise](#customise).

If you are a little more technical and you want to be on the bleeding edge of the development then you can build and deploy the new Terminal from the source code repo by following the instructions below.

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

The actual profile is installed in a UWP folder. For me it is:

```text
/mnt/c/Users/richeney/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/RoamingState
```

Yours will be different as you'll have a different code in the Microsoft.WindowsTerminal\_ name.

You will find a set of images and my current profiles.json file in my  [terminal-profile](https://github.com/richeney/terminal-profile) repo.

## Copy and Paste

The current version (v0.3) is far better for copy and paste, but is not great when moving between windows and linux files in handling CRLF to LF and vice versa.

If you are in vi and paste in multiline text from the windows clipboard file then you will find you have additional empty lines. DO `esc`+`:` and then use the vi command `g/^$/d`.

Going in the other direction is a mess, with everything on one line.  If I am copying out from ubuntu then I tend to use the standard Ubuntu window. The conhost behaves far better at this point in time.

## References

Here are the sources I used as a reference:

* [Build 2019 Windows Terminal session](https://mybuild.techcommunity.microsoft.com/sessions/77004)
* [GitHub README.md](https://github.com/microsoft/terminal/blob/master/README.md)
* [YouTube: Build Windows Terminal application with Visual Studio 2019](https://www.youtube.com/watch?v=4N1Ils4cDYo)
* [Scott Hanselman's Blog Post](https://www.hanselman.com/blog/ANewConsoleForWindowsItsTheOpenSourceWindowsTerminal.aspx)
