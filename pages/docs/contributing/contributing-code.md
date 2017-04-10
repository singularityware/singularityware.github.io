---
title: Contributing to Singularity
sidebar: main_sidebar
permalink: contributing-code
folder: docs
---

## Contribute to the code

To contribute to the development of Singularity, you must:

- Own the code and/or have the right to contribute it
- Be able to submit software under the 3 clause BSD (or equivalent) license (while other licenses are allowed to be submitted by the license, acceptance of any contribution is up to the project lead)
- Read, understand and agree to the license
- Have a GitHub account (this just makes it easier on me)


We use the traditional <a href="https://guides.github.com/introduction/flow/" target="_blank">Github Flow</a> to develop. This means that you fork the repo and checkout a branch to make changes, you submit a pull request (PR) to the development branch with your changes, and the development branch gets merged with master for official releases.


### Step 1. Fork the repo
To contribute to the web based documentation, you should obtain a GitHub account and fork the <a href="{{site.repo}}" target="_blank">Singularity</a> repository. Once forked, you will want to clone the fork of the repo to your computer. Let's say my Github username is vsoch, and I am using ssh:

```bash
git clone git@github.com:vsoch/singularity.git
cd singularity/
```

### Step 2. Set up your config
The github config file, located at `.git/config`, is the best way to keep track of many different forks of a repository. I usually open it up right after cloning my fork to add the repository that I forked as a <a href="https://help.github.com/articles/adding-a-remote/" target="_blank">remote</a>, so I can easily get updated from it. Let's say my .git/config first looks like this, after I clone my own branch:


```bash
      [core]
              repositoryformatversion = 0
              filemode = true
              bare = false
              logallrefupdates = true
      [remote "origin"]
              url = git@github.com:vsoch/singularity
              fetch = +refs/heads/*:refs/remotes/origin/*
      [branch "master"]
              remote = origin
              merge = refs/heads/master
```


I would want to add the upstream repository, which is where I forked from.


```bash
      [core]
              repositoryformatversion = 0
              filemode = true
              bare = false
              logallrefupdates = true
      [remote "origin"]
              url = git@github.com:vsoch/singularity
              fetch = +refs/heads/*:refs/remotes/origin/*
      [remote "upstream"]
              url = https://github.com/singularityware/singularity
              fetch = +refs/heads/*:refs/remotes/origin/*
      [branch "master"]
              remote = origin
              merge = refs/heads/master
```


I can also add some of my colleagues, if I want to pull from their branches:


```bash
      [core]
              repositoryformatversion = 0
              filemode = true
              bare = false
              logallrefupdates = true
      [remote "origin"]
              url = git@github.com:vsoch/singularity
              fetch = +refs/heads/*:refs/remotes/origin/*
      [remote "upstream"]
              url = https://github.com/singularityware/singularity
              fetch = +refs/heads/*:refs/remotes/origin/*
      [remote "greg"]
              url = https://github.com/gmkurtzer/singularity
              fetch = +refs/heads/*:refs/remotes/origin/*
      [branch "master"]
              remote = origin
              merge = refs/heads/master

```

In the Github flow, the master branch is the frozen, current version of the software. Your master branch is always in sync with the upstream (our singularityware master), and the singularityware master is always the latest release of 

This would mean that I can update my master branch as follows:

```bash
git checkout master
git pull upstream master
git push origin master
```
and then I would return to working on the branch for my feature. How to do that exactly? Read on!



### Step 3. Checkout a new branch
<a href="https://guides.github.com/introduction/flow/" target="_blank">Branches</a> are a way of isolating your features. For example, if I am working on several features, I would want to keep them separate, and "submit them" (in what is called a <a href="https://help.github.com/articles/about-pull-requests/" target="_blank">pull request</a>) to be added to the main repository codebase. Each repository, including your fork, has a main branch, which is usually called "master". As mentioned earlier, the master branch of a fork should always be in sync with the repository it is forked from (which I usually refer to as "upstream") and then branches of the fork consistently updated with that master. Given that we've just cloned the repo, we probably want to work off of the current development branch, which has the most up to date "next version" of the software. So we can start by checking out that branch:

```bash
git checkout -b development
git pull origin development
```

At this point, you can either choose to work on this branch, push to your origin development and pull request to singularityware development, or you can checkout another branch specific to your feature. We recommend always working from, and staying in sync with development. The command below would checkout a branch called `add/my-awesome-new-feature` from development.

```bash
# Checkout a new branch called add/my-awesome-feature
git checkout -b add/my-awesome-feature development
```

The addition of the `-b` argument tells git that we want to make a new branch. If I want to just change branches (for example back to master) I can do the same command without `-b`:

```bash
# Change back to master
git checkout master
```

Note that you should commit changes to the branch you are working on before changing branches, otherwise they would be lost. Github will give you a warning and prevent you from changing branches if this is the case, so don't worry too much about it.


### Step 4. Make your changes
On your new branch, go nuts! Make changes, test them, and when you are happy with a bit of progress, commit the changes to the branch:

```bash
git commit -a
```

This will open up a little window in your default text editor that you can write a message in the first line. This commit message is important - it should describe exactly the changes that you have made. Bad commit messages are like:

- changed code
- updated files

Good commit messages are like:

- changed function "get_config" in functions.py to output csv to fix #2
- updated docs about shell to close #10

The tags "close #10" and "fix #2" are referencing issues that are posted on the main repo you are going to do a pull request to. Given that your fix is merged into the master branch, these messages will automatically close the issues, and further, it will link your commits directly to the issues they intended to fix. This is very important down the line if someone wants to understand your contribution, or (hopefully not) revert the code back to a previous version.

### Step 5. Push your branch to your fork
When you are done with your commits, you should push your branch to your fork (and you can also continuously push commits here as you work):

```bash
git push origin add/my-awesome-feature
```

Note that you should always check the status of your branches to see what has been pushed (or not):

```bash
git status
```

### Step 6. Submit a Pull Request

Once you have pushed your branch, then you can go to either fork and (in the GUI) <a href="https://help.github.com/articles/creating-a-pull-request/" target="_blank">submit a Pull Request</a>. Regardless of the name of your branch, your PR should be submit to the singularityware development branch. This will open up a nice conversation interface / forum for the developers of Singularity to discuss your contribution, likely after testing. At this time, any continuous integration that is linked with the code base will also be run. If there is an issue, you can continue to push commits to your branch and it will update the Pull Request.


## Support, helping and spreading the word!
This is a huge endavor, and it is greatly appreciated! If you have been using Singularity and having good luck with it, join our <a href="https://groups.google.com/a/lbl.gov/forum/#!forum/singularity" target="_blank">Google Group</a> and help out other users! Post to online communities about Singularity, and request that your distribution vendor, service provider, and system administrators include Singularity for you!
