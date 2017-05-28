---
title: Singularity Exec
sidebar: user_docs
permalink: docs-exec
folder: docs
toc: false
---

The `exec` Singularity sub-command allows you to spawn an arbitrary command within your container image as if it were running directly on the host system. All standard IO, pipes, and file systems are accessible via the command being exec'ed within the container. Note that this exec is different from the Docker exec, as it does not require a container to be "running" before using it.

## Usage

The usage is as follows:

```bash
USAGE: singularity [...] exec [exec options...] <container path> <command>

This command will allow you to execute any program within the given
container image.

EXEC OPTIONS:
    -B/--bind <spec>    A user-bind path specification.  spec has the format
                        src[:dest[:opts]], where src and dest are outside and
                        inside paths.  If dest is not given, it is set equal
                        to src.  Mount options ('opts') may be specified as
                        'ro' (read-only) or 'rw' (read/write, which is the 
                        default). This option can be called multiple times.
    -c/--contain        This option disables the automatic sharing of writable
                        filesystems on your host (e.g. $HOME and /tmp).
    -C/--containall     Contain not only file systems, but also PID and IPC 
    -e/--cleanenv       Clean environment before running container
    -H/--home <spec>    A home directory specification.  spec can either be a
                        src path or src:dest pair.  src is the source path
                        of the home directory outside the container and dest
                        overrides the home directory within the container
    -i/--ipc            Run container in a new IPC namespace
    -p/--pid            Run container in a new PID namespace
    --pwd               Initial working directory for payload process inside 
                        the container
    -S/--scratch <path> Include a scratch directory within the container that 
                        is linked to a temporary dir (use -W to force location)
    -u/--user           Try to run completely unprivileged (only works on very
                        new kernels/distros)
    -W/--workdir        Working directory to be used for /tmp, /var/tmp and
                        $HOME (if -c/--contain was also used)
    -w/--writable       By default all Singularity containers are available as
                        read only. This option makes the file system accessible
                        as read/write.


CONTAINER FORMATS SUPPORTED:
    *.img               This is the native Singularity image format for all
                        Singularity versions 2.x.
    *.sqsh              SquashFS format, note the suffix is required!
    *.tar*              Tar archives are exploded to a temporary directory and
                        run within that directory (and cleaned up after). 
                        Compression suffixes as '.gz' and 'bz2' are supported.
    directory/          Container directories that contain a valid root file
                        system.


EXAMPLES:
    
    $ singularity exec /tmp/Debian.img cat /etc/debian_version
    $ singularity exec /tmp/Debian.img python ./hello_world.py
    $ cat hello_world.py | singularity exec /tmp/Debian.img python
    $ sudo singularity exec --writable /tmp/Debian.img apt-get update

```

### Examples

#### Printing the OS release inside the container:

```bash
$ singularity exec container.img cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 8 (jessie)"
NAME="Debian GNU/Linux"
VERSION_ID="8"
VERSION="8 (jessie)"
ID=debian
HOME_URL="http://www.debian.org/"
SUPPORT_URL="http://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
$ 
```

#### Special Characters
And properly passing along special characters to the program within the container.

```bash
$ singularity exec container.img echo -ne "hello\nworld\n\n"
hello
world
$ 
```

And a demonstration using pipes:

```bash
$ cat debian.def | singularity exec container.img grep 'MirrorURL'
MirrorURL "http://ftp.us.debian.org/debian/"
$ 
```


#### A Python example
Starting with the file `hello.py` in the current directory with the contents of:

```python
#!/usr/bin/python

import sys
print("Hello World: The Python version is %s.%s.%s" % sys.version_info[:3])
```

Because our home directory is automatically bound into the container, and we are running this from our home directory, we can easily execute that script using the Python within the container:

```bash
$ singularity exec /tmp/Centos7-ompi.img /usr/bin/python hello.py 
Hello World: The Python version is 2.7.5
```

We can also pipe that script through the container and into the Python binary which exists inside the container using the following command:

```bash
$ cat hello.py | singularity exec /tmp/Centos7-ompi.img /usr/bin/python 
Hello World: The Python version is 2.7.5
```

For demonstration purposes, let's also try to use the latest Python container which exists in DockerHub to run this script:

```bash
$ singularity exec docker://python:latest /usr/local/bin/python hello.py
library/python:latest
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:fbd06356349dd9fb6af91f98c398c0c5d05730a9996bbf88ff2f2067d59c70c4
Downloading layer: sha256:644eaeceac9ff6195008c1e20dd693346c35b0b65b9a90b3bcba18ea4bcef071
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:766692404ca72f4e31e248eb82f8eca6b2fcc15b22930ec50e3804cc3efe0aba
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:6a3d69edbe90ef916e1ecd8d197f056de873ed08bcfd55a1cd0b43588f3dbb9a
Downloading layer: sha256:ff18e19c2db42055e6f34323700737bde3c819b413997cddace2c1b7180d7efd
Downloading layer: sha256:7b9457ec39de00bc70af1c9631b9ae6ede5a3ab715e6492c0a2641868ec1deda
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:6a5a5368e0c2d3e5909184fa28ddfd56072e7ff3ee9a945876f7eee5896ef5bb
Hello World: The Python version is 3.5.2
```
