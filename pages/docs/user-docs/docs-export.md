---
title: Singularity Export
sidebar: user_docs
permalink: docs-export
toc: false
folder: docs
---

Export is a way to dump the contents of your container into a .tar.gz, or a stream to put into some other place. For example, you could stream this into an in memory tar in python.

## Usage

```bash
USAGE: singularity [...] export [export options...] <container path>

Export will dump a tar stream of the container image contents to standard
out (stdout). 

EXPORT OPTIONS:
    -f/--file       Output to a file instead of a pipe
       --command    Replace the tar command (DEFAULT: 'tar cf - .')

EXAMPLES:

    $ singularity export /tmp/Debian.img > /tmp/Debian.tar
    $ singularity export /tmp/Debian.img | gzip -9 > /tmp/Debian.tar.gz
    $ singularity export -f Debian.tar /tmp/Debian.img

```
