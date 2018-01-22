---
title: Frequently Asked Questions
sidebar: main_sidebar
permalink: faq
folder: docs
---

## General Singularity info

### Why the name "Singularity"?
A "Singularity" is an astrophysics phenomenon in which a single point becomes infinitely dense. This type of a singularity can thus contain massive quantities of universe within it and thus encapsulating an infinite amount of data within it.

Additionally, the name "Singularity" for me (Greg) also stems back from my past experience working at a company called <a href="https://en.wikipedia.org/wiki/Linuxcare" target="_blank">Linuxcare</a> where the Linux Bootable Business Card (LNX-BBC) was developed. The BBC, was a Linux rescue disk which paved the way for all live CD bootable distributions using a compressed single image file system called the "singularity".

The name has **NOTHING** to do with Kurzweil's (among others) prediction that artificial intelligence will abruptly have the ability to reprogram itself, surpass that of human intelligence and take control of the planet. If you are interested in this may I suggest the movie **Terminator 2: Judgement Day**.

### What is so special about Singularity?
While Singularity is a container solution (like many others), Singularity differs in it's primary design goals and architecture:

1. **Reproducible software stacks:** These must be easily verifiable via checksum or cryptographic signature in such a manner that does not change formats (e.g. splatting a tarball out to disk). By default Singularity uses a container image file which can be checksummed, signed, and thus easily verified and/or validated.
2. **Mobility of compute:** Singularity must be able to transfer (and store) containers in a manner that works with standard data mobility tools (rsync, scp, gridftp, http, NFS, etc..) and maintain software and data controls compliancy (e.g. HIPPA, nuclear, export, classified, etc..)
3. **Compatibility with complicated architectures:** The runtime must be immediately compatible with existing HPC, scientific, compute farm and even enterprise architectures any of which maybe running legacy kernel versions (including RHEL6 vintage systems) which do not support advanced namespace features (e.g. the user namespace)
4. **Security model:** Unlike many other container systems designed to support *trusted users running trusted containers* we must support the opposite model of *untrusted users running untrusted containers*. This changes the security paradigm considerably and increases the breadth of use cases we can support.


### Which namespaces are virtualized? Is that select-able?
That is up to you!

While some namespaces, like newns (mount) and fs (file system) must be virtualized, all of the others are conditional depending on what you want to do. For example, if you have a workflow that relies on communication between containers (e.g. MPI), it is best to not isolate any more than absolutely necessary to avoid performance regressions. While other tasks are better suited for isolation (e.g. web and data base services).

Namespaces are selected via command line usage and system administration configuration.

### What Linux distributions are you trying to get on-board?
All of them! Help us out by letting them know you want Singularity to be included!


### How do I request an installation on my resource?
It's important that your administrator have all of the resources available to him or her to make a decision to install Singularity. We've prepared a [helpful guide](/install-request) that you can send to him or her to start a conversation. If there are any unanswered questions, we recommend that you [reach out](/support).

## Basic Singularity usage

### Do you need administrator privileges to use Singularity?
You generally do not need admin/sudo to use Singularity containers but you do however need admin/root access to install Singularity and for some container build functions (for example, building from a recipe, or a writable image).

This then defines the work-flow to some extent. If you have a container (whether Singularity or Docker) ready to go, you can run/shell/import without root access. If you want to build a new Singularity container image from scratch it must be built and configured on a host where you have root access (this can be a physical system or on a VM). And of course once the container image has been configured it can be used on a system where you do not have root access as long as Singularity has been installed there.


### What if I don't want to install Singularity on my computer?
If you don't want to build your own images, <a href="https://singularity-hub.org" target="_blank">Singularity Hub</a> will connect to your Github repos with build specification files, and build the containers automatically for you. You can then interact with them easily where Singularity is installed (e.g., on your cluster):

```bash
singularity shell shub://vsoch/hello-world
singularity run shub://vsoch/hello-world
singularity pull shub://vsoch/hello-world
singularity build hello-world.simg shub://vsoch/hello-world # redundant, you would already get an image
```

### Can you edit/modify a Singularity container once it has been instantiated?
We strongly advocate for reproducibility, so if you build a squashfs container, it is immutable. However, if you build with `--sandbox` or `--writable` you can produce a writable sandbox folder or a writable ext3 image, respectively. From a sandbox you can develop, test, and make changes, and then build or convert it into a standard image.

We recommend to use the default compressed, immutable format for production containers.

### Can multiple applications be packaged into one Singularity Container?
Yes! You can even create entire pipe lines and work flows using many applications, binaries, scripts, etc.. The `%runscript` bootstrap section is where you can define what happens when a Singularity container is run, and with the introduction of [modular apps](/docs-apps) you can now even define `%apprun` sections for different entrypoints to your container.

### How are external file systems and paths handled in a Singularity Container?
Because Singularity is based on container principals, when an application is run from within a Singularity container its default view of the file system is different from how it is on the host system. This is what allows the environment to be portable. This means that root ('/') inside the container is different from the host!

