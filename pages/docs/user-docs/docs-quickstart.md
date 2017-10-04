---
title: Quick Start
sidebar: user_docs
permalink: quickstart
folder: docs
toc: true
---

This guide is intended for running Singularity on a computer where you have root (administrative) privileges.  But if you are learning about Singularity on a system where you lack root privileges you can still complete the steps that do not require the `sudo` command.

## Installation Quick Start
There are many ways to [install Singularity](docs-installation) but this quick start guide will only cover one.  

```bash
git clone {{ site.repo }}.git
cd singularity
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
```

Singularity must be installed as root to function properly.  

## Overview of the Singularity Interface
Singularity's [command line interface](docs-usage) allows you to build and interact with containers transparently. You can run programs inside a container as if they were running on your host system. You can easily redirect IO, use pipes, pass arguments, and access files, sockets, and ports on the host system from within a container. 

The `--help` option gives an overview of Singularity options and subcommands as follows:

```
$ singularity --help
USAGE: singularity [global options...] <command> [command options...] ...

GLOBAL OPTIONS:
    -d|--debug    Print debugging information
    -h|--help     Display usage summary
    -s|--silent   Only print errors
    -q|--quiet    Suppress all normal output
       --version  Show application version
    -v|--verbose  Increase verbosity +1
    -x|--sh-debug Print shell wrapper debugging information

GENERAL COMMANDS:
    help       Show additional help for a command or container                  
    selftest   Run some self tests for singularity install                      

CONTAINER USAGE COMMANDS:
    exec       Execute a command within container                               
    run        Launch a runscript within container                              
    shell      Run a Bourne shell within container                              
    test       Launch a testscript within container                             

CONTAINER MANAGEMENT COMMANDS:
    apps       List available apps within a container                           
    bootstrap  *Deprecated* use build instead                                   
    build      Build a new Singularity container                                
    check      Perform container lint checks                                    
    inspect    Display a container's metadata                                   
    mount      Mount a Singularity container image                              
    pull       Pull a Singularity/Docker container to $PWD                      

COMMAND GROUPS:
    image      Container image command group                                    
    instance   Persistent instance command group                                


CONTAINER USAGE OPTIONS:
    see singularity help <command>

For any additional help or support visit the Singularity
website: http://singularity.lbl.gov/
```
Singularity uses positional syntax.  Global options follow the `singularity` invocation  and affect the way that Singularity runs any command.  Then commands are passed followed by their options.  

For example, to pass the `--debug` option to the main `singularity` command and  run Singularity with debugging messages on:

```
$ singularity --debug run shub://GodloveD/lolcow
```
And to pass the `--containall` option to the `run` command and run a Singularity image in an isolated manner:

```
$ singularity run --containall shub://GodloveD/lolcow
```
To learn more about a specific Singularity command, type one of the following:

```
$ singularity help <command>
$ singularity --help <command>
$ singularity -h <command>
$ singularity <command> --help
$ singularity <command> -h
```

