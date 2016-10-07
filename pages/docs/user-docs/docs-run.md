---
title: Singularity Run
sidebar: user_docs
permalink: docs-run
folder: docs
toc: false
---

## Usage
Singularity `run` allows you to define a custom action to be taken when a container is either `run` or executed directly by file name. The action is defined by a Singularity "runscript" which is an executable file (script or binary) located within the container physically at '/singularity'.

The usage is as follows:

```bash
$ singularity run
USAGE: singularity (options) run [container image] (options)
The command that you want to exec will follow the container image along with any additional arguments will all be passed directly to the program being executed within the container.
You can also execute the container directly, and it will automatically pass the execution process to the Singularity runscript along with any arguments.
```

### Examples
Here is a basic runscript

```bash
$ cat singularity
#!/bin/sh
echo "$@"
$ chmod +x singularity
```

Now to copy it into the container:

```bash
$ sudo singularity copy container.img singularity /
$ singularity exec container.img ls -l /singularity
-rwxr-xr-x. 1 root root 20 Jun  1 18:14 /singularity
```

Now to run the container:

```bash
$ singularity run container.img "hello world"
hello world
```
And to execute the container directly:

```bash
$ ./container.img "hello again"
hello again
$ 
```
