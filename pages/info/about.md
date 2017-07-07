---
title: About Singularity
sidebar: main_sidebar
permalink: about
toc: false
---

## Overview

Designed around the notion of extreme mobility of compute and reproducible science, Singularity enables users to have full control of their operating system environment. This means that a non-privileged user can "swap out" the operating system on the host for one they control. If the host system is running RHEL6 but your application runs in Ubuntu, you can create an Ubuntu image, install your applications into that image, copy the image to another host, and run your application on that host in it's native Ubuntu environment.

Singularity also allows you to leverage the resources of whatever host you are on. This includes HPC interconnects, resource managers, file systems, GPUs and/or accelerators, etc.


## Background
Software development on Linux is moving in a new direction. Thanks to advances in virtualization and container technologies, developers are finding it very convenient to distribute instances of their entire build/development environment in addition to or instead of source code alone. There are some benefits and drawbacks to this model.

Some of the benefits of distributing software in this fashion include being able to provide a configuration free implementation which can easily be replicated to distribute a software or work flow. The user does not need to worry about managing potentially complicated dependency chains nor worry about configuration nuances.

The drawbacks are numerous, but tend to focus on several major areas: container overhead, container technology and architecture concerns (e.g., privilege escalation and network/file system access), and work flow compatibility.

### The Singularity Solution
Singularity containers are purpose built and can include a simple binary and library stack or a complicated work flow that includes both network and file system access (or anything in between). The Singularity container images are then completely portable to any binary compatible version of Linux with the only dependency being Singularity running on the target system.

Singularity blocks privilege escalation within the container. If you want to be root inside the container, you first must be root outside the container. This usage paradigm mitigates many of the security concerns that exists with containers on multi-tenant shared resources. You can directly call programs inside the container from outside the container fully incorporating pipes, standard IO, file system access, X11, and MPI. Singularity images can be seamlessly incorporated into your environment.

### Portability
Singularity containers are designed to be as portable as possible, spanning many flavors and vintages of Linux. The only known i86 limitation is the version of Linux running on the host. Singularity has been ported to distributions going as far back as RHEL 5 (and compatibles) and works on all flavors of Debian, Gentoo and Slackware. Within the container, there are almost no limitations aside from basic binary compatibility.

Within the container, there could be an entire distribution of Linux or a very lightweight tuned set of packages to support a particular work-flow. The work-flow can be scripted to run completely within the container or interact with files and other programs outside the container. The container can also emulate a single program and can be executed directly (yes, you heard that right). Containers have the execute bit set such they can be executed and configured to run a defined script or program when executed in this manner.

### Reproducibility
Each Singularity image includes all of the application's necessary run-time libraries and can even include the required data and files for a particular application to run. This encapsulation of the entire user-space environment facilitates not only portability but also reproducibility.

### License
Singularity is released under a special 3 clause BSD license. Please see our <a href="{{ site.repo }}/blob/master/LICENSE.md" target="_blank">LICENSE</a> file for more details).

## Features

### Encapsulation of the environment

Mobility of Compute is the encapsulation of an environment in such a manner to make it portable between systems. This operating system environment can contain the necessary applications for a particular work-flow, development tools, and/or raw data. Once this environment has been developed it can be easily copied and run from any other Linux system.

This allows users to BYOE (Bring Their Own Environment) and work within that environment anywhere that Singularity is installed. From a service provider's perspective we can easily allow users the flexibility of "cloud"-like environments enabling custom requirements and workflows.

Additionally there is always a misalignment between development and production environments. The service provider can only offer a stable, secure tuned production environment which in many times will not keep up with the fast paced requirements of developers. With Singularity, you can control your own development environment and simply copy them to the production resources.

### Containers are image based

Using images have several key benefits:

First, this image serves as a vector for mobility while retaining permissions of the files within the image. For example, a user may own the image file so they can copy the image to and from system to system. But, files within an image must be owned by the appropriate user. For example, '/etc/passwd' and '/' must be owned by root to achieve appropriate access permission. These permissions are maintained within a user owned image.

There is never a need to build, rebuild, or cache an image! All IO happens on an as needed basis. The overhead in starting a container is in the thousandanths of a second because there is never a need to pull, build or cache anything!

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

## Getting started

Jump in and <a href="/quickstart"><strong>get started</strong></a>, or find ways to <a href="/support">get help</a>.

* Project lead: <a href="https://gmkurtzer.github.io/" target="_blank">Gregory M. Kurtzer</a>

{% include links.html %}
