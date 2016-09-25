---
title: Contributing to Documentation
sidebar: docs_sidebar
permalink: contributing-docs
folder: releases
---

We (like almost all open source software providers) have a documentation dillemma... We tend to focus on the code features and functionality before working on documentation. And there is very good reason for this, we want to share the love so nobody feels left out!


## Setting up Development

### Fork the repo
To contribute to the web based documentation, you should obtain a GitHub account and fork the <a href="{{site.repo}}/singularityware.github.io" target="_blank">Singularityware site</a> repository. Once forked, you will want to clone the fork of the repo to your computer. Let's say my Github username is vsoch, and I am using ssh:

```bash
git clone git@github.com:vsoch/singularityware.github.io.git
cd singularityware.github.io/
```

### Install dependencies
We will eventually provide a Dockerfile to get rid of this step, but for the time being you must first <a href="https://jekyllrb.com/docs/installation/" target="_blank">install Jekyll</a>. Jekyll is a static website generator that makes it easy to magically turn markdown files into site content.

Once Jekyll is installed, you can then install the dependencies (called gems) using bundle:

```bash
cd singularityware.github.io/
bundle install
```

If you see an error about a missing gem, you can also install a gem individually:

```bash
gem install jekyll-github
```

Now you can see the site locally by running the server with jekyll:

```bash
jekyll serve
```

This will make the site viewable at `http://localhost:4005/` If you want a nice look into how this works, you will probably want to look into the <a href="" target="_blank">config</a> file, or post a question to one of the <a href="/support" target="_blank">support places</a>.


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

All of the pages are in the <a href="{{ site.repo }}/blob/master/pages" target="_blank">pages</a> folder, organized in a somewhat logical manner. If you want to edit content for a page, just edit the corresponding file. If you need to do something more advanced like edit a sidebar, you should look at the <a href="{{ site.repo }}/blob/master/_data/sidebar" target="_blank">sidebar data</a> yml documents, which render into the navigation.

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
