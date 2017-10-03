---
title: Bootstrap Images (Deprecated)
sidebar: user_docs
permalink: docs-bootstrap
folder: docs
toc: false
---

>> Note: The bootstrap command is deprecated for Singularity Version 2.4. You should use <a href="/build" target="_blank">build</a> instead.

Bootstrapping was the original way (for Singularity versions prior to 2.4) to install an operating system and then configure it appropriately for a specified need. Bootstrap is very similar to build, except that it by default uses an <a href="https://en.wikipedia.org/wiki/Ext3" target="_blank">ext3</a> filesystem and allows for writability. The images unfortunately are not immutable in this way, and can degrade over time. As of 2.4, bootstrap is still supported for Singularity, however we encourage you to use <a href="/build" target="_blank">build</a> instead.

{% include toc.html %}


## Quick Start
A bootstrap is done based on a Singularity recipe file (a text file called `Singularity`) that describes how to specifically build the container. Here we will overview the sections, best practices, and a quick example.

```bash
$ singularity bootstrap
USAGE: singularity [...] bootstrap <container path> <definition file>
```

The `<container path>` is the path to the Singularity image file, and the `<definition file>` is the location of the definition file (the recipe) we will use to create this container. The process of building a container should always be done by root so that the correct file ownership and permissions are maintained. Also, so installation programs check to ensure they are the root user before proceeding. The bootstrap process may take anywhere from one minute to one hour depending on what needs to be done and how fast your network connection is.
 

Let's continue with our quick start example. Here is your spec file, `Singularity`,


```bash
Bootstrap:docker
From:ubuntu:latest
```

You next create an image:

```bash
$ singularity image.create ubuntu.img
Initializing Singularity image subsystem
Opening image file: ubuntu.img
Creating 768MiB image
Binding image to loop
Creating file system within image
Image is done: ubuntu.img
```

and finally run the bootstrap command, pointing to your image (`<container path>`) and the file `Singularity` (`<definition file>`).

```bash
$ sudo singularity bootstrap ubuntu.img Singularity 
Sanitizing environment
Building from bootstrap definition recipe
Adding base Singularity environment to container
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /root/.singularity/docker
[5/5] |===================================| 100.0% 
Exploding layer: sha256:b6f892c0043b37bd1834a4a1b7d68fe6421c6acbc7e7e63a4527e1d379f92c1b.tar.gz
Exploding layer: sha256:55010f332b047687e081a9639fac04918552c144bc2da4edb3422ce8efcc1fb1.tar.gz
Exploding layer: sha256:2955fb827c947b782af190a759805d229cfebc75978dba2d01b4a59e6a333845.tar.gz
Exploding layer: sha256:3deef3fcbd3072b45771bd0d192d4e5ff2b7310b99ea92bce062e01097953505.tar.gz
Exploding layer: sha256:cf9722e506aada1109f5c00a9ba542a81c9e109606c01c81f5991b1f93de7b66.tar.gz
Exploding layer: sha256:fe44851d529f465f9aa107b32351c8a0a722fc0619a2a7c22b058084fac068a4.tar.gz
Finalizing Singularity container
```

Notice that bootstrap does require sudo. If you do an import, with a docker uri for example, you would see a similar flow, but the calling user would be you, and the cache your `$HOME`.

```bash
$ singularity image.create ubuntu.img
singularity import ubuntu.img docker://ubuntu:latest
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /home/vanessa/.singularity/docker
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:b6f892c0043b37bd1834a4a1b7d68fe6421c6acbc7e7e63a4527e1d379f92c1b.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:55010f332b047687e081a9639fac04918552c144bc2da4edb3422ce8efcc1fb1.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:2955fb827c947b782af190a759805d229cfebc75978dba2d01b4a59e6a333845.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:3deef3fcbd3072b45771bd0d192d4e5ff2b7310b99ea92bce062e01097953505.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:cf9722e506aada1109f5c00a9ba542a81c9e109606c01c81f5991b1f93de7b66.tar.gz
Importing: /home/vanessa/.singularity/metadata/sha256:fe44851d529f465f9aa107b32351c8a0a722fc0619a2a7c22b058084fac068a4.tar.gz
```

For details and best practices for creating your Singularity recipe, <a href="/docs-recipes">read about them here</a>.
