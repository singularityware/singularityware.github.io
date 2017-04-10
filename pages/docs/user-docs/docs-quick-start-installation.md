---
title: Quick Start Installation
sidebar: user_docs
permalink: docs-quick-start-installation
folder: docs
---

The following commands will install the latest release of Singularity to `/usr/local`. If you have an earlier version of Singularity installed, you should first remove it before continuing with the following installation commands.

```bash
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ ./autogen.sh
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```

You should note that the installation prefix is `/usr/local` but the configuration directory is `/etc`. This is done such that the configuration file is in the traditionally found location. If you omit that configure parameter, the configuration file will be found within `/usr/local/etc`.

## Install the development branch
You commonly might want to test a development branch feature, in which case the routine above should be tweaked slightly:


```bash
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ git fetch
$ git checkout development
$ ./autogen.sh
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```

## Remove an old version
Let's say that we installed Singularity to `/usr/local`. To remove it completely, you need to hit all of the following:

```bash
$ sudo rm -rf /usr/local/libexec/singularity
$ sudo rm -rf /usr/local/etc/singularity
$ sudo rm -rf /usr/local/include/singularity
$ sudo rm -rf /usr/local/lib/singularity
$ sudo rm -rf /usr/local/var/lib/singularity/
$ sudo rm /usr/local/bin/singularity
$ sudo rm /usr/local/bin/run-singularity
$ sudo rm /usr/local/etc/bash_completion.d/singularity 
$ sudo rm /usr/local/man/man1/singularity.1
```

and remember that if you modified the system configuration directory, remove the file there as well.


## Overview of the Singularity Interface
Singularity is a command line driven interface that is designed to interact with containers and applications inside the container in as a transparent manner as possible. This means you can not only run programs inside a container as if they were on your host directly, but also redirect IO, pipes, arguments, files, shell redirects and sockets directly to the applications inside the container. 

Once you have Singularity installed, you should inspect the output of the `--help` option as follows:

```bash
USAGE: singularity [global options...] <command> [command options...] ...

GLOBAL OPTIONS:
    -d --debug    Print debugging information
    -h --help     Display usage summary
    -q --quiet    Only print errors
       --version  Show application version
    -v --verbose  Increase verbosity +1
    -x --sh-debug Print shell wrapper debugging information

GENERAL COMMANDS:
    help          Show additional help for a command
    selftest      Run some self tests to make sure Singularity is
                    installed and operating properly

CONTAINER USAGE COMMANDS:
    exec          Execute a command within container
    run           Launch a runscript within container
    shell         Run a Bourne shell within container
    test          Execute any test code defined within container

CONTAINER USAGE OPTIONS:
    see singularity help <command>

CONTAINER MANAGEMENT COMMANDS (requires root):
    bootstrap     Bootstrap a new Singularity image from scratch
    copy          Copy files from your host into the container
    create        Create a new container image
    expand        Grow the container image
    export        Export the contents of a container via a tar pipe
    import        Import/add container contents via a tar pipe
    mount         Mount a Singularity container image

CONTAINER REGISTRY COMMANDS:
    pull          pull a Singularity Hub container to $PWD


For any additional help or support visit the Singularity
website: http://singularity.lbl.gov/
```

Specifically notice the first line marked "USAGE". Here you will see the basic Singularity command usage, and notice the placement of the options. Option placement is very important in Singularity to ensure that the right options are being parsed at the right time. As you will see later in the guide, if you were to run a command inside the container called `foo -v`, then Singularity must be aware that the option `-v` that you are passing to the command `foo` is not intended to be parsed or interfered with by Singularity. So the placement of the options is very critical. In this example, you may pass the `-v` option twice, once in the Singularity global options and once for the command that you are executing inside the container. The final command may look like:

```bash
$ singularity -v exec container.img foo -v
```

This means that debugging looks like the following:

```bash
$ singularity --debug create container.img
```

Quiet is the same position:

```bash
$ singularity --quiet create container.img
```

But if we were to bind a container, it must come after the command!

```bash
$ singularity run --bind /local/path:/container/path container.img
```

The take home message here is that option placement is exceedingly important. The algorithm that Singularity uses for option parsing for both global options as well as subcommand options is as follows:

