---
title: Getting Started with Bootstrap
sidebar: user_docs
permalink: bootstrap-image
folder: docs
toc: false
---

Bootstrapping is the process where we install an operating system and then configure it appropriately for a specified need. To do this we use a bootstrap definition file (a text file called `Singularity`) which is a recipe of how to specifically build the container. Here we will overview the sections, best practices, and a quick example.

{% include toc.html %}


## Quick Start
Too long... didn't read! If you want the quickest way to run bootstrap, here is the usage:

```bash
$ singularity bootstrap
USAGE: singularity [...] bootstrap <container path> <definition file>
```

The `<container path>` is the path to the Singularity image file, and the `<definition file>` is the location of the definition file (the recipe) we will use to create this container. The process of building a container should always be done by root so that the correct file ownership and permissions are maintained. Also, so installation programs check to ensure they are the root user before proceeding. The bootstrap process may take anywhere from one minute to one hour depending on what needs to be done and how fast your network connection is.
 

Let's continue with our quick start example. Here is your spec file, `Singularity`,


```bash
Bootstrap:docker
From:ubuntu:latest
```

You next create an image:

```bash
$ singularity create ubuntu.img
Initializing Singularity image subsystem
Opening image file: ubuntu.img
Creating 768MiB image
Binding image to loop
Creating file system within image
Image is done: ubuntu.img
```

and finally run the bootstrap command, pointing to your image (`<container path>`) and the file `Singularity` (`<definition file>`).

```bash
$ sudo singularity  bootstrap ubuntu.img Singularity 
Sanitizing environment
Building from bootstrap definition recipe
Adding base Singularity environment to container
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /root/.singularity/docker
[5/5] |===================================| 100.0% 
Exploding layer: sha256:b6f892c0043b37bd1834a4a1b7d68fe6421c6acbc7e7e63a4527e1d379f92c1b.tar.gz
Exploding layer: sha256:55010f332b047687e081a9639fac04918552c144bc2da4edb3422ce8efcc1fb1.tar.gz
Exploding layer: sha256:2955fb827c947b782af190a759805d229cfebc75978dba2d01b4a59e6a333845.tar.gz
Exploding layer: sha256:3deef3fcbd3072b45771bd0d192d4e5ff2b7310b99ea92bce062e01097953505.tar.gz
Exploding layer: sha256:cf9722e506aada1109f5c00a9ba542a81c9e109606c01c81f5991b1f93de7b66.tar.gz
Exploding layer: sha256:fe44851d529f465f9aa107b32351c8a0a722fc0619a2a7c22b058084fac068a4.tar.gz
Finalizing Singularity container
```

Notice that bootstrap does require sudo. If you do an import, with a docker uri for example, you would see a similar flow, but the calling user would be you, and the cache your `$HOME`.

```bash
$singularity create ubuntu.img
singularity import ubuntu.img docker://ubuntu:latest
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /home/vanessa/.singularity/docker
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:b6f892c0043b37bd1834a4a1b7d68fe6421c6acbc7e7e63a4527e1d379f92c1b.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:55010f332b047687e081a9639fac04918552c144bc2da4edb3422ce8efcc1fb1.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:2955fb827c947b782af190a759805d229cfebc75978dba2d01b4a59e6a333845.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:3deef3fcbd3072b45771bd0d192d4e5ff2b7310b99ea92bce062e01097953505.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:cf9722e506aada1109f5c00a9ba542a81c9e109606c01c81f5991b1f93de7b66.tar.gz
Importing: /home/vanessa/.singularity/metadata/sha256:fe44851d529f465f9aa107b32351c8a0a722fc0619a2a7c22b058084fac068a4.tar.gz
```


## Best Practices for Bootstrapping
When bootstrapping a container, it is best to consider the following:

1. Install packages, programs, data, and files into operating system locations (e.g. not `/home`, `/tmp`, or any other directories that might get commonly binded on).
2. Make your container speak for itself. A good runscript will spit out usage, variables, and tell the user how to interact with the container.
3. If you require any special environment variables to be defined, add them the `%environment` section of the bootstrap recipe.
4. Files should never be owned by actual users, they should always be owned by a system account (UID < 500).
5. Ensure that the container's `/etc/passwd`, `/etc/group`, `/etc/shadow`, and no other sensitive files have anything but the bare essentials within them.
6. Do all of your bootstrapping via a definition file instead of manipulating the containers by hand (with the `--writable` options), this ensures greatest possibility of reproducibility and mitigates the *black box effect*.



## The Bootstrap Definition File
There are multiple sections of the Singularity bootstrap definition file:

1. **Header**: The Header describes the core operating system to bootstrap within the container. Here you will configure the base operating system features that you need within your container. Examples of this include, what distribution of Linux, what version, what packages must be part of a core install.
2. **Sections**: The rest of the definition is comprised of sections or blobs of data. Each section is defined by a `%` character followed by the name of the particular section. All sections are optional.


