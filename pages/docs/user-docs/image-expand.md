---
title: image.expand
sidebar: user_docs
permalink: docs-expand
folder: docs
---

While the squashfs filesystem means that you typically don't need to worry about the size of your container being built, you might find that
if you are building an ext3 image (pre Singularity 2.4) you want to expand it.

## Increasing the size of an existing image
You can increase the size of an image after it has been instantiated by using the `image.expand` Singularity sub-command. In the
example below, we:

 1. create an empty image
 2. inspect it's size
 3. expand it
 4. confirm it's larger

```
$ singularity image.create container.img
Creating empty 768MiB image file: container.imglarity image.create container.im 
Formatting image with ext3 file system
Image is done: container.img

$ ls -lh container.img 
-rw-rw-r-- 1 vanessa vanessa 768M Oct  2 18:48 container.img

$ singularity image.expand container.img
Expanding image by 768MB
Checking image's file system
e2fsck 1.42.13 (17-May-2015)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
container.img: 11/49152 files (0.0% non-contiguous), 7387/196608 blocks
Resizing image's file system
resize2fs 1.42.13 (17-May-2015)
Resizing the filesystem on container.img to 393216 (4k) blocks.
The filesystem on container.img is now 393216 (4k) blocks long.
Image is done: container.img

$ ls -lh container.img 
-rw-rw-r-- 1 vanessa vanessa 1.5G Oct  2 18:48 container.img
```

Similar to the create sub-command, you can override the default size increase (which is 768MiB) by using the `--size` option.

{% include asciicast.html source='docs-create-expand.js' uid='how-to-expand-images' title='How to expand images' author='davidgodlove@gmail.com'%}
