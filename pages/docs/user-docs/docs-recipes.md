---
title: The Singularity Recipe
sidebar: user_docs
permalink: docs-recipes
toc: false
folder: docs
---

A Singularity Recipe is the driver of a custom build, and the starting point for designing any custom container. It includes specifics about installation software, environment variables, files to add, and container metadata. You can even write a help section, or define modular components in the container called <a href="/apps"></a> based on the <a href="https://containers-ftw.github.io/SCI-F/" target="_blank">Standard Container Integration Format (SCI-F)</a>.

{% include toc.html %}

## Overview

A Singularity Recipe file is divided into several parts:

1. **Header**: The Header describes the core operating system to build within the container. Here you will configure the base operating system features that you need within your container. Examples of this include, what distribution of Linux, what version, what packages must be part of a core install.
2. **Sections**: The rest of the definition is comprised of sections, sometimes called scriptlets or blobs of data. Each section is defined by a `%` character followed by the name of the particular section. All sections are optional. Sections that are executed at build time are executed with the `/bin/sh` interpreter and can accept `/bin/sh` options.  Similarly, sections that produce scripts to be executed at runtime can accept options intended for `/bin/sh`

Please see the [examples](https://github.com/singularityware/singularity/tree/master/examples) directory in the [Singularity source code](https://github.com/singularityware/singularity) for some ideas on how to get started. 

### Header
The header is at the top of the file, and tells Singularity the base Operating System that it should use to build the container.  It is composed of several keywords. Specifically:

 - `Bootstrap:` references the kind of base you want to use (e.g., docker, debootstrap, shub). For example, a shub bootstrap will pull containers for shub as bases. A Docker bootstrap will pull docker layers to start your image. For a full list see [build](docs-build-container)
 - `From:` is the named container (shub) or reference to layers (Docker) that you want to use (e.g., vsoch/hello-world)

Depending on the value assigned to `Bootstrap:`, other keywords may also be valid in the header.

For example, a very minimal Singularity Hub build might look like this:

```
Bootstrap: shub
From: vsoch/hello-world
```

A build that uses a mirror to install Centos-7 might look like this:

```
Bootstrap: yum
OSVersion: 7
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/$basearch/
Include: yum
```

Each build base requires particular details during build time.  You can read about them and see examples at the following links:

 - [shub](/build-shub) (images hosted on Singularity Hub)
 - [docker](/build-docker-module) (images hosted on Docker Hub)
 - [localimage](/build-localimage) (images saved on your machine)
 - [yum](/build-yum) (yum based systems such as CentOS and Scientific Linux)
 - [debootstrap](/build-debootstrap) (apt based systems such as Debian and Ubuntu)
 - [arch](/build-arch) (Arch Linux)
 - [busybox](/build-busybox) (BusyBox)
 - [zypper](/build-zypper) (zypper based systems such as Suse and OpenSuse)


### Sections
The main content of the bootstrap file is broken into sections. Different sections add different content or execute commands at different times during the build process.  Note that if any command fails, the build process will halt.

Let's add each section to our container to see how it works. For each section, we will build the container from the recipe (a file called Singularity) as follows:

```
$ sudo singularity build roar.simg Singularity
```

#### %help
You don't need to do much programming to add a `%help` section to your container. Just write it into a section:

```
Bootstrap: docker
From: ubuntu

%help
Help me. I'm in the container.
```

And it will work when the user asks the container for help.

```
$ singularity help roar.simg 

Help me. I'm in the container.
```

#### %setup
Commands in the `%setup` section are executed on the host system outside of the container after the base OS has been installed.  For versions earlier than 2.3 if you need files during `%post`, you should copy files from your host to `$SINGULARITY_ROOTFS` to move them into the container. For >2.3 you can add files to the container (added before `%post`) using the `%files` section. We can see the difference between `%setup` and `%post` in the following asciicast:

{% include asciicast.html source='docs-bootstrap-setup-vs-post.json' uid='container-setup-vs-post' title='How does the container see setup vs post?' author='vsochat@stanford.edu'%}

In the above, we see that copying something to `$SINGULARITY_ROOTFS` during `%setup` was successful to move the file into the container, but copying during `%post` was not. Let's add a setup to our current container, just writing a file to the root of the image:

```
Bootstrap: docker
From: ubuntu

%help
Help me. I'm in the container.

%setup
    touch ${SINGULARITY_ROOTFS}/tacos.txt
    touch avocados.txt
```

Importantly, notice that the avocados file isn't relative to `$SINGULARITY_ROOTFS`, so we would expect it not to be in the image. Is tacos there?

```
$ singularity exec roar.simg ls /
bin   environment  lib	  mnt	root  scif	   sys	      usr
boot  etc	   lib64  opt	run   singularity  **tacos.txt**  var
dev   home	   media  proc	sbin  srv	   tmp
```

Yes! And avocados.txt isn't inside the image, but in our present working directory:

```
$ ls
avocados.txt   roar.simg   Singularity
```


#### %files
If you want to copy files from your host system into the container, you should do so using the `%files` section.  Each line is a pair of `<source>` and `<destination>`, where the source is a path on your host system, and the destination is a path in the container. 

The `%files` section uses the traditional `cp` command, so the <a href="https://linux.die.net/man/1/cp" target="_blank">same conventions apply</a>. 

Files are copied **before** any `%post` or installation procedures for Singularity versions > 2.3. If you are using a legacy version, files are copied after `%post` so you must do this via `%setup`. Let's add the avocado.txt into the container, to join tacos.txt.

```
Bootstrap: docker
From: ubuntu

%help
Help me. I'm in the container.

# Both of the below are copied before %post
# 1. This is how to copy files for legacy < 2.3
%setup
    touch ${SINGULARITY_ROOTFS}/tacos.txt
    touch avocados.txt

# 2. This is how to copy files for >= 2.3
%files
    avocados.txt
    avocados.txt /opt
```
Notice that I'm adding the same file to two different places. For the first, I'm adding the single file to the root of the image. For the second, I'm adding it to opt. Does it work?

```
$ singularity exec roar.simg ls /
 singularity exec roar.simg ls /
**avocados.txt**  dev	   home   media  proc  sbin	    srv        tmp
bin	      environment  lib	  mnt	 root  scif	    sys        usr
boot	      etc	   lib64  opt	 run   singularity  **tacos.txt**  var

$ singularity exec roar.simg ls /opt
**avocados.txt**

```

We have avocados!

#### %labels
To store metadata with your container, you can add them to the `%labels` section. They will be stored in the file `/.singularity.d/labels.json` as metadata within your container. The general format is a `LABELNAME` followed by a `LABELVALUE`. Labels from Docker bootstraps will be carried forward here. Let's add to our example:

```
Bootstrap: docker
From: ubuntu

%help
Help me. I'm in the container.

%setup
    touch ${SINGULARITY_ROOTFS}/tacos.txt
    touch avocados.txt

%files
    avocados.txt
    avocados.txt /opt    

%labels
    Maintainer Vanessasaurus
    Version v1.0
```
The easiest way to see labels is to inspect the image:

```
$ singularity inspect roar.simg
{
    "org.label-schema.usage.singularity.deffile.bootstrap": "docker",
    "MAINTAINER": "Vanessasaurus",
    "org.label-schema.usage.singularity.deffile": "Singularity",
    "org.label-schema.usage": "/.singularity.d/runscript.help",
    "org.label-schema.schema-version": "1.0",
    "VERSION": "v1.0",
    "org.label-schema.usage.singularity.deffile.from": "ubuntu",
    "org.label-schema.build-date": "2017-10-02T17:00:23-07:00",
    "org.label-schema.usage.singularity.runscript.help": "/.singularity.d/runscript.help",
    "org.label-schema.usage.singularity.version": "2.3.9-development.g3dafa39",
    "org.label-schema.build-size": "1760MB"
}
```

You'll notice some other labels that are captured automatically from the build process. You can read more about labels and metadata <a href="/docs-environment-metadata">here</a>.


#### %environment
As of Singularity 2.3, you can add environment variables to your Singularity Recipe in a section called `%environment`. Keep in mind that these environment variables are sourced at runtime and *not* at build time. This means that if you need the same variables during build time, you should also define them in your `%post` section. Specifically:

 - **during build**: the `%environment` section is written to a file in the container's metadata folder. This file is not sourced.
 - **during runtime**: the file written to the container's metadata folder is sourced.

Since the file is ultimately sourced, you should generally use the same conventions that you might use in a `bashrc` or `profile`. In the example below, the variables `VADER` `LUKE` and `SOLO` would not be available during build, but when the container is finished and run: 

```
Bootstrap: docker
From: ubuntu

%help
Help me. I'm in the container.

%setup
    touch ${SINGULARITY_ROOTFS}/tacos.txt
    touch avocados.txt

%files
    avocados.txt
    avocados.txt /opt    

%labels
    Maintainer Vanessasaurus
    Version v1.0

%environment
    VADER=badguy
    LUKE=goodguy
    SOLO=someguy
    export VADER LUKE SOLO
```

For the rationale behind this approach and why we do not source the `%environment` section at build time, refer to <a href="https://github.com/singularityware/singularity/issues/1053" target="_blank">this issue</a>. When the container is finished, you can easily see environment variables also with inspect, and this is done by showing the file produced above:

```
$ singularity inspect -e roar.simg # Custom environment shell code should follow

    VADER=badguy
    LUKE=goodguy
    SOLO=someguy
    export VADER LUKE SOLO

```

or in the case of variables generated at build time, you can add environment variables to your container in the `%post` section (see below) using the following syntax:

```
%post
    echo 'export JAWA_SEZ=wutini' >> $SINGULARITY_ENVIRONMENT
```

When we rebuild, is it added to the environment?

```
singularity exec roar.simg env | grep JAWA
JAWA_SEZ=wutini
```

Where are all these environment variables going? Inside the container is a metadata folder located at `/.singularity.d`, and a subdirectory `env` for environment scripts that are sourced. Text in the `%environment` section is appended to a file called `/.singularity.d/env/90-environment.sh`.  Text redirected to the `$SINGULARITY_ENVIRONMENT` variable will added to a file called `/.singularity.d/env/91-environment.sh`.  At runtime, scripts in `/.singularity/env` are sourced in order. This means that variables in `$SINGULARITY_ENVIRONMENT` take precedence over those added via `%environment`. Note that you won't see these variables in the inspect output, as inspect only shows the contents added from `%environment`.

See <a href="/docs-environment-metadata">Environment and Metadata</a> for more information about the `%labels` and `%environment` sections.


#### %post
Commands in the `%post` section are executed within the container after the base OS has been installed at build time. This is where the meat of your setup will live, including making directories, and installing software and libraries. We will jump from our simple use case to show a more realistic scientific container. Here we are installing yum, openMPI, and other dependencies for a Centos7 bootstrap:

```
%post
    echo "Installing Development Tools YUM group"
    yum -y groupinstall "Development Tools"
    echo "Installing OpenMPI into container..."

    # Here we are at the base, /, of the container
    git clone https://github.com/open-mpi/ompi.git

    # Now at /ompi
    cd ompi
    ./autogen.pl
    ./configure --prefix=/usr/local
    make
    make install

    /usr/local/bin/mpicc examples/ring_c.c -o /usr/bin/mpi_ring
```

You cannot copy files from the host to your container in this section, but you can of course download with commands like `git clone` and `wget` and `curl`.


#### %runscript
The `%runscript` is another scriptlet, but it does not get executed during bootstrapping. Instead it gets persisted within the container to a file (or symlink for later versions) called `/singularity` which is the execution driver when the container image is ***run*** (either via the `singularity run` command or via executing the container directly).

When the `%runscript` is executed, all options are passed along to the executing script at runtime, this means that you can (and should) manage argument processing from within your runscript. Here is an example of how to do that, adding to our work in progress:

```
Bootstrap: docker
From: ubuntu

%help
Help me. I'm in the container.

%setup
    touch ${SINGULARITY_ROOTFS}/tacos.txt
    touch avocados.txt

%files
    avocados.txt
    avocados.txt /opt    

%labels
    Maintainer Vanessasaurus
    Version v1.0

%environment
    VADER=badguy
    LUKE=goodguy
    SOLO=someguy
    export VADER LUKE SOLO


%post
    echo 'export JAWA_SEZ=wutini' >> $SINGULARITY_ENVIRONMENT

%runscript
    echo "Rooooar!"
    echo "Arguments received: $*"
    exec echo "$@"
```

In this particular runscript, the arguments are printed as a single string (`$*`) and then they are passed to `echo` via a quoted array (`"$@"`) which ensures that all of the arguments are properly parsed by the executed command. Using the `exec` command is like handing off the calling process to the one in the container. The final command (the echo) replaces the current entry in the process table (which originally was the call to Singularity). This makes it so the runscript shell process ceases to exist, and the only process running inside this container is the called echo command. This could easily be another program like python, or an analysis script. Running it, it works as expected:

```
$ singularity run roar.simg 
Rooooar!
Arguments received: 

$ singularity run roar.simg one two
Rooooar!
Arguments received: one two
one two
```

#### %test
You may choose to add a `%test` section to your definition file. This section will be run at the very end of the build process and will give you a chance to validate the container during the bootstrap process. You can also execute this scriptlet through the container itself, such that you can always test the validity of the container itself as you transport it to different hosts. Extending on the above Open MPI `%post`, consider this real world example:

```
%test
    /usr/local/bin/mpirun --allow-run-as-root /usr/bin/mpi_test
```

This is a simple Open MPI test to ensure that the MPI is build properly and communicates between processes as it should.

If you want to build without running tests (for example, if the test needs to be done in a different environment), you can do so with the `--notest` argument:

```
$ sudo singularity build --notest mpirun.simg Singularity
```

This argument is useful in cases where you need hardware that is available during runtime, but is not available on the host that is building the image.


## Apps
What if you want to build a single container with two or three different apps that each have thier own runscripts and custom environments? In some circumstances, it may be redundant to build different containers for each app with almost equivalent dependencies. 

Starting in Singularity 2.4 all of the above commands can also be used in the context of internal modules called <a href="/docs-apps">apps</a> based on the <a href="http://containers-ftw.org/SCI-F/" target="_blank">Standard Container Integration Format</a>. For details on apps, see the <a href="/docs-apps">apps</a> documentation. For a quick rundown of adding an app to your container, here is an example runscript:

```
Bootstrap: docker
From: ubuntu

%environment
    VADER=badguy
    LUKE=goodguy
    SOLO=someguy
    export VADER LUKE SOLO

%labels
   Maintainer Vanessasaur

##############################
# foo
##############################

%apprun foo
    exec echo "RUNNING FOO"

%applabels foo
   BESTAPP=FOO
   export BESTAPP

%appinstall foo
   touch foo.exec

%appenv foo
    SOFTWARE=foo
    export SOFTWARE

%apphelp foo
    This is the help for foo.

%appfiles foo
   avocados.txt


##############################
# bar
##############################

%apphelp bar
    This is the help for bar.

%applabels bar
   BESTAPP=BAR
   export BESTAPP

%appinstall bar
    touch bar.exec

%appenv bar
    SOFTWARE=bar
    export SOFTWARE
```

Importantly, note that the apps can exist alongside any and all of the primary sections (e.g. `%post` or `%runscript`), and the new `%appinstall` section is the equivalent of `%post` but for an app. The title sections (`######`) aren't necessary or required, they are just comments to show you the different apps. The ordering isn't important either, you can have any mixture of sections anywhere in the file after the header. The primary difference is now the container can perform any of it's primary functions in the context of an app:


**What apps are installed in the container?**
```
$ singularity apps roar.simg 
bar
foo
```

**Help me with bar!**
```
$ singularity help --app bar roar.simg
This is the help for bar.
```

**Run foo**
```
singularity run --app foo roar.simg 
RUNNING FOO
```

**Show me the custom environments**
Remember how we defined the same environment variable, `SOFTWARE` for each of foo and bar? We can execute a command to search the list of active environment variables with grep to see if the variable changes depending on the app we specify:

```
$ singularity exec --app foo roar.simg env | grep SOFTWARE
SOFTWARE=foo
$ singularity exec --app bar roar.simg env | grep SOFTWARE
SOFTWARE=bar
```

## Examples
For more examples, for real world scientific recipes we recommend you look at other containers on <a href="https://singularity-hub.org" target="_blank">Singularity Hub</a>. For examples of different bases, look at the <a href="{{ site.repo}}/tree/master/examples" target="_blank">examples</a> folder for the most up-to-date examples. For apps, including snippets and tutorial with more walk throughts, see <a href="http://containers-ftw.org/apps/" target="_blank">SCI-F Apps Home</a>.


## Best Practices for Build Recipes
When crafting your recipe, it is best to consider the following:

1. To make your container internally modular, use <a href="/docs-scif-apps">SCI-F apps</a>. Shared dependencies (between app modules) can go under `%post`.
2. For global installs to `%post`, install packages, programs, data, and files into operating system locations (e.g. not `/home`, `/tmp`, or any other directories that might get commonly binded on).
3. Make your container speak for itself. If your runscript doesn't spit out help, write a `%help` or `%apphelp` section. A good container tells the user how to interact with it.
4. If you require any special environment variables to be defined, add them the `%environment` and `%appenv` sections of the build recipe.
5. Files should never be owned by actual users, they should always be owned by a system account (UID less than 500).
6. Ensure that the container's `/etc/passwd`, `/etc/group`, `/etc/shadow`, and no other sensitive files have anything but the bare essentials within them.
7. It is encouraged to build containers from a recipe instead of a sandbox that has been manually changed. This ensures greatest possibility of reproducibility and mitigates the *black box effect*.

Are you a recipe pro and now ready to build? Take a look at the [build](docs-build-container) documentation.
