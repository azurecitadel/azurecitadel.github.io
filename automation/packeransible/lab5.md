---
title: "Creating Custom Ansible Roles"
date: 2019-10-07
author: Richard Cheney
category:
comments: true
featured: false
hidden: true
published: true
tags: [ image, packer, linux ]
header:
  overlay_image: images/header/gherkin.jpg
  teaser: images/teaser/packeransible.png
sidebar:
  nav: "packeransible"
excerpt: Do you need a role and cannot find it in Ansible Galaxy? Follow our guide to creating your own.
---

## Introduction

You now know how to use simple playbooks and leverage the roles found in Ansible Galaxy. However, you may find times when you need to create your own roles for something that does not exist in Ansible Galaxy, or requires a slight twist on those that are available in order to meet your specific needs.

In the last lab we created a simple playbook to install the Azure CLI.  If you were to [search on Azure CLI](https://galaxy.ansible.com/search?keywords=azure%20cli&order_by=-relevance&page=1&deprecated=false&platforms=Ubuntu) (filtered to Ubuntu) then you will notice that there are a few existing roles, designed for various combinations of platform and versions within them.

The first two roles in the list support xenial, but not bionic. (If you are using Ubuntu 18.04 then you are running the bionic version.)

> (The [third](https://galaxy.ansible.com/andrelohmann/azurecli) does support both xenial and bionic, but we'll pretend it doesn't exist for the sake of this lab.)

We will create a local Ubuntu only role for the Azure CLI, based on our az_cli.yml file. We'll then add it to a GitHub repo and then update our requirements.yml and master.yml files to make use of the new role.

## Git and GitHub

We will be using both git and GitHub during this lab, so you will need the following:

1. Local git repos area

    You may have your own existing folder for repos.  If so then use that.

    Using `/git` or `/repos` is a good default for WSL2, Linux or MacOS. For WSL1 then you may prefer to use `/mnt/c/git` instead.

    Create a repos folder if you don't already have one, e.g.:

    ```bash
    mkdir -m 755 /git
    ```

    > This lab will use `/git` throughout. Substitute your actual git repos directory path whenever you see `/git` mentioned in this lab.

1. Git binary

    Make sure that you have the git binary installed locally. ([Git installation guide](https://azurecitadel.com/prereqs/git/).)

    > Note that this lab will use the git binary commands wherever possible. If familiar with vscode then feel free to use the automatic git integration in the Source Control view, but you will still need to have the git binary installed.

1. GitHub ID

    [Sign up](https://github.com/join) for a GitHub ID if you haven't already got one.

If you would like an overview of git then the [Git Basics: What is git?](https://git-scm.com/video/what-is-git) video is a good place to start.

## Initialise the ansible-role-azure-cli area

1. Change directory to your git repos folder

    ```bash
    cd /git
    ```

    > Make sure you are directly in your git repos folder before continuing to the initialising step.

1. Initialise the role area

    The **`ansible-galaxy init`** command creates a skeleton role in the current directory.

    ```bash
    umask 022
    ansible-galaxy init ansible-role-azure-cli
    cd ansible-role-azure-cli
    ```

    You can see the structure using the **`tree .`** command.

1. Start vscode for the current folder

    ```bash
    code .
    ```

    The role will open up in its own vscode window.

    > Again,  install vscode using these [instructions](https://azurecitadel.com/prereqs/vscode/), plus the vscode extension for Ansible (`vscoss.vscode-ansible`). However you may complete the lab using your preferred editing tool.

Let's take a look at the structure of the role.

## Role structure

Each role has multiple folders.  The `ansible-galaxy init` automatically creates the following, as output by `tree /git/ansible-role-azure-cli`:

```text
/git/ansible-role-azure-cli
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 8 files
```

The various sections of the playbook will need to be split out and placed in the correct area:

* **tasks** go into **`./tasks/main.yml`**
* **meta** file contains metadata about the role
    * required if you are planning to upload to Ansible Galaxy
* variables and the lower priority defaults go into the **vars** and **defaults** folders respectively
* **handlers** are there to manage errors during deployments
* artefacts deployed by the task modules are placed in either **files** (static) or **templates** (dynamic)
* automated role testing within CI/CD pipelines is stored in the **tests** folder
    * test results are visible in Ansible Galaxy with the _build passing_ or _build failing_ tags

For more info on the various sections within a role then read the [docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html). I would also recommend that you browse the various roles in Ansible Galaxy and then navigate to the linked repos.

## Convert to a local git repo

Before we modify the skeleton files, let's commit the current set of files as a local repo.

1. Initialise the local repo

    Initialise git and add your user config. (Open the Terminal in vscode using `CTRL`+`'`.)

    ```bash
    git init
    git config --global user.email "richeney@microsoft.com"
    git config --global user.name "Richard Cheney"
    git config --global credential.helper store
    git config --global credential.user richeney
    ```

    > Change the email and user name to your own. Change the credential.user to your GitHub ID.

1. Git attributes file

    Create a .gitattributes file

    ```text
    echo "* text=auto eol=lf" > .gitattributes
    ```

    > This is highly recommended for WSL1 users. This file will a) automate CRLF to LF translation and b) ensure that Windows and WSL1 level git info are synced.

1. Stage the files

    ```bash
    git add *
    git add .gitattributes
    ```

1. Commit the files

    ```bash
    git commit -m "ansible-galaxy init"
    ```

    The `-m` switch adds a message for the commit.

1. Show the status

    ```bash
    git status
    ```

    Expected result:

    ```text
    On branch master
    nothing to commit, working tree clean
    ```

OK, we have a local repo, with a commit prior to customising the role.

## Configure the local role

OK, let's configure the role to install the Azure CLI.

1. Remove the sections that are not needed

    We have no artefacts, variables or tests, so we'll remove the following directories.

    * files
    * handlers
    * templates
    * tests
    * vars

    If using the CLI:

    ```bash
    cd /git/ansible-role-azure-cli
    rm -fR files handlers templates tests vars
    ```

    > In vscode you can force a refresh the explorer view. (Hover over the bar above the folder's explorer view.)

1. Update the tasks/main.yml

    The tasks file is effectively a subset of the original az_cli.yml file, only containing the task information. These tasks are different to those in that previous lab, but not substantially.

    Replace the contents of the ./tasks/main.yml file with the yaml below:

    {% raw %}

    ```yaml
    ---
    # Install the Azure CLI
    # Based on <https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest>

    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Get packages needed for the install process
      apt:
        name: "{{ apt_packages }}"
        state: present
      when: ansible_os_family == 'Debian'

    - name: Import the Microsoft signing key into apt
      apt_key:
        url: "{{ repo_key_url }}"
        state: present

    - name: Add the Azure CLI software repository
      apt_repository:
        repo: "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ {{ansible_distribution_release}} main"
        filename: "{{ azure_package_name }}"
        state: present

    - name: Install Azure CLI
      apt:
        name: "{{ azure_package_name }}"
        update_cache: yes

    ...
    ```

    {% endraw %}

    In terms of file structure this is a straight YAML list of tasks.  If you remember the format in the single playbook file then ]the tasks were indented and therefore nested within.

    Note the curly braced variable names. We could have hardcoded the values, but instead we'll define those in a defaults file.

1. Update the defaults/main.yml

    Replace the contents of the ./defaults/main.yml with the following yaml:

    ```yaml
    ---

    azure_package_name: azure-cli

    repo_key_url: https://packages.microsoft.com/keys/microsoft.asc

    apt_packages:
      - aptitude
      - curl
      - apt-transport-https
      - lsb-release
      - gnupg

    ...
    ```

    The list of packages for apt to install is the one most likely to be updated over time, but chances are that the defaults will always be used. The mechanism is shown for your benefit.

1. Update the meta/main.yml

    The meta file is used principally by both Ansible Galaxy and the ansible-galaxy executable. There is some good documentation on the [Role Metadata](https://galaxy.ansible.com/docs/contributing/creating_role.html#role-metadata).

    Replace the contents of the ./meta/main.yml file with the following yaml.

    ```yaml
    ---
    galaxy_info:
      role_name: azure_cli
      author: azurecitadel
      description: This role installs the Microsoft Azure CLI for Linux.
      company: "None"
      license: "MIT"
      min_ansible_version: 2.4
      platforms:
      - name: Ubuntu
        versions:
          - xenial
          - bionic
      galaxy_tags:
        - cloud
        - microsoft
        - azure
        - cli

    dependencies: []

    ...
    ```

1. Update the README.md

    The markdown file is the one that you see when you are browsing the repo.  (It is also used for the Ansible Galaxy web pages if you import the role into there.)

    Replace the contents of ./README.md with the following markdown.

    ~~~markdown
    # Install Azure CLI

    Ansible role to install the Azure CLI for either Ubuntu 16.04 (xenial) and 18.04 (bionic).

    ## Installation

    `ansible-galaxy install richeney.azure_cli`

    ## Example Playbook

    ```yaml
    - hosts: all
      roles:
        - richeney.azure_cli
    ```

    ## Requirements

    None.

    ## Dependencies

    None.

    ~~~

    > Change **`richeney`** to your GitHub ID.

1. Ensure that all of the edited files have been saved and close the editor

## Commit the deletes and modifications

1. Check the status

    ```bash
    git status
    ```

    Expected result:

    ```text
    On branch master
    Changes not staged for commit:
      (use "git add/rm <file>..." to update what will be committed)
      (use "git checkout -- <file>..." to discard changes in working directory)

            modified:   README.md
            modified:   defaults/main.yml
            deleted:    handlers/main.yml
            modified:   meta/main.yml
            modified:   tasks/main.yml
            deleted:    tests/inventory
            deleted:    tests/test.yml
            deleted:    vars/main.yml

    no changes added to commit (use "git add" and/or "git commit -a")
    ```

1. Stage and commit the files

    ```bash
    git commit -a -m "Azure CLI tasks and defaults"
    ```

    > The `-a` switch stages all of the folder's deletions, modifications and creations. (Same as running `git add *` first.)

    Expected output:

    ```text
    [master ef0af2c] Azure CLI tasks and defaults
     8 files changed, 89 insertions(+), 105 deletions(-)
     rewrite README.md (99%)
     delete mode 100644 handlers/main.yml
     rewrite meta/main.yml (96%)
     rewrite tasks/main.yml (90%)
     delete mode 100644 tests/inventory
     delete mode 100644 tests/test.yml
     delete mode 100644 vars/main.yml
    ```

## Test the role using local path

1. Return to your ansible working area

    ```bash
    cd ~/ansible
    ```

1. Create a test.yml file

    Create the file containing the following text, and then modify your host and path.

    ```yaml
    ---
    # Master playbook to test custom role
    - hosts: vm1_cf1d
      become: yes
      roles:
          - role: /git/ansible-role-azure-cli
    ...
    ```

    Ensure that the VM name against `- hosts:` is correct, as well as the directory path for your role directory. (Reminder: list hosts using **`ansible all --list-hosts`**.)

1. Test

    Run the local playbook to prove that the VM is compliant.

    ```bash
    ansible-playbook test.yml
    ```

## Push to GitHub

OK, our local repo containing our custom role is working nicely, but it won't be widely available if it is stuck on your machine. Time to push it up to GitHub and then install it via the requirements.yml file.

1. Create a GitHub repository

    Log in to [GitHub](https://github.com).

    Click on the **`+`** at the top right to add a **New Repository**.

    * name it **`ansible-role-azure-cli`**
    * add a description, e.g. _"Ansible role to install the Azure CLI on Ubuntu"_
    * leave the repo as _Public_
    * do not click the _"Initialize this repository with a README"_ checkbox
    * click **Create Repository**

1. Copy the push commands

    * scroll down to the _"…or push an existing repository from the command line"_ section
    * click the copy icon on the right

    > The two commands should:
    > 1. add the new GitHub repo as the origin remote
    > 1. push your local repo up to the GitHub repo

1. Return the the CLI and change directory to your local repo

    ```bash
    cd /git/ansible-role-azure-cli
    ```

1. Add the remote and push

    Paste the two commands into the session and hit enter to run them. You will need to authenticate to GitHub for the push command to succeed.

    > Windows 10 users can access clipboard history using `Win`+`V`

    Example output:

    ```text
    Counting objects: 26, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (12/12), done.
    Writing objects: 100% (26/26), 3.85 KiB | 985.00 KiB/s, done.
    Total 26 (delta 0), reused 0 (delta 0)
    To https://github.com/richeney/ansible-role-azure-cli.git
     * [new branch]      master -> master
    Branch 'master' set up to track remote branch 'master' from 'origin'.
    ```

    > The credentials store we configured earlier will retain the credentials for future `git push` commands.

1. List the remotes

    List the origin remote using:

    ```bash
    git remote -v
    ```

    Example output:

    ```bash
    origin  https://github.com/richeney/ansible-role-azure-cli.git (fetch)
    origin  https://github.com/richeney/ansible-role-azure-cli.git (push)
    ```

1. Verify the status

    ```bash
    git status
    ```

    Expected output:

    ```text
    On branch master
    Your branch is up to date with 'origin/master'.

    nothing to commit, working tree clean
    ```

1. Check the GitHub repo

    Return to the browser.

    Refresh the GitHub repo webpage (`CTRL`+`R`) and you should see the files for the role and the contents of the README.md.

## Add the new GitHub repo to your required roles

1. Return to the terminal

1. Change directory to your ansible working area

    ```bash
    cd ~/ansible
    ```

1. Edit the requirement.yml

    Your ~/ansible/requirement.yml should currently look like this:

    ```yaml
    ---
    - src: geerlingguy.pip
      name: pip
    - src: geerlingguy.docker
      name: docker
    ...
    ```

    Add a new entry to the end of that list for your new GitHub repo:

    ```yaml
    - src: https://github.com/richeney/ansible-role-azure-cli
      name: azure_cli
    ```

    Note the change in src format from the Ansible Galaxy default to fully pathed repo.

1. Save and close the file

1. Update your local set of roles

    ```bash
    ansible-galaxy install -r requirements.yml
    ```

    Example output:

    ```yaml
     [WARNING]: - pip (1.3.0) is already installed - use --force to change version to unspecified

     [WARNING]: - docker (2.5.3) is already installed - use --force to change version to unspecified

    - extracting azure_cli to /home/richeney/ansible/roles/azure_cli
    - azure_cli was installed successfully
    ```

## Update the master playbook to use the installed role

1. Edit the master.yml file

    We'll update the master.yml so that it uses two inventory groups rather than just our test host.

    Replace the contents with:

    ```yaml
    ---
    # Master playbook pulling in roles

    - hosts: all
      become: yes
      roles:
        - azure_cli

    - hosts: tag_docker_true
      become: yes
      roles:
        - pip
        - docker
      vars:
        pip_install_packages:
          - name: docker

    ...
    ```

    All hosts should have the Azure CLI installed. Those that have a `docker:true` tag (i.e. vm1 and vm2) will also get the pip and docker roles.

1. Apply the playbook

    ```bash
    ansible-playbook master.yml
    ```

    OK, now the config is starting to look a little more impressive. The playbook will take a little while to run on the first pass

    Don't forget that as well as lists of tasks and roles that we can have roles that include nested roles as well and define dependencies. It would be easy to iteratively update this configuration to something that covers a far wider set of requirements.

## Contributing to Ansible Galaxy

I would absolutely recommend that you use the existing Ansible Galaxy roles wherever you can, but there is always the chance that you find that there is nothing in there that meets your particular requirement. If you have created something that truly has value to the community, then pay it back by uploading into Ansible Galaxy.

> OK, before we continue, let's be clear here.  It would not be a good idea for those of you doing this lab to take your custom azure_cli roles and litter Ansible Galaxy.  There are already good roles in Ansible Galaxy to deal with Azure CLI installation and it will not be enhanced my multiple copies of the same role from these labs!!!

All of the work you have done in creating a role using ansible-galaxy, testing it and pushing it into a GitHub repo is exactly the starting point for contributing into Ansible Galaxy.  Let's show the process and then clean up after ourselves.

1. Browse to [Ansible Galaxy](https://galaxy.ansible.com)
1. Login using your GitHub ID
1. Click on **My Content** in the sidebar on the left
1. Click on **Add Content** (on the right)
1. In the Add Content dialog, click on **Import Role from GitHub**
1. Filter by "_ansible_" (optional)
1. Check your ansible-role-azure-cli repo and click OK
1. Refresh the page (`CTRL`+`R`)
1. Click into your **azure_cli** role
    1. Your URI in the address bar should be similar to `https://galaxy.ansible.com/richeney/azure_cli`
    2. Note that the name, platforms, description etc. in the Details section are taken from that metadata/main.yml
1. Click on the **Read Me** button
    1. The content here is pulled straight from your README.md file
1. Click on **My Content** again
1. Click on the three dots on the far right of the azure_cli record to open the context menu
1. **Delete**

If you've created a role that you think would benefit the wider community then please refer to the full contribution [documentation](https://galaxy.ansible.com/docs/contributing/index.html).

## References

* <https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html>
* <https://galaxy.ansible.com/docs/contributing/index.html>
* <https://galaxy.ansible.com/docs/contributing/creating_role.html>

## Finishing Up

In the next lab we will return to Packer, and use Ansible playbooks in creating an image.  We will also start using the Shared Image Gallery as our image repository.

[◄ Lab 4: Playbooks](../lab4){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 6: Shared Image Gallery ►](../lab6){: .btn .btn--primary}
