---
title: About Singularity
sidebar: main_sidebar
permalink: about
toc: false
---

## Overview
While there are many container solutions being used commonly in this day and age, what makes Singularity different stems from it's primary design features and thus it's architecture:

1. **Reproducible software stacks:** These must be easily verifiable via checksum or cryptographic signature in such a manner that does not change formats (e.g. splatting a tarball out to disk). By default Singularity uses a container image file which can be checksummed, signed, and thus easily verified and/or validated.
2. **Mobility of compute:** Singularity must be able to transfer (and store) containers in a manner that works with standard data mobility tools (rsync, scp, gridftp, http, NFS, etc..) and maintain software and data controls compliancy (e.g. HIPPA, nuclear, export, classified, etc..)
3. **Compatibility with complicated architectures:** The runtime must be immediately compatible with existing HPC, scientific, compute farm and even enterprise architectures any of which maybe running legacy kernel versions (including RHEL6 vintage systems) which do not support advanced namespace features (e.g. the user namespace)
4. **Security model:** Unlike many other container systems designed to support trusted users running trusted containers we must support the opposite model of untrusted users running untrusted containers. This changes the security paradigm considerably and increases the breadth of use cases we can support.

## Background
A Unix operating system is broken into two primary components, the kernel space, and the user space. The Kernel, supports the user space by interfacing with the hardware, providing core system features and creating the software compatibility layers for the user space. The user space on the other hand is the environment that most people are most familiar with interfacing with. It is where applications, libraries and system services run.

Containers are shifting the emphasis away from the runtime environment by commoditizing the user space into swappable units. This means that the entire user space portion of a Linux operating system, including programs, custom configurations, and environment can be interchanged at runtime. Singularity emphasis and simplifies the distribution vector of containers to be that of a single, verifiable file.

Software developers can now build their stack onto whatever operating system base fits their needs best, and create distributable runtime encapsulated environments and the users never have to worry about dependencies, requirements, or anything else from the user space.

It provides the functionality of a virtual machine, without the heavyweight implementation and performance costs of emulation and redundancy!

### The Singularity Solution
Singularity has two primary roles:

1. **Container Image Management:** Singularity supports building different container image formats from scratch using your choice of Linux distribution bases or leveraging other container formats (e.g. Docker Hub). Container formats supported are the default compressed immutable (read only) image files, writable raw file system based images, and sandboxes (*chroot* style directories). 
2. **Container Runtime:** The Singularity runtime is designed to leverage the above mentioned container formats and support the concept of *untrusted users running untrusted containers*. This counters the typical container runtime practice of *trusted users running trusted containers* and as a result of that, Singularity utilizes a very different security paradigm. This is a required feature for implementation within any multi-user environment.

The Singularity containers themselves are purpose built and can include a simple application and library stack or a complicated work flow that can interface with the hosts resources directly or run isolated from the host and other containers. You can even launch a contained work flow by executing the image file directly! For example, assuming that `~/bin` is in the user's path as it is normally by default:

