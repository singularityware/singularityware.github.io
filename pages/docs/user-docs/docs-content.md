---
title: Image Content
sidebar: user_docs
permalink: image-content
folder: docs
---

So, you want to put stuff in your container? This is understandable. There are a few ways to do that, some of which are more reproducible than others. 

## Bootstrap
We recommend strongly that you add content during an image <a href="/docs-bootstrap">bootstrap</a>, because the operations on your image will be recorded in the build specification file, and you'll remember. During bootstrap you can get content:

 - by way of Docker layers
 - by cloning a Github (or other) repository in the `%post` section
 - using wget, curl, or any other method to download in `%post` or `%setup`
 - Adding pairs of `path/on/host` `/path/in/container` to the `%files` section


## After Bootstrap
While we don't recommend these methods (this is not reproducible practice) there are ways to add content after image creation.

### Writable Shell
You can shell into your image with `--writable` and then issue any kind of content creation, or download using `wget` or `curl` or `git clone`, etc.

### Copy
Singularity has a `copy` command that is basically a wrapper around the system's `/bin/cp`. This means that it accepts all of the same arguments, and option flags and you should look at these:

```
man cp


```

Notably, you might run into the issue of copying a file to your container, and then you can't execute it. This is because you need to use `-p` to preserve permissions:

```
singularity copy container.img -p /path/host/script.sh /bin
```

Done without sudo, the permissions might look something like this:

```
$ singularity exec container.img ls -l /bin/script.sh
-rwxrwxr-x 1 vanessa vanessa 11 Apr 13 16:07 /bin/script.sh
```

If you want to change the owner to root, you can do that first:

```
$ chmod 775 script.sh
$ sudo chown root script.sh
$ sudo singularity copy container.img -p script.sh /bin
$ singularity exec container.img ls -l /bin/script.sh
-rwxrwxr-x 1 root vanessa 11 Apr 13 16:07 /bin/script.sh
$ singularity exec rosdep.img /bin/script.sh
Hello
```

### Mount
Mount is useful for physically mounting a container (it may not even be working) and moving files around.

```
mkdir mnt 
$ singularity mount centos7.img mnt
centos7.img is mounted at: mnt

Spawning a new shell in this namespace, to unmount, exit shell
Singularity: \w> 
```

Note that if you run **without** sudo you won't see any files in the folder. You must run with sudo for them to be viewable. 

```
mkdir mnt 
$ sudo singularity mount centos7.img mnt
centos7.img is mounted at: mnt
$
```

A key difference is that with sudo, it creates the mount and doesn't shell. But even with sudo, you can't copy files. The container is read only.

```
$ cp file.sh mnt/bin/
cp: cannot create regular file 'mnt/bin/file.sh': Read-only file system
$ sudo cp file.sh mnt/bin/
cp: cannot create regular file 'mnt/bin/file.sh': Read-only file system
```

Now if we try with sudo and `--writable`

```
sudo singularity mount --writable centos7.img mnt
centos7.img is mounted at: mnt

$ sudo cp file.sh mnt/bin
```

Does the file execute from outside the container?

```
ls -l mnt/bin/file.sh
-rw-r--r-x 1 root root 13 Apr 13 15:46 mnt/bin/file.sh

ls -l file.sh
-rw-rw-r-x 1 vanessa vanessa 13 Apr 13 15:43 file.sh

./mnt/bin/file.sh
hello
```

Yep. And actually, using `mount` instead of `copy` seems to better preserve (most) of the file's 
attributes. We can do a bit better, however:

```
ls -l mnt/bin/file.sh
-rw-rw-r-x 1 vanessa vanessa 13 Apr 13 15:43 mnt/bin/file.sh
```

We generally recommend that you do not manually move things. It's not good practice.