### Header
The header is at the top of the file, and tells Singularity the kind of bootstrap, and from where. For example, a very minimal Docker bootstrap might look like this:


```bash
Bootstrap: docker
From: ubuntu:latest
```

a Bootstrap that uses a mirror to install Centos-7 might look like this:


```bash
BootStrap: yum
OSVersion: 7
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/$basearch/
Include: yum
```

For complete details about header fields that are allowed, please see the <a href="/docs-bootstrap">Bootstrap Command</a>. We will continue here with higher level overview.


### Sections
The main content of the bootstrap file is broken into sections.

#### %setup
Setup is where you might perform actions on the host before we move into the container. For versions earlier than 2.3, or if you need files during `%post`, you should copy files from your host to `$SINGULARITY_ROOTFS` to move them into the container. For 2.3 and cases when you don't need the files until after `%post`, we recommend you use `%files`. We can see the difference between `%setup` and `%post` in the following asciicast:

{% include asciicast.html source='docs-bootstrap-setup-vs-post.json' title='How does the container see setup vs post?' author='vsochat@stanford.edu'%}

In the above, we see that copying something to `$SINGULARITY_ROOTFS` during `%setup` was successful to move the file into the container, but copying during `%post` was not.

#### %files
Speaking of files, if you want to copy content into the container, you should do so using the `%files` section, where each is a pair of `<source>` and `<destination>`, where the file or expression to be copied is a path on your host, and the destination is a path in the container. Here we are using the traditional `cp` command, so the <a href="https://linux.die.net/man/1/cp" target="_blank">same conventions apply</a>. Note that the `%files` section is executed **after** `%post`, so if you need files before that, the current workaround is to copy your files from the host to `$SINGULARITY_ROOTFS` in the `%setup` section. We plan to change this to make different sections for pre and post files in Singularity 2.4, and please comment <a href="https://github.com/singularityware/singularity/issues/674" target="_blank">here</a> if you have thoughts or suggestions.

#### %labels
To store metadata with your container, you can add them to the `%labels` section. They will be stored in a file `/.singularity.d/labels.json` as metadata with your container. The general format is a `LABELNAME` followed by a `LABELVALUE`. Labels from Docker bootstraps will be carried forward here. As an example:

```bash
%labels
Maintainer vsochat@stanford.edu
Version 2.0
```

#### %environment
You can add environment variables to be sourced when the container is used in the `%environment` section. The entire section is written to a file that gets sourced, so you should generally use the same conventions that you might use in a `bashrc` or `profile`. 

```
%environment
    export VADER=badguy
    export LUKE=goodguy
    export SOLO=someguy
```

See <a href="/docs-environment-metadata">Environment and Metadata</a> for more information about the `%labels` and `%environment` sections.


#### %post
This scriptlet will be run from inside the container. This is where the guts of your setup will live, including making directories, and installing software and libraries. For example, here we are installing yum, openMPI, and other dependencies for a Centos7 bootstrap:

```bash
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
The `%runscript` is another scriptlet, but it does not get executed during bootstrapping. Instead it gets persisted within the container to a file called `/singularity` which is the execution driver when the container image is ***run*** (either via the `singularity run` command or via executing the container directly).

When the `%runscript` is executed, all options are passed along to the executing script at runtime, this means that you can (and should) manage argument processing from within your runscript. Here is an example of how to do that:

```bash
%runscript
    echo "Arguments received: $*"
    exec /usr/bin/python "$@"
```

In this particular runscript, the arguments are printed as a single string (`$*`) and then they are passed to `/usr/bin/python` via a quoted array (`$@`) which ensures that all of the arguments are properly parsed by the executed command. The `exec` command causes the given command to replace the current entry in the process table with the one that is to be called. This makes it so the runscript shell process ceases to exist, and the only process running inside this container is the called Python command.

#### %test
You may choose to add a `%test` section to your definition file. This section will be run at the very end of the boostrapping process and will give you a chance to validate the container during the bootstrap process. You can also execute this scriptlet through the container itself, such that you can always test the validity of the container itself as you transport it to different hosts. Extending on the above Open MPI `%post`, consider this example:

```bash
%test
    /usr/local/bin/mpirun --allow-run-as-root /usr/bin/mpi_test
```

This is a simple Open MPI test to ensure that the MPI is build properly and communicates between processes as it should.

If you want to bootstrap without running tests, you can do so with the `--notest` argument:

```bash
$ sudo singularity bootstrap --notest container.img Singularity
```

This argument might be useful in cases where you might need hardware that is available during runtime, but is not available on the host that is building the image.


## Examples
For more examples, we recommend you look at other containers on <a href="https://singularity-hub.org" target="_blank">Singularity Hub</a>. For more <strong>examples</strong> we recommend that you look at the <a href="{{ site.repo}}/tree/master/examples" target="_blank">examples</a> folder for the most up-to-date examples.
