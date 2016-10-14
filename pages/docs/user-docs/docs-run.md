---
title: Singularity Run
sidebar: user_docs
permalink: docs-run
folder: docs
toc: false
---

## Usage
Singularity `run` allows you to define a custom action to be taken when a container is either `run` or executed directly by file name. The action is defined by a Singularity "runscript" which is an executable file (script or binary) located within the container physically at '/singularity'.

The usage is as follows:

```bash
$ singularity run
USAGE: singularity (options) run [container image] (options)
The command that you want to exec will follow the container image along with any additional arguments will all be passed directly to the program being executed within the container.
You can also execute the container directly, and it will automatically pass the execution process to the Singularity runscript along with any arguments.
```

### Examples

As we have defined within the `%runscript` in [bootstrap](/bootstrap-image), we can execute a script, workflow, or a given command using the `run` Singularity container interface command. In the above examples, we specified the run script to `exec /usr/bin/python "%@"` which will call Python and pass along any arguments we have supply.

For example:

```bash
$ singularity run /tmp/Centos7-ompi.img --version
Python 2.7.5
$ singularity run /tmp/Centos7-ompi.img hello.py 
Hello World: The Python version is 2.7.5
$ singularity run /tmp/Centos7-ompi.img 
Python 2.7.5 (default, Nov 20 2015, 02:00:19) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-4)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 
```


## Executing a container directly
Additionally, the `run` interface gets called when the container file is executed directly (yes, the container is set as executable!):

```bash
$ ls -l /tmp/Centos7-ompi.img 
-rwxr-xr-x. 1 root root 2147483679 Oct  9 05:31 /tmp/Centos7-ompi.img
$ /tmp/Centos7-ompi.img hello.py 
Hello World: The Python version is 2.7.5
```

This means you could even rename this container to something related to the runscript (perhaps "*centos7-python.exe*") and have users call that directly instead of the system python program.

