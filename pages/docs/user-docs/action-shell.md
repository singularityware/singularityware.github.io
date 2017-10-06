---
title: Singularity Shell
sidebar: user_docs
permalink: docs-shell
folder: docs
toc: false
---

The `shell` Singularity sub-command will automatically spawn an interactive shell within a container. As of v2.3 the default shell that is spawned via the `shell` command is Bash if it exists otherwise `/bin/sh` is called.

{% include toc.html %}

```bash
$ singularity shell
USAGE: singularity (options) shell [container image] (options)
```

Here we can see the default shell in action:

```
$ singularity shell centos7.img
Singularity: Invoking an interactive shell within container...

Singularity centos7.img:~> echo $SHELL
/bin/bash
```

Additionally any arguments passed to the Singularity command (after the container name) will be passed to the called shell within the container, and shell can be used across image types. Here is a quick example of shelling into a container assembled from Docker layers.

{% include asciicast.html source='shell_from_docker.js' uid='how-to-shell-from-docker' title='How to shell into container from Docker' author='davidgodlove@gmail.com'%}



## Change your shell
The `shell` sub-command allows you to set or change the default shell using the `--shell` argument. As of Singularity version 2.2, you can also use the environment variable `SINGULARITY_SHELL` which will use that as your shell entry point into the container.

### Bash

The correct way to do it:

```bash
export SINGULARITY_SHELL="/bin/bash --norc"
singularity shell centos7.img Singularity: Invoking an interactive shell within container...
Singularity centos7.img:~/Desktop> echo $SHELL
/bin/bash --norc
```

Don't do this, it can be confusing:

```bash
$ export SINGULARITY_SHELL=/bin/bash
$ singularity shell centos7.img 
Singularity: Invoking an interactive shell within container...

# What? We are still on my Desktop? Actually no, but the uri says we are!
vanessa@vanessa-ThinkPad-T460s:~/Desktop$ echo $SHELL
/bin/bash
```

Depending on your shell, you might also want the `--noprofile` flag. How can you learn more about a shell? Ask it for help, of course!


## Shell Help

```bash
$ singularity shell centos7.img --help
Singularity: Invoking an interactive shell within container...

GNU bash, version 4.2.46(1)-release-(x86_64-redhat-linux-gnu)
Usage:	/bin/bash [GNU long option] [option] ...
	/bin/bash [GNU long option] [option] script-file ...
GNU long options:
	--debug
	--debugger
	--dump-po-strings
	--dump-strings
	--help
	--init-file
	--login
	--noediting
	--noprofile
	--norc
	--posix
	--protected
	--rcfile
	--rpm-requires
	--restricted
	--verbose
	--version
Shell options:
	-irsD or -c command or -O shopt_option		(invocation only)
	-abefhkmnptuvxBCHP or -o option
Type `/bin/bash -c "help set"' for more information about shell options.
Type `/bin/bash -c help' for more information about shell builtin commands.
```

And thus we should be able to do:

```bash
$ singularity shell centos7.img -c "echo hello world"
Singularity: Invoking an interactive shell within container...

hello world
```
