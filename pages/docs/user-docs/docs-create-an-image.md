---
title: Create an Image
sidebar: user_docs
permalink: create-image
folder: docs
---

A Singularity image, which can be referred to as a "container," is a single file that contains a virtual file system. After creating an image you can install an operating system, applications, and save meta-data with it.

Whereas Docker assembles images from layers that are stored on your computer (viewed with the `docker history` command), a Singularity image is just one file that can sit on your Desktop, in a folder on your cluster, or anywhere.

Having Singularity containers housed within a single image file greatly simplifies management tasks such as sharing, copying, and branching your containers. It also means that standard Linux file system concepts like permissions, ownership, and ACLs apply to the container (e.g. I can give read only access to a colleague, or block access completely with a simple chmod command).

## Creating a new blank Singularity container image
Singularity will create a default container image of 768MiB using the following command:

```
$ singularity create container.img
Initializing Singularity image subsystem
Opening image file: container.img
Creating 768MiB image
Binding image to loop
Creating file system within image
Image is done: container.img
```
How big is it?

```
$ du -sh container.img 
29M     container.img
```

We can now use `ls` to list details about the image.

```
$ ls -l container.img 
-rwxr-xr-x 1 user group 805306400 Apr 15 11:11 container.img
```

Note the permissions of the image make it executable. Singularity images [can be executed directly](/docs-run).

### Creating an image of a different size

You can change the maximum size of an image you create using the `--size` option. Note that `--size` is not a global option.  It is an option to the `create` sub-command and must therefore follow it:

```
$ singularity create --size 2048 container2.img
Initializing Singularity image subsystem
Opening image file: container2.img
Creating 2048MiB image
Binding image to loop
Creating file system within image
Image is done: container2.img

$ ls -lh container*.img 
-rwxr-xr-x 1 user group 2.1G Apr 15 11:34 container2.img
-rwxr-xr-x 1 user group 769M Apr 15 11:11 container.img
```

### Overwriting an image with a new one

If you have already created an image and wish to overwrite it, you can do so with the `--force` option.  This option must also follow the `create` sub-command.

```
$ singularity create --size 512 --force container2.img
Initializing Singularity image subsystem
Opening image file: container2.img
Creating 512MiB image
Binding image to loop
Creating file system within image
Image is done: container2.img

$ ls -lh container*.img 
-rwxr-xr-x 1 user group 513M Apr 15 11:39 container2.img
-rwxr-xr-x 1 user group 769M Apr 15 11:11 container.img
```

{% include asciicast.html source='docs-create-create.js' title='How to create images' author='davidgodlove@gmail.com'%}

## Increasing the size of an existing image
You can increase the size of an image after it has been instantiated by using the `expand` Singularity sub-command as follows:

```
$ ls -lh container.img 
-rwxr-xr-x 1 user group 769M Apr 15 11:11 container.img

$ singularity expand container.img 
Initializing Singularity image subsystem
Opening image file: container.img
Expanding image by 768MiB
Binding image to loop
Checking file system
e2fsck 1.42.13 (17-May-2015)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/loop0: 11/49152 files (0.0% non-contiguous), 7387/196608 blocks
Resizing file system
resize2fs 1.42.13 (17-May-2015)
Resizing the filesystem on /dev/loop0 to 393216 (4k) blocks.
The filesystem on /dev/loop0 is now 393216 (4k) blocks long.

Image is done: container.img

$ ls -lh container.img 
-rwxr-xr-x 1 user group 1.6G Apr 15 12:21 container.img
```

Similar to the create sub-command, you can override the default size increase (which is 768MiB) by using the `--size` option.

{% include asciicast.html source='docs-create-expand.js' title='How to expand images' author='davidgodlove@gmail.com'%}

## Mounting an image
Once an image has been created and an OS has been added with the [`import`](/docs-import) or [`bootstrap`](/docs-bootstrap) commands, you can use the [`shell`](/docs-shell) command to start an interactive shell within the container. But this is not possible when an image does not yet contain a functional OS or shell. For debugging, development, or simply inspecting an image that lacks a functional shell you can use the `mount` command like so:

```
$ mkdir /tmp/container

$ singularity mount container.img /tmp/container/
container.img is mounted at: /tmp/container/

Spawning a new shell in this namespace, to unmount, exit shell

Singularity: \w> df
Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/loop0       1531760      1172   1451948   1% /tmp/container

Singularity: \w> cd /tmp/container

Singularity: \w> ls -a
.  ..  lost+found
```

{% include asciicast.html source='docs-create-mount.js' title='How to mount an image' author='davidgodlove@gmail.com'%}

At this point the image just contains a bare file system because we haven't used something like the [`bootstrap`](docs-bootstrap) or [`import`](docs-import) commands to install an OS. 
 
Singularity mounts images in private name-spaces so that the mount is only visible and accessible from within the freshly spawned shell. When you are finished, you can simply exit the shell and the file system will be automatically unmounted.

Files can be copied from the image to the host when it is mounted in this way, but they cannot be copied from the host into the image.  This is because the image is mounted in read-only mode by default and the mount point is owned by the root user.  To copy files into a mounted image, first become root and then mount the image with the `--writable` option to the `mount` sub-command.

```
$ sudo -i

# singularity mount --writable /home/user/container.img /tmp/container
```

{% include asciicast.html source='docs-create-rootmount.js' title='How to mount an image and copy files to it' author='davidgodlove@gmail.com'%}

## Copying, sharing, branching, and distributing your image
A primary goal of Singularity is mobility. The single file image format makes mobility easy.

Because Singularity images are single files, they are easily copied and managed. You can copy the image to create a branch, share the image and distribute the image as easily as copying any other file you control! 

If you want an automated solution for building and hosting your image, you can use our container registry <a href="https://singularity-hub.org" target="_blank">Singularity Hub</a>. Singulairty Hub can automatically build [bootstrap specification files](/bootstrap-image#the-bootstrap-definition-file) from a Github repository each time that you push. It provides a simple cloud solution for storing and sharing your image.  

