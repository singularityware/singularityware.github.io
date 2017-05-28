---
title: Singularity Shell
sidebar: user_docs
permalink: docs-shell
folder: docs
---

## Usage
The `shell` Singularity sub-command will automatically spawn a shell within a container. The default and the only requirement of any Singularity container is that `/bin/sh` must be present, and thus `/bin/sh` is also used as the default shell.

The usage is as follows:

```bash
$ singularity shell
USAGE: singularity (options) shell [container image] (options)
```

Here we can see the default shell:

```bash
singularity shell centos7.img 
Singularity: Invoking an interactive shell within container...
Singularity centos7.img:~/Desktop> echo $SHELL
/bin/sh
```

Additionally any arguments passed to the Singularity command (after the container name) will be passed to the called shell within the container.

## Change your shell
The shell sub-command allows you to set or change the default shell which is used by using the `--shell` argument. As of Singularity version 2.2, you can also use the environment variable `SINGULARITY_SHELL` which will use that as your shell entry point into the container.

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
