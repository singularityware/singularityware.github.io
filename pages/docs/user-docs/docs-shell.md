---
title: Singularity Shell
sidebar: user_docs
permalink: docs-shell
folder: docs
toc: false
---

The `shell` Singularity sub-command will automatically spawn a shell within a container. As of v2.3 the default shell that is spawned via the `shell` command is `/bin/bash`.

{% include toc.html %}

## Usage
```
USAGE: singularity [...] shell [shell options...] <container path>

Obtain an interactive shell (/bin/sh) within the container image.


SHELL OPTIONS:
    -B/--bind <spec>    A user-bind path specification.  spec has the format
                        src[:dest[:opts]], where src and dest are outside and
                        inside paths.  If dest is not given, it is set equal
                        to src.  Mount options ('opts') may be specified as
                        'ro' (read-only) or 'rw' (read/write, which is the
                        default). This option can be called multiple times.
    -c/--contain        This option disables the sharing of filesystems on 
                        your host (e.g. /dev, $HOME and /tmp).
    -C/--containall     Contain not only file systems, but also PID and IPC
    -e/--cleanenv       Clean environment before running container
    -H/--home <spec>    A home directory specification.  spec can either be a
                        src path or src:dest pair.  src is the source path
                        of the home directory outside the container and dest
                        overrides the home directory within the container
    -i/--ipc            Run container in a new IPC namespace
    -n/--nv             Enable experimental Nvidia support
    -p/--pid            Run container in a new PID namespace (creates child)
    --pwd               Initial working directory for payload process inside
                        the container
    -S/--scratch <path> Include a scratch directory within the container that
                        is linked to a temporary dir (use -W to force location)
    -s/--shell <shell>  Path to program to use for interactive shell
    -u/--user           Run container in a new user namespace (this allows
                        Singularity to run completely unprivileged on recent
                        kernels and doesn't support all features)
    -W/--workdir        Working directory to be used for /tmp, /var/tmp and
                        $HOME (if -c/--contain was also used)
    -w/--writable       By default all Singularity containers are available as
                        read only. This option makes the file system accessible
                        as read/write.


CONTAINER FORMATS SUPPORTED:
    *.img               This is the native Singularity image format for all
                        Singularity versions 2.x.
    *.sqsh              SquashFS format, note the suffix is required!
    *.tar*              Tar archives are exploded to a temporary directory and
                        run within that directory (and cleaned up after). The
                        contents of the archive is a root file system with root
                        being in the current directory. Compression suffixes as
                        '.gz' and '.bz2' are supported.
    directory/          Container directories that contain a valid root file
                        system.


EXAMPLES:

    $ singularity shell /tmp/Debian.img
    Singularity/Debian.img> pwd
    /home/gmk/test
    Singularity/Debian.img> exit

    $ singularity shell -C /tmp/Debian.img
    Singularity/Debian.img> pwd
    /home/gmk
    Singularity/Debian.img> ls -l
    total 0
    Singularity/Debian.img> exit

    $ sudo singularity shell -w /tmp/Debian.img
    $ sudo singularity shell --writable /tmp/Debian.img
```

```bash
$ singularity shell
USAGE: singularity (options) shell [container image] (options)
```

Here we can see the default shell:

```
$ singularity shell centos7.img
Singularity: Invoking an interactive shell within container...

Singularity centos7.img:~> echo $SHELL
/bin/bash
```

Additionally any arguments passed to the Singularity command (after the container name) will be passed to the called shell within the container.

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
