---
title: image.export
sidebar: user_docs
permalink: docs-export
toc: false
folder: docs
---

Export is a way to dump the contents of your container into a `.tar.gz`, or a stream to put into some other place. For example, you could stream this into an in memory tar in python. Importantly, this command was originally intended for Singularity version less than 2.4 in the case of exporing an ext3 filesystem. For Singularity greater than 2.4, the resulting export file is likely to be larger than the original squashfs counterpart. An example with an ext3 image is provided.

Here we export an image into a `.tar` file:

```
singularity image.export container.img > container.tar
```

We can also specify the file with `--file`

```
singularity image.export --file container.tar container.img
```

And here is the recommended way to compress your image:

```
singularity image.export container.img | gzip -9 > container.img.gz
```