```
$ mkdir ~/bin
$ singularity build ~/bin/python-latest docker://python:latest
Docker image path: index.docker.io/library/python:latest
Cache folder set to /home/gmk/.singularity/docker
Importing: base Singularity environment
Importing: /home/gmk/.singularity/docker/sha256:aa18ad1a0d334d80981104c599fa8cef9264552a265b1197af11274beba767cf.tar.gz
Importing: /home/gmk/.singularity/docker/sha256:15a33158a1367c7c4103c89ae66e8f4fdec4ada6a39d4648cf254b32296d6668.tar.gz
Importing: /home/gmk/.singularity/docker/sha256:f67323742a64d3540e24632f6d77dfb02e72301c00d1e9a3c28e0ef15478fff9.tar.gz
Importing: /home/gmk/.singularity/docker/sha256:c4b45e832c38de44fbab83d5fcf9cbf66d069a51e6462d89ccc050051f25926d.tar.gz
Importing: /home/gmk/.singularity/docker/sha256:b71152c33fd217d4408c0e7a2f308e66c0be1a58f4af9069be66b8e97f7534d2.tar.gz
Importing: /home/gmk/.singularity/docker/sha256:c3eac66dc8f6ae3983a7f37e3da84a8acb828faf909be2d6649e9d7c9caffc28.tar.gz
Importing: /home/gmk/.singularity/docker/sha256:494ffdf1660cdec946ae13d6b726debbcec4c393a7eecfabe97caf3961f62c36.tar.gz
Importing: /home/gmk/.singularity/docker/sha256:f5ec737c23de3b1ae2b1ce3dce1fd20e0cb246e4c73584dcd4f9d2f50063324e.tar.gz
Importing: /home/gmk/.singularity/metadata/sha256:5dd22488ce22f06bed1042cc03d3efa5a7d68f2a7b3dcad559df4520154ef9c2.tar.gz
WARNING: Building container as an unprivileged user. If you run this container as root
WARNING: it may be missing some functionality.
Building Singularity image...
Cleaning up...
Singularity container built: /home/gmk/bin/python-latest
$ which python-latest
/home/gmk/bin/python-latest
$ python-latest --version
Python 3.6.3
$ singularity exec ~/bin/python-latest cat /etc/debian_version
8.9
$ singularity shell ~/bin/python-latest 
Singularity: Invoking an interactive shell within container...

Singularity python-latest:~> 
```

<font color='red' size='+2'>Ascineimsasasessssss!</font>

Additionally, Singularity blocks privilege escalation within the container and you are always yourself within a container! If you want to be root inside the container, you first must be root outside the container. This simple usage paradigm mitigates many of the security concerns that exists with containers on multi-user shared resources. You can directly call programs inside the container from outside the container fully incorporating pipes, standard IO, file system access, X11, and MPI. Singularity images can be seamlessly incorporated into your environment.

### Portability and Reproducibility
Singularity containers are designed to be as portable as possible, spanning many flavors and vintages of Linux. The only known limitation is binary compatibility of the kernel and container. Singularity has been ported to distributions going as far back as RHEL 5 (and compatibles) and works on all currently living versions of RHEL, Debian, Arch, Alpine, Gentoo and Slackware. Within the container, there are almost no limitations aside from basic binary compatibility.

Inside the container, it is also possible to have a very old version of Linux supported. The oldest known version of Linux tested was a Red Hat Linux 8 container, that was converted by hand from a physical computer's hard drive as the 15 year old hardware was failing. The container was transferred to a new installation of Centos7, and is still running in production!

Each Singularity image includes all of the application's necessary run-time libraries and can even include the required data and files for a particular application to run. This encapsulation of the entire user-space environment facilitates not only portability but also reproducibility.


## Features

### Encapsulation of the environment
Mobility of Compute is the encapsulation of an environment in such a manner to make it portable between systems. This operating system environment can contain the necessary applications for a particular work-flow, development tools, and/or raw data. Once this environment has been developed it can be easily copied and run from any other Linux system.

This allows users to BYOE (Bring Their Own Environment) and work within that environment anywhere that Singularity is installed. From a service provider's perspective we can easily allow users the flexibility of "cloud"-like environments enabling custom requirements and workflows.

Additionally there is always a misalignment between development and production environments. The service provider can only offer a stable, secure tuned production environment which in many times will not keep up with the fast paced requirements of developers. With Singularity, you can control your own development environment and simply copy them to the production resources.

### Containers are image based
Using image files have several key benefits:

First, this image serves as a vector for mobility while retaining permissions of the files within the image. For example, a user may own the image file so they can copy the image to and from system to system. But, files within an image must be owned by the appropriate user. For example, '/etc/passwd' and '/' must be owned by root to achieve appropriate access permission. These permissions are maintained within a user owned image.

There is never a need to build, rebuild, or cache an image! All IO happens on an as needed basis. The overhead in starting a container is in the thousandths of a second because there is never a need to pull, build or cache anything!

On HPC systems a single image file optimizes the benefits of a shared parallel file system! There is a single metadata lookup for the image itself, and the subsequent IO is all directed to the storage servers themselves. Compare this to the massive amount of metadata IO that would be required if the container's root file system was in a directory structure. It is not uncommon for large Python jobs to DDOS (distributed denial of service) a parallel meta-data server for minutes! The Singularity image mitigates this considerably.

