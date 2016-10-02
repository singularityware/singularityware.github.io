---
title: Contributing to Documentation
sidebar: docs_sidebar
permalink: contributing-docs
folder: releases
---

We (like almost all open source software providers) have a documentation dillemma... We tend to focus on the code features and functionality before working on documentation. And there is very good reason for this, we want to share the love so nobody feels left out!

The following documentation page assumes one is running on OS X, but if you are not, you should be able to easily transpose the necessary commands to your operating system of choice.


## Setting Up Your Development Environment

### Installing Dependencies
Initially (on OS X), you will need to setup [Brew](http://brew.sh/) which is a package manager for OS X and [Git](https://git-scm.com/). To install Brew and Git, run the following commands:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
```

### Fork the repo
To contribute to the web based documentation, you should obtain a GitHub account and *fork* the <a href="https://www.github.com/singularityware/singularityware.github.io" target="_blank">Singularity GitHub Pages</a> repository by clicking the *fork* button on the top right of the page. Once forked, you will want to clone the fork of the repo to your computer. Let's say my Github username is *user99*:

```bash
git clone https://github.com/user99/singularityware.github.io.git
cd singularityware.github.io/
```

### Install a local Jekyll server
This step is required if you want to render your work locally before committing the changes. This is highly recommended to ensure that your changes will render properly and will be accepted.

```bash
brew install ruby
gem install jekyll
gem install bundler
bundle install
```

Now you can see the site locally by running the server with jekyll:

```bash
bundle exec jekyll serve
```

This will make the site viewable at <a href="http://localhost:4005/" target="_blank">http://localhost:4005/</a>.

## Contributing a News Item

Each news item that is rendered automatically in the <a href="http://localhost:4005/feed.xml" target="_blank">site feed</a> and the <a href="/blog" target="_blank">news page</a> is done very simply - you just add a new markdown file to the folder `_posts/news`. There are a few rules you must follow:

### Naming Convention
The name of the markdown file must be in the format `YYYY-MM-DD-meaningful-name.md` For example, `2016-09-23-first-post.md`

### Front End Matter
Jekyll has this thing they call <a href="https://jekyllrb.com/docs/frontmatter/" target="_blank">front matter</a> which is basically a header in your markdown file. For our news feed, the header should look something like this:

      
      ---
      title:  "Welcome to Singularity"
      category: news
      permalink: first-post
      ---

and then write your post after it in <a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank">Markdown Syntax</a>. All and any HTML tags are fair game as well! Once you add the post, if you have set the category correctly to "news" it should show up in the site feed. It's that easy!

## Contributing to a Page

All of the pages are in the <a href="https://www.github.com/singuarityware/singularity/blob/master/pages" target="_blank">pages</a> folder, organized in a somewhat logical manner. If you want to edit content for a page, just edit the corresponding file. If you need to do something more advanced like edit a sidebar, you should look at the <a href="https://www.github.com/singuarityware/singularity/blob/master/_data/sidebar" target="_blank">sidebar data</a> yml documents, which render into the navigation.

## Adding a Release

The releases, akin to the news, are done via a feed. The only difference is that they are rendered on the site in the  <a href="/releases" target="_blank">releases section</a>. It is also done very simply - you just add a new markdown file to the folder `_posts/releases`. The same naming convention follows, however the title of the post should correspond to the release, e.g.:

### Naming Convention
The name of the markdown file must be in the format `YYYY-MM-DD-release-x-x-x.md` For example, `2016-09-23-release-2-2-1.md`

### Front End Matter
The header in your markdown file should look something like this:

      ---
      title:  "Singularity 2.1.2 release"
      category: releases
      permalink: release-2-1-2
      targz: "2.1.2.tar.gz"
      ---      

The targz is the name of the file in the "archive" section of the repository defined in the _config.yml file's "repo" variable. This link will be rendered automatically on the site. The category is also very important, and must be "releases" otherwise it won't show up.

In the markdown file above, after the front end matter you can again use Markdown and HTML to write about the release, make lists of features, and go to town.