1. Read in the current option name
2. If the option is recognized do what is needed, move to next option (goto #1)
3. If the paramater is prefixed with a `-` (hyphen) but is not recognized, error out
4. If the next option is not prefixed with a `-` (hyphen), then assume we are done with option parsing

This means that options will continue to be parsed until no more options are listed.

*note: Options that require data (e.g. `--bind <path>`) must be separated by white space, not an equals sign!*

As the above "USAGE" describes, Singularity will parse the command as follows:

1. Singularity command (`singularity`)
2. Global options
3. Singularity subcommand (`shell` or `exec`)
4. Subcommand options
5. Any additional input is passed to the subcommand

You can get additional help on any of the Singularity subcommands by using any one of the following command syntaxes:

```bash
$ singularity help <subcommand>
$ singularity --help <subcommand>
$ singularity -h <subcommand>
$ singularity <subcommand> --help
$ singularity <subcommand -h
```

## Shell into a Non-Persistent Container
At this point, you can easily test Singularity by downloading and running a non-persistent container. As mentioned earlier, Singularity has the ability to interface with the main Docker Registry, so let's start off by pulling a container down from the main Docker Registry and launching a shell inside of a given container:

```bash
$ singularity shell docker://ubuntu:latest
Importing: base Singularity environment
Cache folder set to /home/vanessa/.singularity/docker
Exploding layer: sha256:6d9ef359eaaa311860550b478790123c4b22a2eaede8f8f46691b0b4433c08cf.tar.gz
Exploding layer: sha256:9654c40e9079e3d5b271ec71f6d83f8ce80cfa6f09d9737fc6bfd4d2456fed3f.tar.gz
Exploding layer: sha256:e8db7bf7c39fab6fec91b1b61e3914f21e60233c9823dd57c60bc360191aaf0d.tar.gz
Exploding layer: sha256:f8b845f45a87dc7c095b15f3d9661e640ebc86f42cd8e8ab36674846472027f7.tar.gz
Exploding layer: sha256:d54efb8db41d4ac23d29469940ec92da94c9a6c2d9e26ec060bebad1d1b0e48d.tar.gz
Exploding layer: sha256:fe44851d529f465f9aa107b32351c8a0a722fc0619a2a7c22b058084fac068a4.tar.gz
Singularity: Invoking an interactive shell within container...

Singularity ubuntu:latest:\w> cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.2 LTS"
Singularity ubuntu:latest:\w> which apt-get
/usr/bin/apt-get
```

In this example, you can see we started off on your (insert OS here) host operating system, ran Singularity as a non-root user and used a URI which tells Singularity to pull a given container from the main Docker Registry and execute a shell within it. In this example, we are not telling Singularity to use a local image, which means that any changes we make will be non-persistent (e.g. the container is removed automatically as soon as the shell is exited). It's also salient to note that although we are using Docker layers, you don't need to have Docker installed.

You may select other images that are currently hosted on the main Docker Hub Library.

You now have a properly functioning Singularity installation on your system. 


## Container Guts
Where do we keep metadata and things? The metadata folder is located at the base of the image, `/.singularity.d`


```bash
Singularity ubuntu:latest:\w> ls /.singularity.d
actions  env  labels.json  runscript
```

The `runscript` is linked to the file `/singularity`. Within `env` we have different files that were sourced by the container to generate the `/environment` file at the root of the image, in the order specified.

```bash
ls /.singularity.d/env
01-base.sh  10-docker.sh  99-environment.sh
```

`labels.json` is metadata about the container, both from the bootstrap or creation, and docker (if relevant). We are showing these files so you understand how we are storing metadata. We advise you to not edit these files manually but rather to add variables to your [bootstrap specification](/docs-bootstrap) file that will automatically generate these files.


## Creating a New Singularity Image
The primary use cases of Singularity revolve around the idea of mobility, portability, reproducibility, and archival of containers. These features are realized via Singularity via the Singularity image file. As explained earlier, Singularity images are single files which can be copied, shared, and easily archived along with relevant data. This means that the all of the computational components can be easily replicated, utilized and extended on by other researchers.

The first part of building your reproducible container is to first create the raw Singularity image file:

```bash
$ singularity create container.img
Creating a new image with a maximum size of 768MiB...
Executing image create helper
Formatting image with ext3 file system
Done.
```

Think of this as an empty bucket of a given size, and you can fill that bucket up to the specified size. By default the size in Singularity v2.2.1 is 768MiB (but this has changed from 512 - 1024 in different versions). You can override the default size by specifying the `--size` option in MiB as follows:

```bash
$ singularity create --size 2048 container.img
Creating a new image with a maximum size of 2048MiB...
Executing image create helper
Formatting image with ext3 file system
Done.
```

Notice that the permissions of the generated file. While the `umask` is adhered to, you should find that the file is executable. While at this point there is nothing to execute within that image, once this image has within it a proper container file system, you can define what this image will do when it is executed directly. 

What should you do next? How about learning how to [import](/docs-import) or [bootstrap](/docs-bootstrap).
