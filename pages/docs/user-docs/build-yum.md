---
title: Yum Builds
sidebar: user_docs
permalink: build-yum
folder: docs
toc: false
---


The YUM base uses YUM on the host system to bootstrap the core operating system that exists within the container. This module is applicable for bootstrapping distributions like Red Hat, Centos, and Scientific Linux. When using the `yum` bootstrap module, several other keywords may also be necessary to define:

 - **MirrorURL**: This is the location where the packages will be downloaded from. When bootstrapping different RHEL/YUM compatible distributions of Linux, this will define which variant will be used (e.g. the only difference in bootstrapping Centos from Scientific Linux is this line.
 - **OSVersion**: When using the `yum` bootstrap module, this keyword is conditional and required only if you have specified a %{OSVERSION} variable name in the `MirrorURL` keyword. If the `MirrorURL` definition does not have the %{OSVERSION} variable, `OSVersion` can be omitted from the header field.
 - **Include**: By default the core operating system is an extremely minimal base, which may or may not include the means to even install additional packages. The `Include` keyword should define any additional packages which should be used and installed as part of the core operating system bootstrap. The best practice is to keep this keyword usage as minimal as possible such that you can then use the `%inside` scriptlet (explained shortly) to do additional installations. One common package you may want to include here is `yum` itself.

Warning, there is a major limitation with using YUM to bootstrap a container and that is the RPM database that exists within the container will be created using the RPM library and Berkeley DB implementation that exists on the host system. If the RPM implementation inside the container is not compatible with the RPM database that was used to create the container, once the container has been created RPM and YUM commands inside the container may fail. This issue can be easily demonstrated by bootstrapping an older RHEL compatible image by a newer one (e.g. bootstrap a Centos 5 or 6 container from a Centos 7 host).
