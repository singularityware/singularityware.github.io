---
title: Quick Start
sidebar: main_sidebar
permalink: quickstart
folder: docs
toc: true
---

## Installation Quick Start
Note that this quickstart is intended for using Singularity on your personal workstation, where you have installed Singularity and have sudo. If you only have access to Singularity on a shared cluster resource, you will be able to go through all parts of this tutorial that do not require writing to an image. First, if you are on your local machine, let's install Singularity.

```bash
git clone {{ site.repo }}.git
cd singularity
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
```

Installing Singularity as a user, or without sudo, will not produce software that works properly. If you want Singularity on your shared cluster resource, you should ask an administrator to install it for you!


## Overview of the Singularity Interface
Singularity is a command line interface that is designed to interact with containerized applications as transparently as possible. This means you can run programs inside a container as if they were running on your host system. You can easily redirect IO, use pipes, pass arguments, and access files, sockets, and ports on the host system from within a container. 

Once you have Singularity installed, you should inspect the output of the `--help` option as follows:

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

Notice the first line marked `USAGE:` and the placement of the options. Option placement is very important in Singularity.  It ensures that the right options are being parsed at the right time. The important "global" commands tend to relate to debugging, and this will be useful for you to know:

```
$ singularity --quiet run shub://vsoch/hello-world
$ singularity --debug shell docker://ubuntu
```

Notice the positioning *before* the actions to `run` or `shell`. This is different from a command intended for the action.

```
$ singularity run --bind /local/path:/container/path docker://ubuntu
```

Notice the argument `--bind` is located after the action `run`. 

The take home message here is that option placement is exceedingly important. You can get additional help on any of the Singularity subcommands by using any one of the following command syntaxes:

```
$ singularity help <subcommand>
$ singularity --help <subcommand>
$ singularity -h <subcommand>
$ singularity <subcommand> --help
$ singularity <subcommand> -h
```

You can also ask for the help section written by the creator, or specific to an internal module called an <a href="/apps">app</a>.

```
$ singularity help container.img            # See the container's help, if provided
$ singularity help --app foo container.img  # See the help for foo, if provided
```

## Container Guts
Where do we keep metadata and things? The metadata folder is located within the image under the root directory at `/.singularity.d`

```
singularity shell roar.simg
$ ls /.singularity.d/
actions  env  libs  runscript  startscript  labels.json
```

The `runscript` is linked to the file `/singularity`. Within `env` we have different files that were sourced by the container to generate the `/environment` file at the root of the image, in the order specified.

```
 ls /.singularity.d/env
01-base.sh  10-docker.sh  90-environment.sh  95-apps.sh  99-base.sh
```

`labels.json` is metadata about the container, both from the bootstrap or creation, and from Docker (if relevant). These files should not be edited manually.  Instead, add variables to your `%environment` or `%appenv` sections of your [Singularity recipe](/docs-recipes) file that will automatically generate these files.

{% include asciicast.html source='container_guts.js' title='Viewing container meta-data' uid='viewing-container-metadata' author='davidgodlove@gmail.com'%}


