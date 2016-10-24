---
title: Quick Start Installation
sidebar: user_docs
permalink: docs-quick-start-installation
folder: docs
---

If you already have Singularity installed, or if you are using Singularity from your distribution provider and the version they have included version 2.2 or newer, you may skip this section. Otherwise, it is recommended that you install or upgrade the version of Singularity you have on your system. The following commands will get you going, and install Singularity to `/usr/local`. If you have an earlier version of Singularity installed, you should first remove it before continuing with the following installation commands.

```bash
$ mkdir ~/git
$ cd ~/git
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ ./autogen.sh
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```

You should note that the installation prefix is `/usr/local` but the configuration directory is `/etc`. This is done such that the configuration file is in the traditionally found location. If you omit that configure parameter, the configuration file will be found within `/usr/local/etc`.


## Overview of the Singularity Interface
Singularity is a command line driven interface that is designed to interact with containers and applications inside the container in as a transparent manner as possible. This means you can not only run programs inside a container as if they were on your host directly, but also redirect IO, pipes, arguments, files, shell redirects and sockets directly to the applications inside the container. 

Once you have Singularity installed, you should inspect the output of the `--help` option as follows:

```
$ singularity --help
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

CONTAINER USAGE COMMANDS:
    exec          Execute a command within container
    run           Launch a runscript within container
    shell         Run a Bourne shell within container
    test          Execute any test code defined within container

CONTAINER MANAGEMENT COMMANDS (requires root):
    bootstrap     Bootstrap a new Singularity image from scratch
    copy          Copy files from your host into the container
    create        Create a new container image
    expand        Grow the container image
    export        Export the contents of a container via a tar pipe
    import        Import/add container contents via a tar pipe
    mount         Mount a Singularity container image

For any additional help or support visit the Singularity
website: http://singularity.lbl.gov/
```

Specifically notice the first line marked "USAGE". Here you will see the basic Singularity command usage, and notice the placement of the options. Option placement is very important in Singularity to ensure that the right options are being parsed at the right time. As you will see later in the guide, if you were to run a command inside the container called `foo -v`, then Singularity must be aware that the option `-v` that you are passing to the command `foo` is not intended to be parsed or interfered with by Singularity. So the placement of the options is very critical. In this example, you may pass the `-v` option twice, once in the Singularity global options and once for the command that you are executing inside the container. The final command may look like:

```bash
$ singularity -v exec container.img foo -v
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

## Invoking a Non-Persistent Container
At this point, you can easily test Singularity by downloading and running a non-persistent container. As mentioned earlier, Singularity has the ability to interface with the main Docker Registry, so let's start off by pulling a container down from the main Docker Registry and launching a shell inside of a given container:

```bash
$ cat /etc/redhat-release 
CentOS Linux release 7.2.1511 (Core) 
$ singularity shell docker://ubuntu:latest
library/ubuntu:latest
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:9f03ce1741bf604c84258a4c4f1dc98cc35aebdd76c14ed4ffeb6bc3584c1f9b
Downloading layer: sha256:61e032b8f2cb04e7a2d4efa83eb6837c6b92bd1553cbe46cffa76121091d8301
Downloading layer: sha256:50de990d7957c304603ac78d094f3acf634c1261a3a5a89229fa81d18cdb7945
Downloading layer: sha256:3a80a22fea63572c387efb1943e6095587f9ea8343af129934d4c81e593374a4
Downloading layer: sha256:cad964aed91d2ace084302c587dfc502b5869c5b1d15a1f0e458a45e3cadfaa6
Singularity: Invoking an interactive shell within container...

Singularity.ubuntu:latest> cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.1 LTS"
Singularity.ubuntu:latest> which apt-get
/usr/bin/apt-get
Singularity.ubuntu:latest> exit
[gmk@centos7-x64 ~]$
```

In this example, you can see we started off on a Centos-7.2 host operating system, ran Singularity as a non-root user and used a URI which tells Singularity to pull a given container from the main Docker Registry and execute a shell within it. In this example, we are not telling Singularity to use a local image, which means that any changes we make will be non-persistent (e.g. the container is removed automatically as soon as the shell is exited).

You may select other images that are currently hosted on the main Docker Hub Library.

You now have a properly functioning Singularity installation on your system. 

## Creating a New Singularity Image
The primary use cases of Singularity revolve around the idea of mobility, portability, reproducibility, and archival of containers. These features are realized via Singularity via the Singularity image file. As explained earlier, Singularity images are single files which can be copied, shared, and easily archived along with relevant data. This means that the all of the computational components can be easily replicated, utilized and extended on by other researchers.

The first part of building your reproducible container is to first create the raw Singularity image file:

```bash
$ sudo singularity create /tmp/container.img
Creating a new image with a maximum size of 768MiB...
Executing image create helper
Formatting image with ext3 file system
Done.
```

Think of this as an empty bucket of a given size, and you can fill that bucket up to the specified size. By default the size in Singularity v2.2 is 768MiB (but this has changed from 512 - 1024 in different versions). You can override the default size by specifying the `--size` option in MiB as follows:

```bash
$ sudo singularity create --size 2048 /tmp/container.img
Creating a new image with a maximum size of 2048MiB...
Executing image create helper
Formatting image with ext3 file system
Done.
```

Notice that the permissions of the generated file. While the `umask` is adhered to, you should find that the file is executable. While at this point there is nothing to execute within that image, once this image has within it a proper container file system, you can define what this image will do when it is executed directly. 
