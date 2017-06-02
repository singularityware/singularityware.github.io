---
title: Controlling Your Build
sidebar: user_docs
permalink: user-control
folder: docs
---

This document will cover various environment variables that you can set to control the build of your image. If you are looking for the admin setup for Singularity on a shared resource, see the separate <a href="/admin-guide">Singularity Administration Guide</a>.


## Cache Folders
To make download of layers for <a href="/docs-import">import</a> and <a href="/docs-pull">pull</a> faster and less redundant, we use a caching strategy. By default, the Singularity software will create a set of folders in your `$HOME` directory for docker layers, Singularity Hub images, and Docker metadata, respectively:

```
$HOME/.singularity
$HOME/.singularity/docker
$HOME/.singularity/shub
$HOME/.singularity/metadata
```

Fear not, you have control to customize this behavior! If you don't want the cache to be created (and a temporary directory will be used), set `SINGULARITY_DISABLE_CACHE` to True/yes, or if you want to move it elsewhere, set `SINGULARITY_CACHEDIR` to the full path where you want to cache. Remember that when you run commands as sudo (for example, with <a href="/docs-bootstrap">bootstrap</a> this will use root's home at `/root` and not your user's home. 

## Pull Folder
For details about customizing the output location of <a href="/docs-pull">pull</a>, see the<a href="/docs-pull">pull docs.</a> You have the similar ability to set it to be something different, or to customize the name of the pulled image.


## Support

Have a question, or need further information? <a href="/support">Reach out to us.</a>
