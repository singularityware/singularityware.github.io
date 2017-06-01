---
title: Singularity Import
sidebar: user_docs
permalink: docs-import
toc: false
folder: docs
---

Singularity import is essentially taking a dump of files and folders and adding them to your image. This works for local compressed things (e.g., tar.gz) but also for docker image layers that you don't have on your system. As of version 2.3, import of docker layers includes the environment and metadata without needing sudo.

## Usage

```bash
USAGE: singularity [...] import <container path> [import from URI]

Import takes a URI and will populate a container with the contents of
the URI. If no URI is given, import will expect an incoming tar pipe.

The size of the container you need to create to import a complete system
may be significantly larger than the size of the tar file/stream due to
overheads of the container filesystem.

SUPPORTED URIs:

    http/https: Pull an image using curl over HTTPD
    docker:     Pull an image from the Docker repository
    shub:       Pull an image from Singularity Hub
    file:       Use a local file (same as just passing local path)

SUPPORTED FILE TYPES:

    .tar, .tar.gz, .tgz, .tar.bz2

EXAMPLES:

    Once you have created the base image template:

    $ singularity create /tmp/Debian.img

    You can then import:

    $ gunzip -c debian.tar.gz | singularity import /tmp/Debian
    $ singularity import /tmp/Debian.img debian.tar.gz
    $ singularity import /tmp/Debian.img file://debian.tar.gz
    $ singularity import /tmp/Debian.img http://foo.com/debian.tar.gz
    $ singularity import /tmp/Debian.img docker://ubuntu:latest

```
