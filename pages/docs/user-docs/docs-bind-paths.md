---
title: Bind Paths / File Sharing
sidebar: user_docs
permalink: docs-mount
toc: false
folder: docs
---

{% include toc.html %}

Singularity 'swaps' out the currently running root operating system on the host for what is inside the container, and in doing so none of the host file systems are accessible anymore. As a workaround for this, Singularity will *bind* those paths back in via two primary methods: system defined bind points and conditional user defined bind points.

To *mount* a bind path inside the container, a ***bind point*** must be defined within the container. The bind point is a target location entity to which the actual directory or file can be bound to. This means that if you want to bind to a point within the container such as `/global`, that directory must already exist within the container.

It is however possible that the system administrator has enabled a Singularity feature called *overlay* in the `/etc/singularity/singularity.conf` file. This will cause the bind points to be created on an as needed basis in an overlay file system so that the underlying container is not modified. But because the *overlay* feature is not always used, it maybe necessary for container standards to exist to ensure portability from host to host.

If a bind path is requested, and the bind point does not exist within the container, a warning message will be displayed, and Singularity will continue trying to mount file system. For example:

```bash
$ singularity shell /tmp/Centos7-ompi.img 
WARNING: Non existant bind point (directory) in container: '/global'
Singularity: Invoking an interactive shell within container...

Singularity.Centos7-ompi.img> 
```

Even though `/global` did not exist inside the container, the shell command printed a warning but continued on. If we enable `enable overlay = yes` in the `/etc/singularity/singularity.conf` you will find that we no longer get the error and `/global` is created and accessible as expected:

```bash
$ singularity shell /tmp/Centos7-ompi.img 
Singularity: Invoking an interactive shell within container...

Singularity.Centos7-ompi.img> 
```

#### System defined bind points
The system administrator has the ability to define what bind points will be included automatically inside each container. The bind paths are locations on the host's root file system which should also be visible within the container. Some of the bind paths are automatically derived (e.g. a user's home directory) and some are statically defined (e.g. `bind path = ` in `/etc/singularity/singularity.conf`).


#### User defined bind points
If the system administrator has enabled user control of binds (via `user bind control = yes` in `/etc/singularity/singularity.conf`), you will be able to request your own bind points within your container. 

Further, if the administrator has enabled the use of file system overlay (via `enable overlay = yes` in `/etc/singularity/singularity.conf`), you can bind host system directories to directories that do not exist within the container.  Singularity will dynamically create the necessary bind points in your container on demand.  This feature may not be supported on older host systems.

Here's an example of using the `--bind` option and binding `/tmp` to `/scratch` (which may not already exist within the container if file system overlay is enabled):

```bash
$ singularity shell -B /tmp:/scratch /tmp/Centos7-ompi.img 
Singularity: Invoking an interactive shell within container...

Singularity.Centos7-ompi.img> ls /scratch
ssh-7vywtVeOez  systemd-private-cd84c81dda754fe4a7a593647d5a5765-ntpd.service-12nMO4
```