## Command Quick Start
This first section of commands can be done on a shared resource, or your personal computer. You don't need sudo to create, import, or shell into containers.
First we are going to discuss the three basic ways to get a container:


 - [pull](#pulling-images): pull an image from a registry
 - [build](#building-images): build an image from a base of your choice
 - [interact](#interacting-with-images): Interact with your image, including shell, exec, run, and basic binds.
 - [recipes](#recipes): Once you are comfortable with interacting with images, you probably want to build from a custom recipe


### Pulling Images
The simplest command is likely a pull, and it translates to pulling an image from an external resource, such as Singularity Hub. For example:

```
singularity pull shub://vsoch/hello-world   # pull with default name, vsoch-hello-world-master.img
singularity pull --name hello.img shub://vsoch/hello-world   # pull with custom name
```

To run an image that you've pulled, which means running the script that the creator has defined as the entrypoint to the image (the "runscript") you can do either of the following:

```
singularity run hello.img
./hello.img

RaawwWWWWWRRRR!! Avocado!
```

The same actions would be done on the back end (to temporary files) if you were to try and `run`, `exec`, or `shell` to the same image:

```
singularity shell shub://vsoch/hello-world
singularity run shub://vsoch/hello-world
singularity exec shub://vsoch/hello-world cat /.singularity.d/labels.json
```

You can pull with the `docker://` uri to reference Docker images served from a registry, but be weary - pulling a Docker image does not mean pulling one, immutable file. Docker images are provided via layers, and so if you were to pull `docker://ubuntu` today and in six months, you are not guaranteed to produce the same image. Pull is great because knowing the command minimally gives you ability to use any Docker or Singularity image already provided in a registry. Singularity images can also be pulled and named by an associated Github commit or content hash, see our <a href="/docs-pull">pull</a> docs for more details.


## Building Images
For this example, we will talk about building images from a Docker base, which does not require a <a href="/docs-recipes">Singularity recipe</a>. However, if you want to build and customize your image, you can create a <a href="/docs-recipes">Singularity recipe</a> text file, which is a simple text file that describes how the container should be made. First, let's take a look at where you can build, and the options that you have.

### The Singularity Flow
The diagram below is a visual depiction of how you can use Singularity to build images. The high level idea is that we have two environments:

 - a development environment (where you have sudo privileges) to test and build your container
 - a production environment where you run your container

<a href="/assets/img/diagram/singularity-2.4-flow.png" target="_blank" class="no-after">
   <img style="max-width:900px" src="/assets/img/diagram/singularity-2.4-flow.png">
</a>

Singularity production images are immutable. This is a feature added as of Singularity 2.4, and it ensures a higher level of reproducibility and verification of images. To read more about the details, check out the  <a href="/build">bulid</a>docs. However, immutability is not so great when you are testing, debugging, or otherwise want to quickly change your image. We will proceed by describing a typical workflow of developing first, building a final image, and using in production. 

### 1. Development Commands
If you want a writable image or folder for developing, you have two options:

 1. build into a folder that has writable permissions with sudo
 2. build into an ext3 image file, also that has writable permissions with sudo and the `--writable` flag 

#### Sandbox Folder
To build into a folder (we call this a "sandbox") just ask for it:

```
sudo singularity build --sandbox ubuntu/ docker://ubuntu
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /root/.singularity/docker
Importing: base Singularity environment
Importing: /root/.singularity/docker/sha256:9fb6c798fa41e509b58bccc5c29654c3ff4648b608f5daa67c1aab6a7d02c118.tar.gz
Importing: /root/.singularity/docker/sha256:3b61febd4aefe982e0cb9c696d415137384d1a01052b50a85aae46439e15e49a.tar.gz
Importing: /root/.singularity/docker/sha256:9d99b9777eb02b8943c0e72d7a7baec5c782f8fd976825c9d3fb48b3101aacc2.tar.gz
Importing: /root/.singularity/docker/sha256:d010c8cf75d7eb5d2504d5ffa0d19696e8d745a457dd8d28ec6dd41d3763617e.tar.gz
Importing: /root/.singularity/docker/sha256:7fac07fb303e0589b9c23e6f49d5dc1ff9d6f3c8c88cabe768b430bdb47f03a9.tar.gz
Importing: /root/.singularity/metadata/sha256:22e289880847a9a2f32c62c237d2f7e3f4eae7259bf1d5c7ec7ffa19c1a483c8.tar.gz
Building image from sandbox: ubuntu/
Singularity container built: ubuntu/
```

We now have a folder with the entire ubuntu OS, plus some Singularity metadata, plopped in our present working directory.

```
 tree -L 1 ubuntu
ubuntu
├── bin
├── boot
├── dev
├── environment -> .singularity.d/env/90-environment.sh
├── etc
├── home
├── lib
├── lib64
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── singularity -> .singularity.d/runscript
├── srv
├── sys
├── tmp
├── usr
└── var
```

And you can shell into it just like a normal container. Without sudo, you don't have write permission:

```
singularity shell ubuntu
Singularity: Invoking an interactive shell within container...

Singularity ubuntu:~/Desktop> touch /hello.txt
touch: cannot touch '/hello.txt': Permission denied
```

With sudo, you do:

```
sudo singularity shell ubuntu
Singularity: Invoking an interactive shell within container...

Singularity ubuntu:/home/vanessa/Desktop> touch /hello.txt
```

#### Writable Image
If you don't want a folder, you can perform a similar development build and specify the `--writable` command.
This will produce an image that is writable with an ext3 file system. Unlike the sandbox, it is a single image file.

```
sudo singularity build --writable ubuntu.img docker://ubuntu
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /root/.singularity/docker
Importing: base Singularity environment
Importing: /root/.singularity/docker/sha256:9fb6c798fa41e509b58bccc5c29654c3ff4648b608f5daa67c1aab6a7d02c118.tar.gz
Importing: /root/.singularity/docker/sha256:3b61febd4aefe982e0cb9c696d415137384d1a01052b50a85aae46439e15e49a.tar.gz
Importing: /root/.singularity/docker/sha256:9d99b9777eb02b8943c0e72d7a7baec5c782f8fd976825c9d3fb48b3101aacc2.tar.gz
Importing: /root/.singularity/docker/sha256:d010c8cf75d7eb5d2504d5ffa0d19696e8d745a457dd8d28ec6dd41d3763617e.tar.gz
Importing: /root/.singularity/docker/sha256:7fac07fb303e0589b9c23e6f49d5dc1ff9d6f3c8c88cabe768b430bdb47f03a9.tar.gz
Importing: /root/.singularity/metadata/sha256:22e289880847a9a2f32c62c237d2f7e3f4eae7259bf1d5c7ec7ffa19c1a483c8.tar.gz
Building image from sandbox: /tmp/.singularity-build.VCHPpP
Creating empty Singularity writable container 130MB
Creating empty 162MiB image file: ubuntu.img
Formatting image with ext3 file system
Image is done: ubuntu.img
Building Singularity image...
Cleaning up...
Singularity container built: ubuntu.img
```

The same is true as the above, you can use any commands like `shell`, `exec`, `run`, and if you want a writable image you must use sudo  and the `--writable` flag.

```
sudo singularity shell --writable ubuntu.img
```

>> Development Tip! When building containers, it often is the case that you will have a lot of
testing of installation commands, and if building a production image, one error will stop the entire build. If you
interactively write the build recipe with one of these writable containers, you can debug as you go, and then
build the production (squashfs) container without worrying that it will error and need to be started again.

### 2. Production Commands
Let's set the scene - we just finished buliding our perfect hello world container. It does a fantastic hello-world analysis, and we have written a paper on it! We now want to build an immutable container - meaning that if someone obtained our container and tried to change it, they could not. They *could* easily use the same recipe that you used (it is provided as metadata inside the container), so your work can still be extended.

#### Recommended Production Build
What we want for production is a build into a <a href="https://en.wikipedia.org/wiki/SquashFS" target="_blank">squashfs image</a>. Squashfs is a read only, and compressed filesystem, and well suited for confident archive and re-use of your hello-world. To build a production image, just remove the extra options:

```
sudo singularity build ubuntu.simg docker://ubuntu
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /root/.singularity/docker
Importing: base Singularity environment
Importing: /root/.singularity/docker/sha256:9fb6c798fa41e509b58bccc5c29654c3ff4648b608f5daa67c1aab6a7d02c118.tar.gz
Importing: /root/.singularity/docker/sha256:3b61febd4aefe982e0cb9c696d415137384d1a01052b50a85aae46439e15e49a.tar.gz
Importing: /root/.singularity/docker/sha256:9d99b9777eb02b8943c0e72d7a7baec5c782f8fd976825c9d3fb48b3101aacc2.tar.gz
Importing: /root/.singularity/docker/sha256:d010c8cf75d7eb5d2504d5ffa0d19696e8d745a457dd8d28ec6dd41d3763617e.tar.gz
Importing: /root/.singularity/docker/sha256:7fac07fb303e0589b9c23e6f49d5dc1ff9d6f3c8c88cabe768b430bdb47f03a9.tar.gz
Importing: /root/.singularity/metadata/sha256:22e289880847a9a2f32c62c237d2f7e3f4eae7259bf1d5c7ec7ffa19c1a483c8.tar.gz
Building Singularity image...
Cleaning up...
Singularity container built: ubuntu.simg
```
You will also notice the extension `.simg`. This is the correct extension to designate a Singularity 2.4, production (squashfs) file.

#### Production Build from Sandbox
We understand that it might be wanted to build a Singularity (squashfs) from a previous development image. While we advocate for the first approach, we support this use case. To do this, given our folder called "ubuntu/" we made above:

```
sudo singularity build ubuntu.simg ubuntu/
```
It could be the case that a cluster maintains a "working" base of container folders (with writable) and then builds and provides production containers to its users.


### Interacting with Images
Once you have your image, you can interact with it in several ways! We will go over the basics.

#### Shell
Now let's go back to the `hello.img` we created, and shell inside.

```bash
singularity shell hello.img
Singularity: Invoking an interactive shell within container...

# I am the same user inside as outside!
Singularity centos7.img:~/Desktop> whoam
vanessa

Singularity centos7.img:~/Desktop> id
uid=1000(vanessa) gid=1000(vanessa) groups=1000(vanessa),4(adm),24,27,30(tape),46,113,128,999(input)
```

and as we pointed out earlier, this would work also with a `shub://` or `docker://` URI, to specify a Singularity or Docker Registry served image:

```
singularity shell docker://ubuntu
singularity shell shub://vsoch/hello-world
```

Shell is good for quick inspection, if you don't intend or need to keep the image. Want to keep the container's environment contained, meaning no sharing of host environment?

```
singularity shell --contain hello.img
```

#### Executing Commands
Singularity `exec` will send a custom command for the container to run, anything that you like! Unlike docker exec, a container doesn't have to be actively running. Exec works as it would to execute a script. It runs, and then exists upon completion. So, to list the root of the image (`/`), we could do the following:

```bash
singularity exec vsoch-hello-world-master.img ls /
anaconda-post.log  etc	 lib64	     mnt   root  singularity  tmp
bin		   home  lost+found  opt   run	 srv	      usr
dev		   lib	 media	     proc  sbin  sys	      var
```

#### Working with Files

Files on the host can be reachable from within the container

```bash
echo "Hello World" > $HOME/hello-kitty.txt
singularity exec singularity exec vsoch-hello-world-master.img cat $HOME/hello-kitty.txt
Hello World
```
If you want to add files to the container, you would build from a <a href="/docs-recipes">recipe</a> instead.

#### Mounting
By default, most configurations will mount `/tmp` and the home directories by default. On a research cluster, you probably want to access locations with big datasets, and then write results too. For this, you will want to bind a folder to the container. Here, we are binding my Desktop to `/opt` in the image, and listing the contents to show it worked. We use the command `-B` or `--bind` to do this.

```bash
$ singularity exec --bind /home/vanessa/Desktop:/opt hello.img ls /opt
hello.img	     researchapps-matlab-sherlock-master.img
hello-kitty.txt      singularity-recipe-demo.mp4
party_dinosaur.gif
````


### Singularity Recipes
For a reproducible container, the recommended practice is to build by way of a Singularity recipe file. This also makes it easy to add files, environment variables, and install custom software, and still start from your base of choice (e.g., Docker). The absolute minimum required for a recipe is a base, and here are your options:

**Singularity Hub**
```
Bootstrap: shub
From: vsoch/hello-world
```

**Docker**

```
Bootstrap: docker
From: tensorflow/tensorflow:latest
IncludeCmd: yes # Use the CMD as runscript instead of ENTRYPOINT
```

**YUM/RHEL**
```
Bootstrap: yum
OSVersion: 7
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/$basearch/
Include: yum
```

**Debian/Ubuntu**

```
Bootstrap: debootstrap
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/
```

**Self**

```
Bootstrap: self
```

**Local Image**

```
Bootstrap: localimage
From: /home/dave/starter.img 
```

So many choices! Note that for the debootstrap and bases that require a mirror, you might run into issues of needing additional software on the host (e.g., debootstrap). If you have trouble, you can always fall back to using a Docker base.

Thus, based on the above, the minimum requirement for a Boostrap file is this header section, in a file named `Singularity`:


```bash
Bootstrap: docker
From: ubuntu:latest
```

and then you build the container from it:

```
sudo singularity build ubuntu.simg Singularity
```

#### Singularity Recipe File

If you intend to use Singularity Hub (version 2.0 to be released after Singularity 2.4) then you might want to know the convention of specifying a tag for a container recipe in the format `Singularity.<tagname>`:

 - Singularity.dev
 - Singularity  (implies "latest")
 - Singularity.v10

These files located anywhere in a repo connected to Singularity Hub will build images with these respective tags. If two identical tags are found, the newer file takes preference.

#### Singularity Recipe Example
Now let's create a simple recipe. We want to add some custom installation steps (`%post`), along with environment and labels.

```bash
Bootstrap: docker
From: ubuntu:latest

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

The above recipe can then be built as we specified before:

```bash
sudo singularity build ubuntu.simg Singularity
```

If you want to go through this entire process without having singularity installed locally, or without leaving your cluster, you can build images using <a href="https://github.com/singularityhub/singularityhub.github.io/wiki" target="_blank">singularity hub.</a>

{% include links.html %}
