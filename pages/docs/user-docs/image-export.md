---
title: image.export
sidebar: user_docs
permalink: docs-export
toc: false
folder: docs
---

Export is a way to dump the contents of your container into a .tar.gz, or a stream to put into some other place. For example, you could stream this into an in memory tar in python. 

Here we export an image into a `.tar` file:

```
singularity export container.img > container.tar
```

We can also specify the file with `--file`

```
singularity export --file container.tar container.img
```

And here is the recommended way to compress your image:

```
singularity export container.img | gzip -9 > container.img.gz
```
