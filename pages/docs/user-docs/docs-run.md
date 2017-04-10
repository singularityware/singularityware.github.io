---
title: Singularity Run
sidebar: user_docs
permalink: docs-run
folder: docs
toc: false
---

## Usage
It's common to want your container to "do a thing." Singularity `run` allows you to define a custom action to be taken when a container is either `run` or executed directly by file name. Specifically, you might want it to execute a command, or run an executable that gives access to many different functions for the user. First, how do we run a container? We can do that in one of two ways - the commands below are identical:

```bash
singularity run centos7.img
./centos7.img
```

In both cases, we are executing the container's "runscript," which is the executable `/singularity` at the root of the image, which is either an actual file (version 2.2 and earlier) or a link to one (2.3 and later). For example, looking at a 2.3 image, I can see the runscript via the path to the link:

```bash
singularity exec centos7.img cat /singularity
#!/bin/sh

exec /bin/bash "$@"
```

or to the actual file in the container's metadata folder, `/.singularity.d`

```bash
singularity exec centos7.img cat /.singularity.d/runscript
#!/bin/sh

exec /bin/bash "$@"
```

The usage is as follows:

```bash
$ singularity run
USAGE: singularity (options) run [container image] (options)

Notice how the runscript has bash followed by `$@`? This is good practice to include in a runscript, as any arguments passed by the user will be given to the container. Thus, I could send a command to the container for bash to run:

```bash
echo "echo motorobot" >> /home/vanessa/Desktop/runme.sh
singularity run centos7.img runme.sh
motorbot
```

### Defining the Runscript
When using the "run" command, the order of operations for runscripts works as follows:

 1. A user defined runscript in the `%runscript` section of a bootstrap takes preference over all
 2. If the user has not defined a runscript and is importing a Docker container, the Docker `ENTRYPOINT` is used.
 3. If a user has not defined a runscript and adds `IncludeCmd: yes` to the bootstrap file, the `CMD` is used over the `ENTRYPOINT`
 4. If the user has not defined a runscript and the Docker container doesn't have an `ENTRYPOINT`, we look for `CMD`, even if the user hasn't asked for it.
 5. If the user has not deifned a runscript, and there is no `ENTRYPOINT` or `CMD` (or we aren't importing Docker at all) then we default to `/bin/bash`

Here is how you would define the runscript section when you [bootstrap](/bootstrap-image) an image:

```bash
Bootstrap: docker
From: ubuntu:latest

%runscript
exec /usr/bin/python "$@"`
```

and of course python should be installed as /usr/bin/python. The addition of `$@` ensures that arguments are passed along from the user. If you want your container to run absolutely any command given to it, and you want to use run instead of exec, you could also just do:

```bash
Bootstrap: docker
From: ubuntu:latest

%runscript
exec "$@"`
```

Generally, it is advised to provide a runscript that tells your user how to use the container, and gives access to the important executables. A user should be able to find your container, and execute it without an arguments, and get the equivalent of `--help`. Depending on your language of choice, you can do this in multiple ways.
