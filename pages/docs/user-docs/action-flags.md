---
title: Singularity Action Flags
sidebar: user_docs
permalink: action-flags
folder: docs
toc: false
---

For each of `exec`, `run`, and `shell`, there are a few important flags that we want to note for new users that have substantial impact on using your container. While we won't include the complete list of run options (for this complete list see `singularity run --help` or more generally `singularity <action> --help`) we will review some highly useful flags that you can add to these actions.

 - **--contain**: Contain suggests that we want to better isolate the container runtime from the host. Adding the `--contain` flag will use minimal `/dev` and empty other directories (e.g., `/tmp`).
 - **--containall**: In addition to what is provided with `--contain` (filesystems) also contain PID, IPC, and environment.
 - **--cleanenv**: Clean the environment before running the container.
 - **--pwd**: Initial working directory for payload process inside the container.

This is **not** a complete list! Please see the `singularity <action> help` for an updated list.


## Examples
Here we are cleaning the environment. In the first command, we see that the variable `PEANUTBUTTER` gets passed into the container.

```
PEANUTBUTTER=JELLY singularity exec Centos7.img env | grep PEANUT
PEANUTBUTTER=JELLY
```

And now here we add `--cleanenv` to see that it doesn't.


```
PEANUTBUTTER=JELLY singularity exec --cleanenv Centos7.img env | grep PEANUT
```

Here we will test contain. We can first confirm that there are a lot of files on our host in `/tmp`, and the same files are found in the container.

```
# On the host
$ ls /tmp | wc -l
17

# And then /tmp is mounted to the container, by default
$ singularity exec Centos7.img  ls /tmp | wc -l

# ..but not if we use --contain
$ singularity exec --contain Centos7.img  ls /tmp | wc -l
0
```
