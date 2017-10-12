---
title: Build a Container
sidebar: user_docs
permalink: docs-build
folder: docs
toc: false
---

Use `build` to download and assemble existing containers, convert containers from one format to another, or build a container from a [Singularity recipe](/docs-recipes). 

{% include toc.html %}

## Overview
The `build` command accepts a target as input and produces a container as output.  The target can be a Singularity Hub or Docker Hub URI, a path to an existing container, or a path to a Singularity Recipe file.  The output container can be in squashfs, ext3, or directory format.  

For a complete list of `build` options type `singularity help build`.  For more info on building containers see [Build a Container](docs-build-container).

## Examples 
### Download an existing container from Singularity Hub or Docker Hub

```
$ singularity build lolcow.simg shub://GodloveD/lolcow
$ singularity build lolcow.simg docker://godlovedc/lolcow
```

### Create `--writable` images and `--sandbox` directories

```
$ sudo singularity build --writable lolcow.img shub://GodloveD/lolcow
$ sudo singularity build --sandbox lolcow/ shub://GodloveD/lolcow
```

### Convert containers from one format to another
You can convert the three supported container formats using any combination.
```
$ sudo singularity build --writable development.img production.simg
$ singularity build --sandbox development/ production.simg
$ singularity build production2 development/
```

### Build a container from a Singularity recipe
Given a Singularity Recipe called `Singularity`: 

```
$ sudo singularity build lolcow.simg Singularity 
```

<script>
// Without this, pagination links to exec under repeated build section
$(document).ready(function() {
    $(".next-button").closest('a').attr('href', '/docs-recipes')
})
</script>
