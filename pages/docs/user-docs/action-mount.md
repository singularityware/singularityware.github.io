---
title: Bind Paths
sidebar: user_docs
permalink: docs-mount
toc: false
folder: docs
---

If [enabled by the system administrator](/docs-config#user-bind-control-boolean-defaultyes), Singularity allows you to map directories on your host system to directories within your container using bind mounts.  This allows you to read and write data on the host system with ease.

{% include toc.html %}

## Overview
When Singularity 'swaps' the host operating system for the one inside your container, the host file systems becomes inaccessible. But you may want to read and write files on the host system from within the container.
To enable this functionality, Singularity will *bind* directories back in via two primary methods: system-defined bind points and conditional user-defined bind points.

### System-defined bind points
The system administrator has the ability to define what bind points will be included automatically inside each container. The bind paths are locations on the host's root file system which should also be visible within the container.
Some of the bind paths are automatically derived (e.g. a user's home directory) and some are statically defined (e.g. [`bind path` in the Singularity configuration file](/docs-config#bind-path-string)).
In the default configuration, the directories `$HOME`, `/tmp`, `/proc`, `/sys`, and `/dev` are among the system-defined bind points.

### User-defined bind points
If the system administrator has [enabled user control of binds](/docs-config#user-bind-control-boolean-defaultyes), you will be able to request your own bind points within your container.

To *mount* a bind path inside the container, a **bind point** must be defined within the container. The bind point is a directory within the container that Singularity can use to bind a directory on the host system.  This means that if you want to bind to a point within the container such as `/global`, that directory must already exist within the container.

It is, however, possible that the system administrator has enabled a Singularity feature called [*overlay* in the Singularity configuration file](/docs-config#enable-overlay-boolean-defaultno).
This will cause the bind points to be created on an as-needed basis in an overlay file system so that the underlying container is not modified.
But because the *overlay* feature is not always enabled or is unavailable in the kernels of some older host systems, it may be necessary for container standards to exist to ensure portability from host to host.

#### Specifying Bind Paths
Many of the Singularity commands such as `run`, `exec`, and `shell` take the `--bind`/`-B` command-line option to specify bind paths, in addition to the `SINGULARITY_BINDPATH` environment variable.
This option's argument is a comma-delimited string of bind path specifications in the format `src[:dest[:opts]]`, where `src` and `dest` are outside and inside paths.
If `dest` is not given, it is set equal to `src`.
Mount options (`opts`) may be specified as `ro` (read-only) or `rw` (read/write, which is the default).
The `--bind`/`-B` option can be specified multiple times, or a comma-delimited string of bind path specifications can be used.

Here's an example of using the `-B` option and binding `/tmp` on the host to `/scratch` in the container (`/scratch` does not need to already exist in the container if file system overlay is enabled):

```bash
$ singularity shell -B /tmp:/scratch /tmp/Centos7-ompi.img
Singularity: Invoking an interactive shell within container...

Singularity.Centos7-ompi.img> ls /scratch
ssh-7vywtVeOez  systemd-private-cd84c81dda754fe4a7a593647d5a5765-ntpd.service-12nMO4
```

You can bind multiple directories in a single command with this syntax:

```bash
$ singularity shell -B /opt,/data:/mnt /tmp/Centos7-ompi.img
```

This will bind `/opt` on the host to `/opt` in the container and `/data` on the host to `/mnt` in the container.
Using the environment variable instead of the command line argument, this would be:

```bash
$ export SINGULARITY_BINDPATH="/opt,/data:/mnt"
$ singularity shell /tmp/Centos7-ompi.img
```

Using the environment variable `$SINGULARITY_BINDPATH`, you can bind directories even when you are running your container as an executable file with a runscript.
If you bind many directories into your Singularity containers and they don't change, you could even benefit by setting this variable in your `.bashrc` file.

#### Binding with Overlay

If a bind path is requested and the bind point does not exist within the container, a warning message will be displayed and Singularity will continue trying to start the container. For example:

```bash
$ singularity shell --bind /global /tmp/Centos7-ompi.img
WARNING: Non existent bind point (directory) in container: '/global'
Singularity: Invoking an interactive shell within container...

Singularity.Centos7-ompi.img>
```

Even though `/global` did not exist inside the container, the shell command printed a warning but continued on.
If overlay is available and enabled, you will find that we no longer get the error and `/global` is created and accessible as expected:

```bash
$ singularity shell --bind /global /tmp/Centos7-ompi.img
Singularity: Invoking an interactive shell within container...

Singularity.Centos7-ompi.img>
```

In this case, Singularity dynamically created the necessary bind point in your container.
Without overlay, you would have needed to manually create the `/global` directory inside your container.
