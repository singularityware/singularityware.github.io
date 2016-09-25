---
title: Singularity Exec
sidebar: docs_sidebar
permalink: docs-exec
folder: docs
toc: false
---

## Usage
The `exec` Singularity sub-command allows you to spawn an arbitrary command within your container image as if it were running directly on the host system. All standard IO, pipes, and file systems are accessible via the command being exec'ed within the container.

The usage is as follows:

```bash
$ singularity exec
USAGE: singularity (options) exec [container image] [command] (options)
The command that you want to exec will follow the container image along with any additional arguments will all be passed directly to the program being executed within the container.
```

### Examples
Printing the OS release inside the container:

```bash
$ singularity exec container.img cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 8 (jessie)"
NAME="Debian GNU/Linux"
VERSION_ID="8"
VERSION="8 (jessie)"
ID=debian
HOME_URL="http://www.debian.org/"
SUPPORT_URL="http://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
$ 
```

And properly passing along special characters to the program within the container.

```bash
$ singularity exec container.img echo -ne "hello\nworld\n\n"
hello
world
$ 
```

And a demonstration using pipes:

```bash
$ cat debian.def | singularity exec container.img grep 'MirrorURL'
MirrorURL "http://ftp.us.debian.org/debian/"
$ 
```