Singularity automatically tries to resolve directory mounts such that things will just work and be portable with whatever environment you are running on. This means that `/tmp` and `/var/tmp` are automatically shared into the container as is `/home`. Additionally, if you are in a current directory that is not a system directory, Singularity will also try to bind that to your container.

There is a caveat in that a directory *must* already exist within your container to serve as a mount point. If that directory does not exist, Singularity will not create it for you! You must do that. To create custom mounts at runtime, you should use the `-B` or `--bind` argument:

```bash
singularity run --bind /home/vanessa/Desktop:/data container.img
```


### How does Singularity handle networking?
As of 2.4, Singularity can support the network namespace to a limited degree. At present, we just use it for isolation, but it will soon be more featurefull.


### Can Singularity support daemon processes?
Singularity has container "instance" support which allows one to start a container process, within its own namespaces, and use that instance like it was a stand alone, isolated system.

At the moment (as above describes), the network (and UTS) namespace is not well supported, so if you spin up a process daemon, it will exist on your host's network. This means you can run a web server, or any other daemon, from within a container and access it directly from your host.

### Can a Singularity container be multi-threaded?
Yes. Singularity imposes no limitations on forks, threads or processes in general.

### Can a Singularity container be suspended or check-pointed?
Yes and maybe respectively. Any Singularity application can be suspended using standard Linux/Unix signals. Check-pointing requires some preloaded libraries to be automatically loaded with the application but because Singularity escapes the hosts library stack, the checkpoint libraries would not be loaded. If however you wanted to make a Singularity container that can be check-pointed, you would need to install the checkpoint libraries into the Singularity container via the specfile.

On our roadmap is the ability to checkpoint the entire container process thread, and restart it. Keep an eye out for that feature!


### Are there any special requirements to use Singularity through an HPC job scheduler?
Singularity containers can be run via any job scheduler without any modifications to the scheduler configuration or architecture. This is because Singularity containers are designed to be run like any application on the system, so within your job script just call Singularity as you would any other application!


### Does Singularity work in multi-tenant HPC cluster environments?
Yes! HPC was one of the primary use cases in mind when Singularity was created.

Most people that are currently integrating containers on HPC resources do it by creating virtual clusters within the physical host cluster. This precludes the virtual cluster from having access to the host cluster's high performance fabric, file systems and other investments which make an HPC system high performance.

Singularity on the other hand allows one to keep the high performance in High Performance Computing by containerizing applications and supporting a runtime which seamlessly interfaces with the host system and existing environments.

### Can I run X11 apps through Singularity?
Yes. This works exactly as you would expect it to.

### Can I containerize my MPI application with Singularity and run it properly on an HPC system?
Yes! HPC was one of the primary use cases in mind when Singularity was created.

While we know for a fact that Singularity can support multiple MPI implementations, we have spent a considerable effort working with Open MPI as well as adding a Singularity module into Open MPI (v2) such that running at extreme scale will be as efficient as possible.

note: We have seen no major performance impact from running a job in a Singularity container.

### Why do we call 'mpirun' from outside the container (rather than inside)?
With Singularity, the MPI usage model is to call 'mpirun' from outside the container, and reference the container from your 'mpirun' command. Usage would look like this:

```bash
$ mpirun -np 20 singularity exec container.img /path/to/contained_mpi_prog
```

