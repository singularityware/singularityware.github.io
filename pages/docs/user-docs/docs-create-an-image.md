---
title: Create an Image
sidebar: user_docs
permalink: create-image
folder: docs
---

Singularity images are single files which physically contain the container. Unlike Docker that puts images together from layers, abstractly shown on your computer with `docker -ps`, a Singularity image is just a file that can be sitting on your Desktop, in a folder on your cluster, or elsewhere.

The effect of all files existing virtually within a single image greatly simplifies sharing, copying, branching, and other management tasks. It also means that standard file system ACLs apply to access and permission to the container (e.g. I can give read only access to a colleague, or block access completely with a simple chmod command).


## Creating a new blank Singularity container image
Singularity will create a default container image of 768MiB using the following command example:

```bash
$ singularity create container.img
Initializing Singularity image subsystem
Opening image file: container.img
Creating 768MiB image
Binding image to loop
Creating file system within image
Image is done: container.img
```

Let's import an operating system into it.

```bash
singularity import container.img docker://ubuntu:latest
```

We can now use the command `ls` to look at the files and permissions of the container:

```bash
$ ls -l container.img 
-rwxr-xr-x 1 vanessa vanessa 805306400 Apr  6 19:24 container.img
```

How big is it?

```bash
$ du -sh container.img 
172M     container.img
```

Here we created a new container image called `container.img` in the current directory.

Also, notice the permissions of the container image as it is executable. This is important in that Singularity images can be executed directly (as long as Singularity is installed on the host system).

You can increase or change the default image size using the --size option to create (option ordering is very important with Singularity and it must follow the 'create' sub-command).


## Mounting an image
Once the image has been created, you can mount it with the following command:

```bash
$singularity mount container.img /mnt

Mounting image 'container.img' into '/mnt'
```

To unmount, simply exit this new shell.

```bash
Singularity: \w> df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/loop1      740M  143M  559M  21% /mnt
```
 
When mounting the image in this manner, Singularity makes use of name-spaces such that the mount is only visible and accessible from within the current shell that Singularity will spawn. When you are finished, you can simply exit the shell and the file system will be automatically unmounted.


## Increasing the size of an existing image
You can increase the size of an image after it has been instantiated by using the 'expand' Singularity sub-command as follows:

```bash
$ sudo singularity expand container.img 
Expanding sparse image by 512MiB...
Checking image (/sbin/mkfs.ext4)
e2fsck 1.42.9 (28-Dec-2013)
Growing file system
resize2fs 1.42.9 (28-Dec-2013)
Done. Image can be found at: container.img
$ ls -l container.img 
-rwxr-xr-x. 1 root root 1610612769 Jun  1 08:40 container.img
```

Similar to the create sub-command, you can override the default size (which is 512MiB) by using the --size option.

## Copying, sharing, branching, and distributing your image
Because Singularity images are single files, they are easily copied and managed. You can copy the image to create a branch, share the image and distribute the image as easily as copying any other file you control! If you want an automated builder for your image, you can use our container registry <a href="https://singularity-hub.org" target="_blank">Singularity Hub</a> that will build your "Singularity" bootstrap specification files from a Github repository each time that you push.
 
The primary motivation of Singularity is mobility, the single file image format makes this a simple accomplishment.


### Read Only Vs. Read Write
By default, all Singularity commands that operate within a container (e.g. 'exec', 'run', and 'shell') all enter the image by default as read only. This enables multiple processes to be able to use the image appropriately (as would be necessary with MPI). But if you want to make any changes to the image, you must have both write permission on the image file itself and use the '--writable' flag. For example:


```bash
$ sudo singularity shell container.img 
Singularity/container.img> whoami
root
Singularity/container.img> touch /foo
touch: cannot touch '/foo': Read-only file system
Singularity/container.img> exit

$ sudo singularity shell --writable container.img 
Singularity/container.img> touch /foo
Singularity/container.img> exit
$ 
```

Even though I was root in both cases, I could not touch /foo unless the shell sub-command was called with the `--writable` flag.


## Using Your Container Image
Singularity offers several primary user interfaces to containers: `shell`, `exec`, `run` and `test`. Using these interfaces, you can include any application or workflow that exists inside of a container as easy as if they were on the host system. These interfaces are designed specifically such that you do not need to be root or have escalated privileges to execute them. Additionally, Singularity is designed to abstract out the container system as elegantly as possibly such that the container does not exist. All IO, pipes, sockets, and native process control is handed through the container and to the calling application and Singularity elegantly gets completely out of the way for the process to run.


Generally the differences can be explained as follows

- **shell**: The `shell` interface (or Singularity subcommand) will invoke an interactive shell within the container. By default the shell called is `/bin/sh`, but this can be overridden with the shell option `--shell /path/to/shell` or via the environment variable `SINGULARITY_SHELL`. Once the shell is exited, the namespaces all collapse, and all mounts, binds, and contained processes exit.
- **exec**: As the name implies, the `exec` interface/subcommand offers the ability to execute a single command within a container environment. This is a simple way to run programs, scripts and workflows that exist within a container from the host system. You can run this command from within a script on the host system or from a batch scheduler or an `mpirun` command.
- **run**: Running a container will execute a predefined script (defined in the Singularity bootstrap definition as `%runscript`). If not run script has been provided, the container will launch a shell instead.
- **test**: If you specified a `%test` section within the Singularity bootstrap definition, you can run that test as yourself. This is a useful way to ensure that a container works properly not only when built, but when transferred to other hosts or infrastructures.
