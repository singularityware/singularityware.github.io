---
title: Quick Start Installation
sidebar: user_docs
permalink: docs-quick-start-installation
folder: docs
---


## Before you begin
If you have an earlier version of Singularity installed, you should [remove it](#remove-an-old-version) before executing the installation commands.

These instructions will build Singularity from source on your system.  So you will need to have some development tools installed.  If you run into missing dependencies, try installing them like so:

**Ubuntu**

```
$ sudo apt-get update && \
    sudo apt-get install \
    python \
    dh-autoreconf \
    build-essential
```

**Centos**

```
$ sudo yum update && \
    sudo yum groupinstall 'Development Tools'
```
{% include asciicast.html source='install_dependencies.js' title='How to install dependencies' author='davidgodlove@gmail.com'%}

## Install the master branch
The following commands will install the latest version of the [GitHub repo](https://github.com/singularityware/singularity)  master branch to `/usr/local`. 

```
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ ./autogen.sh
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```

Note that the installation prefix is `/usr/local` but the configuration directory is `/etc`. This ensures that the configuration file `singularity.conf` is placed in the standard location. 

If you omit the `--sysconfdir` option , the configuration file will be installed in `/usr/local/etc`.  If you omit the `--prefix` option, Singularity will be installed in the `/usr/local` directory hierarchy by default.  And if you specify a custom directory with the `--prefix` option, all of Singularity's binaries and the configuration file will be installed within that directory.  This last option can be useful if you want to install multiple versions of Singularity, install Singularity on a shared system, or if you want to remove Singularity easily after installing it.  

{% include asciicast.html source='install_master.js' title='How to install the master branch' author='davidgodlove@gmail.com'%}


## Install a specific release
The following commands will install a specific release from [GitHub releases page](https://github.com/singularityware/singularity/releases) to `/usr/local`.  
 
```
$ VER=2.2.1
$ wget https://github.com/singularityware/singularity/releases/download/$VER/singularity-$VER.tar.gz
$ tar xvf singularity-$VER.tar.gz
$ cd singularity-$VER
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```


## Install the development branch
If you want to test a development branch feature the routine above should be tweaked slightly:


```
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

If you modified the system configuration directory, remove the `singularity.conf` file there as well.

If you installed Singularity in a custom directory, you need only remove that directory to uninstall Singularity.  For instance if you installed singularity with the `--prefix=/some/temp/dir` option argument pair, you can remove Singularity like so:

```bash
$ sudo rm -rf /some/temp/dir
```


## Overview of the Singularity Interface
Singularity is a command line interface that is designed to interact with containerized applications as transparently as possible. This means you can run programs inside a container as if they were running on your host system. You can easily redirect IO, use pipes, pass arguments, and access files, sockets, and ports on the host system from within a container. 

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

Notice the first line marked `USAGE:` and the placement of the options. Option placement is very important in Singularity.  It ensures that the right options are being parsed at the right time. For instance, if you were to run a command inside the container called `foo -v`, then Singularity must be aware that the option `-v` that you are passing to the command `foo` is not intended to be parsed or interfered with by Singularity. 

For example, you may pass the `-v` option twice, once in the Singularity global options and once for the command that you are executing inside the container. The final command may look like:

```
$ singularity -v exec container.img foo -v
```

This means that debugging looks like the following:

```
$ singularity --debug create container.img
```

Quiet is the same position:

```
$ singularity --quiet create container.img
```

But if we were to bind a directory within a container, it must come after the command because `--bind` is not a global option!

```
$ singularity run --bind /local/path:/container/path container.img
```

The take home message here is that option placement is exceedingly important. The algorithm that Singularity uses for option parsing for both global options as well as subcommand options is as follows:

1. Read in the current option name
2. If the option is recognized do what is needed, move to next option (goto #1)
3. If the paramater is prefixed with a `-` (hyphen) but is not recognized, error out
4. If the next option is not prefixed with a `-` (hyphen), then assume we are done with option parsing

This means that options will continue to be parsed until no more options are listed.

*note: Options that require data (e.g.* `--bind <path>`*) must be separated by white space, not an equals sign!*

As the above `USAGE:` describes, Singularity will parse the command as follows:

1. Singularity command (`singularity`)
2. Global options
3. Singularity subcommand (`shell` or `exec`)
4. Subcommand options
5. Any additional input is passed to the subcommand

You can get additional help on any of the Singularity subcommands by using any one of the following command syntaxes:

```
$ singularity help <subcommand>
$ singularity --help <subcommand>
$ singularity -h <subcommand>
$ singularity <subcommand> --help
$ singularity <subcommand -h
```


## Shell into a Non-Persistent Container
At this point, you can easily test Singularity by downloading and running a non-persistent container. As mentioned earlier, Singularity has the ability to interface with the main Docker Registry, so let's start off by pulling a container down from the main Docker Registry and launching a shell inside of a given container:

```
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

In this example, you started on your (insert OS here) host operating system, ran Singularity as a non-root user and used a URI which tells Singularity to pull a given container from the main Docker Registry and execute a shell within it. In this example, we are not telling Singularity to use a local image, which means that any changes we make will be non-persistent (e.g. the container is removed automatically as soon as the shell is exited). It's also salient to note that you don't need to have Docker installed to use an image from Docker Hub.

You may select other images that are currently hosted on the main Docker Hub Library.

{% include asciicast.html source='shell_from_docker.js' title='How to shell into container from Docker' author='davidgodlove@gmail.com'%}


## Container Guts
Where do we keep metadata and things? The metadata folder is located within the image under the root directory at `/.singularity.d`

```
Singularity ubuntu:latest:\w> ls /.singularity.d
actions  env  labels.json  runscript
```

The `runscript` is linked to the file `/singularity`. Within `env` we have different files that were sourced by the container to generate the `/environment` file at the root of the image, in the order specified.

```
ls /.singularity.d/env
01-base.sh  10-docker.sh
```

`labels.json` is metadata about the container, both from the bootstrap or creation, and from Docker (if relevant). These files should not be edited manually.  Instead, add variables to your [bootstrap specification](/docs-bootstrap) file that will automatically generate these files.

{% include asciicast.html source='container_guts.js' title='Viewing container meta-data' author='davidgodlove@gmail.com'%}


## Creating a New Singularity Image
Singularity's primary objectives are:

* mobility 
* reproducibility 
* archiving environments 

These features are realized via the Singularity image file. As explained earlier, Singularity images are individual files which can be copied, shared, and easily archived along with relevant data. This means that the all computational components can be easily replicated, utilized, and extended by other users.

The first part of building your reproducible container is to create the raw Singularity image file:

```
$ singularity create container.img
Creating a new image with a maximum size of 768MiB...
Executing image create helper
Formatting image with ext3 file system
Done.
```

Think of this as an empty file system that you can fill with an OS, apps, and data.  You can override the default size (which varies somewhat according to which version of Singularity you are using) by specifying the `--size` option in MiB as follows:

```
$ singularity create --size 2048 container.img
Creating a new image with a maximum size of 2048MiB...
Executing image create helper
Formatting image with ext3 file system
Done.

$ ls -l container.img
-rwxr-xr-x 1 user group 2147483680 Dec 25 06:00 container.img
```

Note the permissions of the resulting file. While the `umask` is adhered to, you should find that the file is executable. At this point there is nothing to execute within that image. But once this image contains a proper operating system, you can define what it will do when it is executed directly. 

{% include asciicast.html source='create_new_image.js' title='How to create an image' author='davidgodlove@gmail.com'%}


## Bootstrapping a Singularity Image
The final step in creating a fully functional Singularity container is to execute the `bootstrap` command.  This installs an operating system, apps, and creates an environment within the image. 

To bootstrap an image, you first need a [definition file](/bootstrap-image#the-bootstrap-definition-file).  This acts as a set of blueprints describing how to build the container.  The Singularity repository contains an `examples` subdirectory with several definition files.  Assuming that you `git cloned` the Singularity repository into your current working directory and you already executed the `create` command above, you could bootstrap your image like so.  (The exact path to the definition file may vary depending on the version of Singularity you installed.)

```
$ sudo singularity bootstrap container.img singularity/examples/ubuntu/Singularity
```

You will see a lot of standard output as Singularity downloads and installs all the pieces for Ubuntu into your image.  After it completes, you will have a fully functional container!

{% include asciicast.html source='bootstrap_new_image.js' title='How to bootstrap an image' author='davidgodlove@gmail.com'%}


What should you do next? How about learning how to interact with your container via the [shell](/docs-shell), [exec](/docs-exec), or [run](/docs-run) commands.  Or click **next** below to continue the tutorial.  
