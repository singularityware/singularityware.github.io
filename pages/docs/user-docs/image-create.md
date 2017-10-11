---
title: image.create
sidebar: user_docs
permalink: /docs-create
folder: docs
---

A Singularity image, which can be referred to as a "container," is a single file that contains a virtual file system. As of Singularity 2.4, we strongly recommend that you build (create and install) an image using <a href="/docs-build-container">build</a>. If you have reason to create an empty image, or use creat for any other reason, the original `create` command is replaced with a more specific `image.create`. After creating an image you can install an operating system, applications, and save meta-data with it.

Whereas Docker assembles images from layers that are stored on your computer (viewed with the `docker history` command), a Singularity image is just one file that can sit on your Desktop, in a folder on your cluster, or anywhere. Having Singularity containers housed within a single image file greatly simplifies management tasks such as sharing, copying, and branching your containers. It also means that standard Linux file system concepts like permissions, ownership, and ACLs apply to the container (e.g. I can give read only access to a colleague, or block access completely with a simple `chmod` command).

## Creating a new blank Singularity container image
Singularity will create a default container image of 768MiB using the following command:

```
singularity image.create container.imgCreating empty 768MiB image file: container.img
Formatting image with ext3 file system
Image is done: container.img
```

How big is it?

```
$ du -sh container.img 
29M     container.img
```

Create will make an `ext3` filesystem. Let's create and import a docker base (the pre-2.4 way with two commands), and then compare to just building (one command) from the same base. 


```
singularity create container.img
sudo singularity bootstrap container.img docker://ubuntu

...

$ du -sh container.img 
769M
```

Prior to 2.4, you would need to provide a `--size` to change from the default:


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

Now let's compare to if we just built, without needing to specify a size.

```
sudo singularity build container.simg docker://ubuntu

...

du -sh container.simg
45M	container.simg
```

Quite a difference! And one command instead of one.


### Overwriting an image with a new one

For any commands that If you have already created an image and wish to overwrite it, you can do so with the `--force` option. 

```
$ singularity image.create container.img
ERROR: Image file exists, not overwriting.


$ singularity image.create --force container.img
Creating empty 768MiB image file: container.img
Formatting image with ext3 file system
Image is done: container.img
```

`@GodLoveD` has provided a nice interactive demonstration of creating an image (pre 2.4).

{% include asciicast.html source='docs-create-create.js' uid='how-to-create-images' title='How to create images' author='davidgodlove@gmail.com'%}

