---
title: Reviewing Content
date: 2019-01-18
author: Richard Cheney
comments: true
hidden: true
published: true
permalink: /contributing/reviewing/
header:
  overlay_image: /images/site/main.png
excerpt: How can you review your content before submitting pull requests?
sidebar:
  nav: "contributing"
toc_depth: 3
---

# Introduction

OK, so you have created some new content.

This guide will give you a couple of options for reviewing your content, and then runs through the remainder of the GitHub workflow to commit your changes locally, push them up to your origin repository, and then make the pull request.

## Code Spell Checker

Install the Code Spell Checker if you want spelling mistakes to be highlighted with a green underscore.  You can add to the dictionary by right clicking on a highlighted word.

The Code Spell Checker is used widely within Microsoft for those authoring documentation for Microsoft Docs.

## Markdown Preview

The markdown preview built into Visual Studio Code is usually sufficient for most users. If you have only simple changes, or single pages such as landing pages (pointing to another repository) or shorter labs, then try that first.

The Open Preview icon is at the top right.  Click on it to open up a new tab to give an idea of how the page will look, check images and links and review formatting and spelling.

Note that tables will not be displayed correctly as they are outside of the official markdown standard.

A couple of keyboard shortcuts that you may find useful:

**Keys** | **Description**
`CTRL`+`SHIFT`+`V` | Open Preview
`CTRL`+`B` | Toggle the sidebar on and off
`CTRL`+`ALT`+`LEFT` | Move the current tab to the left
`CTRL`+`ALT`+`RIGHT` | Move the current tab to the right
`CTRL`+`S` | Save changes
`CTRL`+`W` | Close current tab

## Running Jekyll locally

You can run Jekyll locally so that you can render a full version of the site and review changes.  This is not recommended unless you need it, but for those of you creating more complex multi page labs then it is a must.

### Install Jekyll

For of all, [install Jekyll into the Ubuntu subsystem](https://jekyllrb.com/docs/installation/windows/#installation-via-bash-on-windows-10).

If you find any missing packages on your installation then install them using `sudo apt install <packagename>`.

### Create _config_local.yml

Create a file called _config_local.yml in the root of the repository.  (It should be right alongside the _config.yml.)

```yaml
# Use as an override when serving locally
# Specify as follows: bundler exec jekyll serve --config _config.yml,_config_local.yml
url: http://localhost:4000
```

Your .gitignore file should include _config_local.yml.

### Run Jekyll

Once it is installed then use the following command to run the site locally from the local repository folder. (On my installation the folder is `/git/<repository>`.)

```bash
cd /git/azurecitadel.github.io
bundler exec jekyll serve --config _config.yml,_config_local.yml --future --unpublished'
```

The `--future` switch allows you to view posts that have a future date set. And the `--unpublished` switch will generate HTML for files that have `published: false` set in the Front Matter. Feel free to omit these switches.

You may also use the `--incremental` switch, which is much faster.  This mode only regenerates modified pages, so the category pages will not be regenerated. (You can always quit using `CTRL`+`C` and then rerun the `bundler exec ...` command.)

### Alias

It is a long command, so save time by setting an alias.  Put the following line near the bottom of your `~/bashrc`:

```bash
alias jk='cd /git/azurecitadel.github.io; bundler exec jekyll serve --config _config.yml,_config_local.yml --future --unpublished'
```

You will need to change the fully pathed repository directory.

Type `source ~/.bashrc` to re-read the profile and then `alias jk` to confirm.

<pre class="language-bash command-line" data-output="3,5-99" data-prompt="$"><code>
source ~/.bashrc
alias jk
alias jk='cd /git/azurecitadel.github.io; bundler exec jekyll serve --config _config.yml,_config_local.yml --future --unpublished'
jk
Configuration file: _config.yml
Configuration file: _config_local.yml
            Source: /mnt/c/git/azurecitadel.github.io
       Destination: /mnt/c/git/azurecitadel.github.io/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
       Jekyll Feed: Generating feed for posts
                    done in 25.296 seconds.
                    Auto-regeneration may not work on some Windows versions.
                    Please see: https://github.com/Microsoft/BashOnWindows/issues/216
                    If it does not work, please upgrade Bash on Windows or run Jekyll with --no-watch.
 Auto-regeneration: enabled for '/mnt/c/git/azurecitadel.github.io'
    Server address: http://127.0.0.1:4000
  Server running... press ctrl-c to stop.
</code></pre>

## GitHub workflow

The remainder of the guide will run through the final steps in the GitHub workflow.

### Stage and commit

Once you are happy with the new content then you can stage and commit them to the local copy of the repo:

* Stage your changed files
    * Go to the Git (SCM) pane (CTRL-SHIFT-G)
    * Click the **+** icon on the changes line to stage the modified files
* Commit the staged files
    * Type in a message to describe your changes
    * Click on CTRL+Enter to commit (or select Commit Staged from the ellipsis (**...**))

### Push the commit up to your fork

Push those committed changes up to your GitHub repo:

* Select Push from the SCM ellipsis, or
* Click on the sync button (![sync](/prereqs/contributing/images/sync.png))

### Make a pull request

Once you have changes that you would like to see added to the main repo then

1. Open <a href="https://github.com/" target="_blank">GitHub</a>
1. Navigate to azurecitadel.github.io in the list of your repositories
1. Click on the Pull Request button

The admins for the main Azure Citadel repo will then receive the pull request, review the additions / changes and will then approve.  If there are issues then they may request modifications before repeating the loop.

Once approved, the Jekyll engine will rebuild the static HTML site and your page(s) will go live!

## Finished

We have reached the end of the guide.

We try to make this process as simple as possible, so if you think the guide could be improved for all then please let us know via the comments.

Or even better, change them in your repo - you'll find them in `/prereqs/contributing` - and then make a pull request!

[◄ Multi Page](../multipage){: .btn .btn--inverse} [▲ Index](../#index){: .btn .btn--inverse}
