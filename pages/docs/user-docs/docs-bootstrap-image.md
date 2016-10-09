---
title: Getting Started with Bootstrap
sidebar: user_docs
permalink: docs-bootstrap
folder: docs
---

## Bootstrapping a Container
Bootstrapping is the process where we install an operating system and then configure it appropriately for a specified need. To do this we use a bootstrap definition file which is a recipe of how to specifically build the container and explained in detail in the previous section.

For the purpose of this example, we will use the portions of the bootstrap definition file above, and assemble it into a complete definition file:

```
# Bootstrap definition example for Centos-7 with the latest Open MPI from GitHub master

BootStrap: yum
OSVersion: 7
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/$basearch/
Include: yum

%setup
    echo "Looking in directory '$SINGULARITY_ROOTFS' for /bin/sh"
    if [ ! -x "$SINGULARITY_ROOTFS/bin/sh" ]; then
        echo "Hrmm, this container does not have /bin/sh installed..."
        exit 1
    fi
    exit 0

%post
	echo "Installing Development Tools YUM group"
	yum -y groupinstall "Development Tools"
	echo "Installing OpenMPI into container..."
	mkdir /tmp/git
	cd /tmp/git
	git clone https://github.com/open-mpi/ompi.git
	cd ompi
	./autogen.pl
	./configure --prefix=/usr/local
	make
	make install
	/usr/local/bin/mpicc examples/ring_c.c -o /usr/bin/mpi_ring
	cd /
	rm -rf /tmp/git
	exit 0

%runscript
	echo "Arguments received: $*"
	exec /usr/bin/python "$@"

%test
	/usr/local/bin/mpirun --allow-run-as-root /usr/bin/mpi_ring

```

Taking this particular definition file as the example, we can use this to create our container.

The Singularity bootstrap command syntax is as follows:

```bash
$ singularity bootstrap
USAGE: singularity [...] bootstrap <container path> <definition file>
```

The `<container path>` is the path to the Singularity image file, and the `<definition file>` is the location of the definition file (the recipe) we will use to create this container. The process of building a container should always be done by root so that the correct file ownership and permissions are maintained. Also, so installation programs check to ensure they are the root user before proceeding. The bootstrap process may take anywhere from one minute to one hour depending on what needs to be done and how fast your network connection is.

Here are the steps necessary to create a container using the above definition file:

```bash
$ sudo singularity create --size 2048 /tmp/Centos7-ompi.img
Creating a new image with a maximum size of 2048MiB...
Executing image create helper
Formatting image with ext3 file system
Done.
$ sudo singularity bootstrap /tmp/Centos7-ompi.img centos7-ompi_master.def 
Bootstrap initialization
Checking bootstrap definition
Executing Prebootstrap module
Executing Bootstrap 'yum' module

...

+ /usr/local/bin/mpicc examples/ring_c.c -o /usr/bin/mpi_ring
+ cd /
+ rm -rf /tmp/git
+ exit 0
+ /usr/local/bin/mpirun --allow-run-as-root /usr/bin/mpi_ring
Process 0 sending 10 to 1, tag 201 (4 processes in ring)
Process 0 sent to 1
Process 0 decremented value: 9
Process 0 decremented value: 8
Process 0 decremented value: 7
Process 0 decremented value: 6
Process 0 decremented value: 5
Process 0 decremented value: 4
Process 0 decremented value: 3
Process 0 decremented value: 2
Process 0 decremented value: 1
Process 0 decremented value: 0
Process 0 exiting
Process 1 exiting
Process 2 exiting
Process 3 exiting
```

You can see from the output above, that the container has been built and the `%test` section has executed as expected. Our container has now been bootstrapped.

<br>For more <strong>examples</strong> we recommend that you look at the <a href="{{ site.repo}}/tree/master/examples" target="_blank">examples</a> folder for the most up-to-date examples.
