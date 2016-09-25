---
title: Create an Image
sidebar: docs_sidebar
permalink: create-image
folder: docs
---

## Singularity Images
Singularity images are single files which physically contain the container. Singularity images are 'sparse' files in that they start off with a giant hole and thus it does not consume disk space until you fill the hole (e.g. a 1GiB image may start off only taking about 30MiB of physical disk space). As you fill the image by installing files, data, and programs into it you will find it increase in size.

The effect of all files existing virtually within a single image greatly simplifies sharing, copying, branching, and other management tasks. It also means that standard file system ACLs apply to access and permission to the container (e.g. I can give read only access to a colleague, or block access completely with a simple chmod command).

### Creating a new blank Singularity container image
Singularity will create a default container image of 1GiB using the following command example:

```bash
$ sudo singularity create container.img
Creating a sparse image with a maximum size of 1024MiB...
Formatting image (/sbin/mkfs.ext4)
Done. Image can be found at: container.img
```

We can now use the command `ls` to look at the files and permissions of the container:

```bash
$ ls -l container.img 
-rwxr-xr-x. 1 root root 1073741856 Jun  1 08:27 container.img
```

How big is it?

```bash
$ du -sh container.img 
33M     container.img
```

Here we created a new container image called `container.img` in the current directory. You can see the the `ls` command reports it is 1GiB in size, but when checking the actual disk usage, it reports only 33MiB. As we add files to the image, its actual disk usage will increase.

Also, notice the permissions of the container image as it is executable. This is important in that Singularity images can be executed directly (as long as Singularity is installed on the host system).

You can increase or change the default image size using the --size option to create (option ordering is very important with Singularity and it must follow the 'create' sub-command).

### Mounting an image
Once the image has been created, you can mount it with the following command:

```bash
$ sudo singularity mount container.img /mnt

Mounting image 'container.img' into '/mnt'
```

To unmount, simply exit this new shell.

```bash
container.img:/mnt> df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/loop0      976M  2.6M  907M   1% /mnt
container.img:/mnt> exit
$
```
 
When mounting the image in this manner, Singularity makes use of name-spaces such that the mount is only visible and accessible from within the current shell that Singularity will spawn. When you are finished, you can simply exit the shell and the file system will be automatically unmounted.

### Increasing the size of an existing image
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

### Copying, sharing, branching, and distributing your image
Because Singularity images are single files, they are easily copied and managed. You can copy the image to create a branch, share the image and distribute the image as easily as copying any other file you control!

The primary motivation of Singularity is mobility, the single file image format makes this a simple accomplishment.

## Read Only Vs. Read Write
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