### No user contextual changes or root escalation allowed
When Singularity is executed, the calling user is maintained within the container. For example, if user 'gmk' starts a Singularity container, the same user 'gmk' will end up within the container. If 'root' starts the container, 'root' will be the user inside the container.

Singularity also limits a user's ability to escalate privileges within the container. Even if the user works in their own environment where they configured 'sudo' or even removed root's password, they will not be able to 'sudo' or 'su' to root. If you want to be root inside the container, you must first be root outside the container.

Because of this model, it becomes possible to blur the line of access between what is contained and what is on the host as Singularity does not grant the user any more access then they already have. It also enables the implementation on shared/multi-tenant resources.

### No root owned daemon processes
Singularity does not utilize a daemon process to manage the containers. While daemon processes do facilitate certain types of workflows and privilege escalation, it breaks all resource controlled environments. This is because a user's job becomes a subprocess of the daemon (rather then the user's shell) and the daemon process is outside of the reach of a resource manager or batch scheduler.

Additionally, securing a root owned daemon process which is designed to manipulate the host's environment becomes tricky. In currently implemented models, it is possible to grant permissions to users to control the daemon, or not. There is no sense of ACL's or access of what users can and can not do.

While there are some other container implementations that do not leverage a daemon, they lack other features necessary to be considered as reasonable user facing solution without having root access. For example, there has been a standing unimplemented patch to RunC (already daemon-less) which allows for root-less usage (no root). But, user contexts are not maintained, and it will only work with chroot directories (instead of an image) where files must be owned and manipulated by the root user!

## Use Cases

### BYOE: Bring Your Own Environment!
Engineering work-flows for research computing can be a complicated and iterative process, and even more so on a shared and somewhat inflexible production environment. Singularity solves this problem by making the environment flexible.

Additionally, it is common (especially in education) for schools to provide a standardized pre-configured Linux distribution to the students which includes all of the necessary tools, programs, and configurations so they can immediately follow along.

### Reproducible science
Singularity containers can be built to include all of the programs, libraries, data and scripts such that an entire demonstration can be contained and either archived or distributed for others to replicate no matter what version of Linux they are presently running.

Commercially supported code requiring a particular environment
Some commercial applications are only certified to run on particular versions of Linux. If that application was installed into a Singularity container running the version of Linux that it is certified for, that container could run on any Linux host. The application environment, libraries, and certified stack would all continue to run exactly as it is intended.

Additionally, Singularity blurs the line between container and host such that your home directory (and other directories) exist within the container. Applications within the container have full and direct access to all files you own thus you can easily incorporate the contained commercial application into your work and process flow on the host.

### Static environments (software appliances)
Fund once, update never software development model. While this is not ideal, it is a common scenario for research funding. A certain amount of money is granted for initial development, and once that has been done the interns, grad students, post-docs, or developers are reassigned to other projects. This leaves the software stack un-maintained, and even rebuilds for updated compilers or Linux distributions can not be done without unfunded effort.

### Legacy code on old operating systems
Similar to the above example, while this is less than ideal it is a fact of the research ecosystem. As an example, I know of one Linux distribution which has been end of life for 15 years which is still in production due to the software stack which is custom built for this environment. Singularity has no problem running that operating system and application stack on a current operating system and hardware.

### Complicated software stacks that are very host specific
There are various software packages which are so complicated that it takes much effort in order to port, update and qualify to new operating systems or compilers. The atmospheric and weather applications are a good example of this. Porting them to a contained operating system will prolong the use-fullness of the development effort considerably.

### Complicated work-flows that require custom installation and/or data
Consolidating a work-flow into a Singularity container simplifies distribution and replication of scientific results. Making containers available along with published work enables other scientists to build upon (and verify) previous scientific work.

## License
Singularity is released under a standard 3 clause BSD license. Please see our <a href="{{ site.repo }}/blob/master/LICENSE.md" target="_blank">LICENSE</a> file for more details).


## Getting started

Jump in and <a href="/quickstart"><strong>get started</strong></a>, or find ways to <a href="/support">get help</a>.

* Project lead: <a href="https://gmkurtzer.github.io/" target="_blank">Gregory M. Kurtzer</a>

{% include links.html %}
