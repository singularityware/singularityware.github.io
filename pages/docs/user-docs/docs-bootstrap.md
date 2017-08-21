---
title: The Bootstrap Definition
sidebar: user_docs
permalink: docs-bootstrap
toc: false
folder: docs
---

The process of *bootstrapping* a Singularity container is equivalent to describing a recipe for the container creation. There are several recipe formats that Singularity supports, but only the primary format of version 2.3 will be documented here. If you want a general overview with examples, see <a href="/bootstrap-image">Bootstrapping an Image</a>. The detailed options for each of the header and sections are provided here.

{% include toc.html %}

## The header fields:

### Bootstrap:
The `Bootstrap: ` keyword identifies the Singularity module that will be used for building the core components of the operating system. There are several supported modules at the time of this writing:

##### **yum**

The YUM bootstrap module uses YUM on the host system to bootstrap the core operating system that exists within the container. This module is applicable for bootstrapping distributions like Red Hat, Centos, and Scientific Linux. When using the `yum` bootstrap module, several other keywords may also be necessary to define:

 - **MirrorURL**: This is the location where the packages will be downloaded from. When bootstrapping different RHEL/YUM compatible distributions of Linux, this will define which variant will be used (e.g. the only difference in bootstrapping Centos from Scientific Linux is this line.
 - **OSVersion**: When using the `yum` bootstrap module, this keyword is conditional and required only if you have specified a %{OSVERSION} variable name in the `MirrorURL` keyword. If the `MirrorURL` definition does not have the %{OSVERSION} variable, `OSVersion` can be omitted from the header field.
 - **Include**: By default the core operating system is an extremely minimal base, which may or may not include the means to even install additional packages. The `Include` keyword should define any additional packages which should be used and installed as part of the core operating system bootstrap. The best practice is to keep this keyword usage as minimal as possible such that you can then use the `%inside` scriptlet (explained shortly) to do additional installations. One common package you may want to include here is `yum` itself.

Warning, there is a major limitation with using YUM to bootstrap a container and that is the RPM database that exists within the container will be created using the RPM library and Berkeley DB implementation that exists on the host system. If the RPM implementation inside the container is not compatible with the RPM database that was used to create the container, once the container has been created RPM and YUM commands inside the container may fail. This issue can be easily demonstrated by bootstrapping an older RHEL compatible image by a newer one (e.g. bootstrap a Centos 5 or 6 container from a Centos 7 host).

##### **debootstrap**
The Debian bootstrap module is a tool which is used specifically for bootstrapping distributions which utilize the `.deb` package format and `apt-get` repositories. This module will bootstrap any of the Debian and Ubuntu based distributions. When using the `debootstrap` module, the following keywords must also be defined:

 - **MirrorURL**: This is the location where the packages will be downloaded from. When bootstrapping different Debian based distributions of Linux, this will define which varient will be used (e.g. specifying a different URL can be the difference between Debian or Ubuntu).
 - **OSVersion**: This keyword must be defined as the alpha-character string associated with the version of the distribution you wish to use. For example, `trusty` or `stable`. 
 - **Include**: As with the `yum` module, the `Include` keyword will install additional packages into the core operating system and the best practice is to supply only the bare essentials such that the `%inside` scriptlet has what it needs to properly completely the bootstrap.

##### **arch**
The Arch Linux bootstrap module does not name any additional keywords at this time. By defining the `arch` module, you have essentially given all of the information necessary for that particular bootstrap module to build a core operating system.

##### **docker**
The Docker bootstrap module will create a core operating system image based on an image hosted on a particular Docker Registry server. By default it will use the primary Docker Library, but that can be overridden. When using the `docker` module, several other keywords may also be defined:

 - **From**: This keyword defines the string of the registry name used for this image in the format [name]:[version]. Several examples are: `ubuntu:latest`, `centos:6`, `alpine:latest`, or `debian` (if the version tag is ommitted, `:latest` is automatically used).
 - **IncludeCmd**: This keyword tells Singularity to utilize the Docker defined `Cmd` as the `%runscript` (defined below), if the `Cmd` is defined.
 - **Registry**: If the registry you wish to download the image from is not from the main Docker Library, you can define it here.
 - **Token**: Sometimes the Docker API (depending on version?) requires an authorization token which is generated on the fly. Toggle this with a `yes` or `no` here.


## Bootstrap sections:
Once the `Bootstrap` module has completed, the sections are identified and utilized if present. The following sections are supported in the bootstrap definition, and integrated during the bootstrap process:


### %setup
This section blob is a Bourne shell scriptlet which will be executed on the host outside the container during bootstrap. The path to the container is accessible from within the running scriptlet environment via the variable `$SINGULARITY_ROOTFS`. For example, consider the following scriptlet:

```
%setup
    echo "Looking in directory '$SINGULARITY_ROOTFS' for /bin/sh"
    if [ ! -x "$SINGULARITY_ROOTFS/bin/sh" ]; then
        echo "Hrmm, this container does not have /bin/sh installed..."
        exit 1
    fi
    exit 0
```

As we investigate this example scriptlet, you will first see this is the outside scriptlet as would be defined within our bootstrap. The following line simply echos a message and prints the variable `$SINGULARITY_ROOTFS` which is defined within the shell context that this scriptlet runs in. Then we check to see if `/bin/sh` is executable, and if it is not, we print an error message. Notice the `exit 1`. The exit value of the scriptlets communicates if the scriptlet ran successfully or not. As with any shell return value, an exit of 0 (zero) means success, and any other exit value is a failure.

*note: Any uncaught command errors that occur within the scriptlet will cause the entire build process to halt!*

### %post
Similar to the `%setup` section, this section will be executed once during bootstrapping, but this scriptlet will be run from inside the container. This is where you should put additional installation commands, downloads, and configuration into your containers. Here is an example to consider:

```
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
```

The above example runs inside the container, so in this case we will first install the Centos YUM group development tools into the container, and then download Open MPI from the master branch from GitHub. We then build Open MPI and install it within the container. Next we compile one of the MPI test examples `ring_c.c` and install that to `/usr/bin/mpi_ring`. Finally we clean up and exit success.

*note: As with the `%setup` scriptlet, if any errors are encountered the entire process will fail.*

*another note: This is not a good example of a reproducible definition because it is pulling Open MPI from a moving target. A better example, would be to pull a static released version, but this serves as a good example of building a `%post` scriptlet.*

### %environment 
Beginning with Singularity v2.3 you can set up your environment using the `%environment` section of the definition file.  For example, if you wanted to add a directory to your search path, you could do so like this.

```
%environment
    export PATH=/opt/good/stuff:$PATH
```

### %runscript
The `%runscript` is another scriptlet, but it does not get executed during bootstrapping. Instead it gets persisted within the container to a file called `/singularity` which is the execution driver when the container image is ***run*** (either via the `singularity run` command or via executing the container directly).

When the `%runscript` is executed, all options are passed along to the executing script at runtime, this means that you can (and should) manage argument processing from within your runscript. Here is an example of how to do that:

```
%runscript
	echo "Arguments received: $*"
	exec /usr/bin/python "$@"
```

In this particular runscript, the arguments are printed as a single string (`$*`) and then they are passed to `/usr/bin/python` via a quoted array (`$@`) which ensures that all of the arguments are properly parsed by the executed command. The `exec` command causes the given command to replace the current entry in the process table with the one that is to be called. This makes it so the runscript shell process ceases to exist, and the only process running inside this container is the called Python command.

### %test
You may choose to add a `%test` section to your definition file. This section will be run at the very end of the boostrapping process and will give you a chance to validate the container during the bootstrap process. If you are building on Singularity Hub, [it is a good practice](https://github.com/singularityhub/singularityhub.github.io/wiki/Generate-Images#add-tests) to have this test section so you can be sure that your container works as expected. A non-zero status code indicates that one or more of your tests did not pass. You can also execute this scriptlet through the container itself, such that you can always test the validity of the container itself as you transport it to different hosts. Extending on the above Open MPI `%post`, consider this example:

```
%test
	/usr/local/bin/mpirun --allow-run-as-root /usr/bin/mpi_test

```

This is a simple Open MPI test to ensure that the MPI is build properly and communicates between processes as it should.

If you want to bootstrap without running tests, you can do so with the `--notest` argument:

```
sudo singularity bootstrap --notest container.img Singularity
```

This argument might be useful in cases where you might need hardware that is available during runtime, but is not available on the host that is building the image.

For further examples, we recommend you take a closer look at the [bootstrap command](/docs-bootstrap)