Users can also [write help docs specific to a container](/docs-recipes#help) or for an internal module called an [app](/docs-scif-apps).  If those help docs exist for a particular container, you can view them like so.   

```
$ singularity help container.img            # See the container's help, if provided
$ singularity help --app foo container.img  # See the help for foo, if provided
```

## Download pre-built images
You can use the [`pull`](docs-pull) and [`build`](docs-build) commands to download pre-built images from an external resource like [Singularity Hub](https://singularity-hub.org/) or [Docker Hub](https://hub.docker.com/).  When called on a native Singularity images like those provided on Singularity Hub, `pull` simply downloads the image file to your system.   


```
$ singularity pull shub://vsoch/hello-world   # pull with default name, vsoch-hello-world-master.img
$ singularity pull --name hello.img shub://vsoch/hello-world   # pull with custom name
```

Singularity images can also be pulled and named by an associated Github commit or content hash.

You can also use `pull` with the `docker://` uri to reference Docker images served from a registry.  In this case `pull` does not just download an image file.  Docker images are stored in layers, so `pull` must also combine those layers into a usable Singularity file.  


```
$ singularity pull docker://godlovedc/lolcow  # with default name
$ singularity pull --name funny.img docker://godlovedc/lolcow # with custom name
```

Pulling Docker images reduces reproducibility.  If you were to pull a Docker image today and then wait six months and pull again, you are not guaranteed to get the same image.  If any of the source layers has changed the image will be altered. If reproducibility is a priority for you, try building your images from Singularity Hub.

You can also use the `build` command to download pre-built images from an external resource.  When using `build` you must specify a name for your container like so:

```
$ singularity build hello-world.img shub://vsoch/hello-world
$ singularity build lolcow.img docker://godlovedc/lolcow
```

Unlike `pull`, `build` will convert your image to the latest Singularity image format after downloading it.  

`build` is like a "Swiss Army knife" for container creation.  In addition to downloading images, you can use `build` to create images from other images or from scratch using a [recipe file](/docs-recipes).  You can also use `build` to convert an image between the 3 major container formats supported by Singularity.  We discuss those image formats below in the [Build images from scratch](/quickstart#build-images-from-scratch) section.  

## Interact with Images
Once you have an image, you can interact with it in several ways. For these examples we will use a `hello-world.img` image that can be downloaded from Singularity Hub like so.

```
$ singularity pull --name hello-world.img shub://vsoch/hello-world

```

### Shell 
The [`shell`](docs-shell) command allows you to spawn a new shell within your container and interact with it as though it were a small virtual machine.  

```
$ singularity shell hello-world.img
Singularity: Invoking an interactive shell within container...

# I am the same user inside as outside!
Singularity hello-world.img:~/Desktop> whoami
vanessa

Singularity hello-world.img:~/Desktop> id
uid=1000(vanessa) gid=1000(vanessa) groups=1000(vanessa),4(adm),24,27,30(tape),46,113,128,999(input)
```

`shell` also works with the `shub://` and `docker://` URIs.  This creates an ephemeral container that disappears when the shell is exited.

```
$ singularity shell shub://vsoch/hello-world
```

### Executing Commands
The [`exec`](docs-exec) command allows you to execute a custom command within a container by specifying the image file.  For instance, to list the root (`/`) of our `hello-world.img` image, we could do the following:

```
$ singularity exec hello-world.img ls /
anaconda-post.log  etc	 lib64	     mnt   root  singularity  tmp
bin		   home  lost+found  opt   run	 srv	      usr
dev		   lib	 media	     proc  sbin  sys	      var
```

`exec` also works with the `shub://` and `docker://` URIs.  This creates an ephemeral container that executes a command and disappears.

```
$ singularity exec shub://singularityhub/ubuntu cat /etc/os-release
```

### Running a container
Singularity containers contain "[runscripts](docs-recipes#runscript)".  These are user defined scripts that define the actions a container should perform when someone runs it.  The runscript can be triggered with the [`run`](docs-run) command, or simply by calling the container as though it were an executable.   

```
$ singularity run hello-world.img
$ ./hello-world.img
```

`run` also works with `shub://` and `docker://` URIs.  This creates an ephemeral container that runs and then disappears.  

```
$ singularity run shub://GodloveD/lolcow
```

### Working with Files

Files on the host are reachable from within the container.

```
$ echo "Hello World" > $HOME/hello-kitty.txt
$ singularity exec vsoch-hello-world-master.img cat $HOME/hello-kitty.txt
Hello World
```

This example works because `hello-kitty.txt` exists in the user's home directory.  By default singularity bind mounts `/home/$USER`, `/tmp`, and `$PWD` into your container at runtime.  

You can specify additional directories to bind mount into your container with the [`--bind`](docs-mount) option. In this example, the `/data` directory on the host system is bind mounted to the `/mnt` directory inside the container.  

```
$ echo "I am your father" >/data/vader.sez
$ ~/sing-dev/bin/singularity exec --bind /data:/mnt hello-world.img cat /mnt/vader.sez
I am your father
```

## Build images from scratch

The diagram below shows how you can use Singularity to build images and run images. The high level idea is that we have two environments:

 - a build environment (where you have root privileges) to test and build your container
 - a production environment where you run your container (where you may or may not have root privileges)

<a href="/assets/img/diagram/singularity-2.4-flow.png" target="_blank" class="no-after">
   <img style="max-width:900px" src="/assets/img/diagram/singularity-2.4-flow.png">
</a>

In practice, your build system may or may not differ from your production system. If you want more details about the different build options, read about the [singularity flow](/docs-flow).

As of Singularity v2.4 by default `build` produces immutable images in the squashfs file format. This ensures reproducible and verifiable images. 

However, during testing and debugging you may want an image format that is writable.  This way you can `shell` into the image and install software and dependencies until you are satisfied that your container will fulfill your needs.  For these scenarios, Singularity supports two other image formats: a `sandbox` format (which is really just a chroot directory), and a `writable` format (the ext3 file system that was used in Singularity versions less than 2.4).  

### Sandbox Directory
To build into a `sandbox` (container in a directory) use the `build --sandbox` command and option:

```
$ sudo singularity build --sandbox ubuntu/ docker://ubuntu
```

This command creates a directory called `ubuntu/` with an entire Ubuntu Operating System and some Singularity metadata in your current working directory.

You can use commands like `shell`, `exec`, and `run` with this directory just as you would with a Singularity image.  You can also write files to this directory from within a Singularity session (provided you have the permissions to do so).  These files will be ephemeral and will disappear when the container is finished executing. However if you use the `--writable` option the changes will be saved into your directory so that you can use them the next time you use your container.   

### Writable Image
If you prefer to have a writable image file, you can `build` a container with the `--writable` option.

```
$ sudo singularity build --writable ubuntu.img docker://ubuntu
```
This produces an image that is writable with an ext3 file system. Unlike the sandbox, it is a single image file.

When you want to alter your image, you can use commands like `shell`, `exec`, `run`, with the `--writable` option. Because of permission issues it may be necessary to execute the container as root to modify it.  

```
$ sudo singularity shell --writable ubuntu.img
```

>> Development Tip! When building containers, it often is the case that you will have a lot of
testing of installation commands, and if building a production image, one error will stop the entire build. If you
interactively write the build recipe with one of these writable formats, you can debug as you go, and then
build the production (squashfs) container without worrying that it will error and need to be started again.


### Converting images from one format to another 
The `build` command allows you to build a container from an existing container.  This means that you can use it to convert a container from one format to another.  For instance, if you have already created a sandbox (directory) and want to convert it to the default immutable image format (squashfs) you can do so:

```
$ singularity build new-squashfs sandbox
```

Doing so may break reproducibility if you have altered your sandbox outside of the context of a recipe file, so you are advised to exercise care.  

You can use `build` to convert containers to and from `writable`, `sandbox`, and default (squashfs) file formats via any of the six possible combinations. 


### Singularity Recipes
For a reproducible, production-quality container, we recommend that you build a container with the default (squashfs) file format using a Singularity recipe file. This also makes it easy to add files, environment variables, and install custom software, and still start from your base of choice (e.g., Singylarity Hub). 

A recipe file has a header and a body.  The header determines what kind of base container to begin with, and the body is further divided into sections (called scriptlets) that do things like install software, setup the environment, and copy files into the container from the host system.  

Here is an example of a recipe file:

```
Bootstrap: shub
From: singularityhub/ubuntu

%runscript
    exec echo "The runscript is the containers default runtime command!"

%files
   /home/vanessa/Desktop/hello-kitty.txt        # copied to root of container
   /home/vanessa/Desktop/party_dinosaur.gif     /opt/the-party-dino.gif #

%environment
    VARIABLE=MEATBALLVALUE
    export VARIABLE

%labels
   AUTHOR vsochat@stanford.edu

%post
    apt-get update && apt-get -y install python3 git wget
    mkdir /data
    echo "The post section is where you can install, and configure your container."
```
To build a container from this definition file (assuming it is a file named Singularity), you would call build like so:

```
$ sudo singularity build ubuntu.simg Singularity
```

In this example, the header tells singularity to use a base Ubuntu image from Singularity Hub.  The `%runscript` section defines actions for the container to take when it is executed (in this case a simple message).  The `%files` section copies some files into the container from the host system at build time.  The `%environment` section defines some environment variables that will be available to the container at runtime.  The `%labels` section allows for custom metadata to be added to the container. And finally the `%post` section executes within the container at build time after the base OS has been installed.  The `%post` section is therefore the place to perform installations of custom apps.  

This is a very small example of the things that you can do with a [recipe file](/docs-recipes).  In addition to building a container from Singularity Hub, you can start with base images from Docker Hub, use images directly from official repositories such as Ubuntu, Debian, Centos, Arch, and BusyBox, use an existing container on your host system as a base, or even take a snapshot of the host system itself and use that as a base image.  

If you want to build Singularity images without having singularity installed in a build environment, you can build images using <a href="https://github.com/singularityhub/singularityhub.github.io/wiki" target="_blank">Singularity Hub</a> instead.  If you want a more detailed rundown and examples for different build options, see our [singularity flow](/docs-flow) page

{% include links.html %}