By calling 'mpirun' outside the container, we solve several very complicated work-flow aspects. For example, if 'mpirun' is called from within the container it must have a method for spawning processes on remote nodes. Historically ssh is used for this which means that there must be an sshd running within the container on the remote nodes, and this sshd process must not conflict with the sshd running on that host! It is also possible for the resource manager to launch the job and (in Open MPI's case) the Orted processes on the remote system, but that then requires resource manager modification and container awareness.

In the end, we do not gain anything by calling 'mpirun' from within the container except for increasing the complexity levels and possibly losing out on some added performance benefits (e.g. if a container wasn't built with the proper OFED as the host).

See the Singularity on HPC page for more details.

### Does Singularity support containers that require GPUs?

Yes. Many users run GPU-dependent code within Singularity containers.  The
experimental `--nv` option allows you to leverage host GPUs without installing 
system level drivers into your container. See the [`exec`](/docs-exec#a-gpu-example) command for
an example.

## Container portability

### Are Singularity containers kernel-dependent?
No, never. But sometimes yes.

Singularity is using standard container principals and methods so if you are leveraging any kernel version specific or external patches/module functionality (e.g. OFED), then yes there maybe kernel dependencies you will need to consider.

Luckily most people that would hit this are people that are using Singularity to inter-operate with an HPC (High Performance Computing) system where there are highly tuned interconnects and file systems you wish to make efficient use of. In this case, See the documentation of MPI with Singularity.

There is also some level of glibc forward compatibility that must be taken into consideration for any container system. For example, I can take a Centos-5 container and run it on Centos-7, but I can not take a Centos-7 container and run it on Centos-5.

note: If you require kernel-dependent features, a container platform is probably not the right solution for you.

### Can a Singularity container resolve GLIBC version mismatches?
Yes. Singularity containers contain their own library stack (including the Glibc version that they require to run).

### What is the performance trade off when running an application native or through Singularity?
So far we have not identified any appreciable regressions of performance (even in parallel applications running across nodes with InfiniBand). There is a small start-up cost to create and tear-down the container, which has been measured to be anywhere from 10 - 20 thousandths of a second.

## Misc

The following are miscellaneous questions.

### Are there any special security concerns that Singularity introduces?
No and yes.

While Singularity containers always run as the user launching them, there are some aspects of the container execution which requires escalation of privileges. This escalation is achieved via a SUID portion of code. Once the container environment has been instantiated, all escalated privileges are dropped completely, before running any programs within the container.

Additionally, there are precautions within the container context to mitigate any escalation of privileges. This limits a user's ability to gain root control once inside the container.

You can read more about the Singularity <a href="/docs-security">security overview here</a>.

## Troubleshooting
A little bit of help.

### Segfault on Bootstrap of Centos Image
If you are bootstrapping a centos 6 docker image from a debian host, you might hit a segfault:

```
$ singularity shell docker://centos:6 
Docker image path: index.docker.io/library/centos:6
Cache folder set to /home/jbdenis/.singularity/docker
Creating container runtime...
Singularity: Invoking an interactive shell within container...

Segmentation fault
```

The fix is on your host, you need to pass the variable `vsyscall=emulate` to the kernel, meaning in the file `/etc/default/grub` (note, this file is debian specific), add the following:

```
GRUB_CMDLINE_LINUX_DEFAULT="vsyscall=emulate"
```

and then update grub and reboot:

```
update-grub && reboot
```

Please note that this change might have <a href="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/kernel-parameters.txt?h=v4.13-rc3#n4387" target="_blank">security implications</a> that you should be aware of. For more information, see the <a href="https://github.com/singularityware/singularity/issues/845" target="_blank">original issue</a>.


### How to use Singularity with GRSecurity enabled kernels
To run Singularity on a GRSecurity enabled kernel, you must disable several security features:

```bash
$ sudo sysctl -w kernel.grsecurity.chroot_caps=0
$ sudo sysctl -w kernel.grsecurity.chroot_deny_mount=0
$ sudo sysctl -w kernel.grsecurity.chroot_deny_chmod=0
$ sudo sysctl -w kernel.grsecurity.chroot_deny_fchdir=0
```

### The container isn't working on a different host!
Singularity by default mounts your home directory. While this is great for seamless communication between your host and the container, it can introduce issues if you have software modules installed at `$HOME`. For example, we had a user <a href="https://github.com/singularityware/singularity/issues/476" target="_blank">run into this issue</a>. 


#### Solution 1: Specify the home to mount
A first thing to try is to point to some "sanitized home," which is the purpose of the `-H` or `--home` option. For example, here we are creating a home directory under `/tmp/homie`, and then telling the container to mount it as home:

```bash
rm -rf /tmp/homie && mkdir -p /tmp/homie && \
singularity exec -H /tmp/homie analysis.img /bin/bash
```

#### Solution 2: Specify the executable to use
It may be the issue that there is an executable in your host environment (eg, python) that is being called in preference to the containers. To avoid this, in your runscript (the `%runscript` section of the bootstrap file) you should specify the path to the executable exactly. This means:


```bash
%runscript

# This specifies the python in the container
exec /usr/bin/python "$@"

# This may pick up a different one
exec python "$@"
```

This same idea would be useful if you are issuing the command to the container using `exec`. Thanks to <a href="https://github.com/yarikoptic" target="_blank">yarikoptic</a> for the suggestions on this issue.


### Invalid Argument or Unknown Option
When I try mounting my container with the `-B` or `--bind` option I receive an <i>unknown option</i> or <i>Invalid argument</i> error.

Make sure that you are using the most recent Singularity release to mount your container to the host system, and that the `--bind` argument is placed after the execution command. An example might look like this:

```bash
$ singularity run -B $PWD:/data my_container.img
```

Also, make sure you are using an up-to-date Singularity to bootstrap your container.  Some features (such as `--bind`) will not work in earlier versions.


### Error running Singularity with sudo
This fix solves the following error when Singularity is installed into the default compiled prefix of /usr/local:

```bash
$ sudo singularity instance.start container.img daemon1
sudo: singularity: command not found
```

The cause of the problem is that `sudo` sanitizes the PATH environment variable and does not include /usr/local/bin in the default search path. Considering this program path is by default owned by root, it is reasonable to extend the default sudo PATH to include this directory.

To add /usr/local/bin to the default sudo search path, run the program visudo which will edit the sudoers file, and search for the string 'secure_path'. Once found, append :/usr/local/bin to that line so it looks like this:

```bash
Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
```

### How to resolve "Too many levels of symbolic links" error
Running singularity failed with "Too many levels of symbolic links" error

```bash
$ singularity run -B /apps container.img
ERROR : There was an error binding the path /apps: Too many levels of symbolic links
ABORT : Retval = 255
```

You got this error because /apps directory is an autofs mount point. You can fix it by editing singularity.conf and adding the following directive with corresponding path:
```bash
autofs bug path = /apps
```

{% include links.html %}
