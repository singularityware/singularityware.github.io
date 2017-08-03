---
title: Frequently Asked Questions
sidebar: main_sidebar
permalink: faq
folder: docs
---

## General Singularity info

### Why the name "Singularity"?

The name "Singularity" for me (Greg) stems back from my past experience working at a company called <a href="https://en.wikipedia.org/wiki/Linuxcare" target="_blank">Linuxcare</a> where the Linux Boot-able Business Card (LNX-BBC) was developed. The BBC, was a Linux rescue disk which paved the way for all live CD bootable distributions using a loop back file system called the "singularity".

This nomenclature represented that all files within the environment were contained within a single file, and for the same reason Singularity emphasizes the same nomenclature. (Thanks LNX-BBC!)


### Which namespaces are virtualized? Is that select-able?

The goal of Singularity is to run an application within a contained environment such as it was not contained. Thus there is a balance between what to separate and what not to separate. At present the virtualized namespaces are process, mount points, and certain parts of the contained file system.

When you run your Singularity container, you may find that the process IDs start with 1 (one) and increment from there. You will also find that while the file system is contained starting with '/' (root), you can have access outside the container via your starting path. This means that relative paths will resolve outside the container, and fully qualified paths will resolve inside the container.

To achieve this behavior, you will find that several Linux namespaces are separated (PIDS, file systems and descriptors, mounts, and root file system). These can be enabled or disabled by the build and what namespaces the host system supports as well as through environment variables.


### Can't you do this with Docker?

No, not even close. If that was true, there would be no use for Singularity. But in fact, Singularity has taken off within the scientific computing world! Furthermore, if Docker can be used on traditional HPC resources, it would be; but it is not! There are no HPC centers utilizing Docker on their traditional HPC resources because it is inheritiatnly incompatible with HPC.

Singularity has a very different usage model then Docker in that Singularity utilizes complete image files while Docker containers are made up of layers of tar files. With Singularity, you can prefetch an entire container, cache it on shared optimized storage, and run it from there.   Singularity also limits user privileges and access from within the container, making it safe for
user's to bring their own containers. It doesn't open up security risks of users being able to control a root owned daemon, and it integrates seemlessly into existing process and resource manager workflows, supports GPU, MPI, architecture independent, among lots of other aspects that Docker does not.

In the end, Docker is designed for micro-service network virtulization and emulation of the full isolation requirements in the legacy of full machine level virtualization platforms (e.g. VMWare, Xen, KVM, etc.). Singularity is designed specifically for the scentific, application and environment virtulization. The right tool for the right job. :)

If you already have a Docker container you can import/shell/run it directly into Singularity!

```bash
# Create and import
singularity create hello-world.img
singularity import hello-world.img docker://hello-world

# Shell right in
singularity shell docker://hello-world

# Or just run
singularity run docker://hello-world
```

## How is Singularity different from chroot?

While Singularity can in fact operate on a chroot directory (thus giving users the ability to securely run within these directories) the feature set of Singularity goes leaps and bounds beyond! For example, chroot can not operate on directories, utilize kernel namespaces, or be used by users (without SUID even when the user namespace is supported). chroot does not support blurring the line between container and host with bind mounts, devices, and does not limit security access for users, or integrate with traditional HPC resources and services. 


### How does Singularity relate/differ from Shifter?

NERSC (like most HPC centers) are feeling the pressure from users asking for support for containers, specifically Docker. Due to the architecture of Docker it is very difficult (if not impossible) to properly and securely implement in a multi-tenant HPC environment. Shifter is NERSC's implementation to provide a Docker compatible front-end interface to their extreme scale HPC resources. It is system/resource specific in that you must import an existing container (from Docker, Singularity, or other), to the host/Shifter implementation.

Singularity on the other hand does not leverage the Docker work-flow and targets a different premise - Mobility of Compute. This makes the integration of Singularity non-HPC specific (even though it works very well with HPC) and allows the image to become the primary unit of mobility (you can share and operate directly on Singularity images).

Singularity is more of a general purpose mobility of compute solution that is very capable at HPC, Shifter's primary focus is targeting extreme scale HPC and integration with Cray and the resource manager.

### How does Singularity relate/differ from Flatpak

Flatpak is a packaging subsystem that uses some container technologies to create distribution neutral packages and it is more similar to the initial proof of concept of Singularity. But the use-cases of Singularity dictated that we should support full operating system containers that contain the entire user's environment.

### How does Singularity relate/differ from other container systems like OpenVz, LXC/LXD, etc.?

 
Singularity differs from other container systems in several major ways that impact usability on shared systems. For example, most container systems emulate standard systems in that there is the ability and necessity to escalate to root, run on separate IP/network address, run services, and in some cases even virtually boot the container system.

Singularity on the other hand focuses on the ability to virtualized only what is necessary to achieve run-time application container and portable environments. For instance, you can not obtain root from within a Singularity container.

There are some additional performance and design enhancements which make Singularity also more appropriate in a scheduled HPC environment. The back-end image type is one such feature that negates the need for temporary caching of container images and optimizes meta-data IO (especially on parallel file systems). Another feature is how Singularity interacts with the host operating system to facilitate application work-flows like X11 and MPI.

### How does Singularity relate/differ from statically compiled binaries?

Statically compiled binaries are a good comparison to what Singularity can do for a single program because it will package up all of the dynamic libraries and package them into a single executable (interpreted) format.

But because Singularity is actually wrapping operating system files in to a container, you can do much more with it... Such as include other files, scripts, work-flows, pipe lines, data, and multi program processes and package them into a single portable executable format.

### What Linux distributions are you trying to get on-board?

All of them! Help us out by letting them know you want Singularity to be included!


## Basic Singularity usage


### Do you need administrator privileges to use Singularity?

You generally do not need admin/sudo to use Singularity containers. As of version 2.3, you can create, import, run, export, and shell without it. You do however need admin/root access to install Singularity and to bootstrap a container (build it from a specification file called `Singularity`). This means that, given that your cluster has Singularity installed, you are empowered to generate your own portable environments.

This then defines the work-flow to some extent. If you have a container (whether Singularity or Docker) ready to go, you can run/shell/import without root access. If you want to build and bootstrap, then your Singularity container image must be built and configured on a host where you have root access (this can be a physical system or on a VM or Docker image). And of course once the container image has been configured it can be used on a system where you do not have root access as long as Singularity has been installed there.


### What if I don't want to install Singularity on my computer?

If you don't want to build your own images, <a href="https://singularity-hub.org" target="_blank">Singularity Hub</a> will connect to your Github repos with build specification files, and build the containers automatically for you. You can then interact with them easily where Singularity is installed (e.g., on your cluster):

```bash
singularity shell shub://vanessa/singularity-hello-world
singularity run shub://vanessa/singularity-hello-world
singularity create hello-world.img 
singularity import hello-world.img shub://vanessa/singularity-hello-world
```

### Can you edit/modify a Singularity container once it has been instantiated?

Yes, if you call it with the `-w/--writable` flag. (e.g. 'singularity shell --writable Container.img'). However, we recommend to not do this as a regular practice, as it induces changes that are not recorded properly. If you need to rebuild the container, you would need to remember those commands.


### Can multiple applications be packaged into one Singularity Container?

Yes! You can even create entire pipe lines and work flows using many applications, binaries, scripts, etc.. The `%runscript` bootstrap section is where you can define what happens when a Singularity container is run. This definition takes priority over all "other places" that might define a container's execution. Specifically:

 - The `%runscript` section of the bootstrap file takes priority over all
 - If you bootstrap a docker image, the `ENTRYPOINT` is used if there is no `%runscript`
 - If you add `Includecmd: yes` to your definition file header, the `CMD` is used instead
 - No `%runscript`, `ENTRYPOINT` OR `CMD` means the container's default execution is `/bin/bash`


### How are external file systems and paths handled in a Singularity Container?

Because Singularity is based on container principals, when an application is run from within a Singularity container its default view of the file system is different from how it is on the host system. This is what allows the environment to be portable. This means that root ('/') inside the container is different from the host!

Singularity automatically tries to resolve directory mounts such that things will just work and be portable with whatever environment you are running on. This means that `/tmp` and `/var/tmp` are automatically shared into the container as is `/home`. Additionally, if you are in a current directory that is not a system directory, Singularity will also try to bind that to your container.

There is a caveat in that a directory *must* already exist within your container to serve as a mount point. If that directory does not exist, Singularity will not create it for you! You must do that. To create custom mounts at runtime, you should use the `-B` or `--bind` argument:

```bash
singularity run --bind /home/vanessa/Desktop:/data container.img
```


### How does Singularity handle networking?

Singularity does no network isolation because it is designed to run like any other application on the system. It has all of the same networking privileges as any program running as that user. Thus, if you run a process in the container directed to localhost, it will show up on your host machine browser as localhost. Take a look at some of our <a href="https://github.com/vsoch/singularity-web" target="_blank">web examples</a> to get a sense for this.


### Can I import an image from Docker?

Yes, you can do this with our import, even without sudo. With import, the Docker layers (the dump of files) plus the environment, and labels are added to the container.

```bash
$ singularity import container.img docker://ubuntu:latest
```

You can also do this by way of bootstrapping Docker images, and to do this you would create a definition file, an image, and then bootstrap. First, here is most simplest definition file, "Singularity":

```bash
Bootstrap: docker
From: ubuntu:latest
```

Now let's create an image and bootstrap using the Singularity file:

```bash
$ singularity create ubuntu.img
$ singularity bootstrap ubuntu.img Singularity
```

Make sure you are running Singularity > 2.2 to make full use of this feature.


### Can a Singularity container be multi-threaded?

Yes. Singularity imposes no limitations on forks, threads or processes in general.

### Can a Singularity container be suspended or check-pointed?

Yes and maybe respectively. Any Singularity application can be suspended using standard Linux/Unix signals. Check-pointing requires some preloaded libraries to be automatically loaded with the application but because Singularity escapes the hosts library stack, the checkpoint libraries would not be loaded. If however you wanted to make a Singularity container that can be check-pointed, you would need to install the checkpoint libraries into the Singularity container via the specfile


### Are there any special requirements to use Singularity through a job scheduler?

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

### Why do we call 'mpirun' from outside the container (rather then inside)?

With Singularity, the MPI usage model is to call 'mpirun' from outside the container, and reference the container from your 'mpirun' command. Usage would look like this:

```bash
$ mpirun -np 20 singularity exec container.img /path/to/contained_mpi_prog
```

By calling 'mpirun' outside the container, we solve several very complicated work-flow aspects. For example, if 'mpirun' is called from within the container it must have a method for spawning processes on remote nodes. Historically ssh is used for this which means that there must be an sshd running within the container on the remote nodes, and this sshd process must not conflict with the sshd running on that host! It is also possible for the resource manager to launch the job and (in Open MPI's case) the Orted processes on the remote system, but that then requires resource manager modification and container awareness.

In the end, we do not gain anything by calling 'mpirun' from within the container except for increasing the complexity levels and possibly loosing out on some added performance benefits (e.g. if a container wasn't built with the proper OFED as the host).

See the Singularity on HPC page for more details.


### Does Singularity support containers that require GPUs?

Yes, Singularity has been tested to run some test and diagnostic code from within a container without modification. There are however potential issues that can come into play when using GPUs, for instance there are version API compatibilities between kernel and user land which will have to be considered.

## Container portability

### Are Singularity containers kernel dependent?

No, never. But sometimes yes.

Singularity is using standard container principals and methods so if you are leveraging any kernel version specific or external patches/module functionality (e.g. OFED), then yes there maybe kernel dependencies you will need to consider.

Luckily most people that would hit this are people that are using Singularity to inter-operate with an HPC (High Performance Computing) system where there are highly tuned interconnects and file systems you wish to make efficient use of. In this case, See the documentation of MPI with Singularity.

There is also some level of glibc forward compatibility that must be taken into consideration for any container system. For example, I can take a Centos-5 container and run it on Centos-7, but I can not take a Centos-7 container and run it on Centos-5.

note: If you require kernel dependent features, a container platform is probably not the right solution for you.

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
$ sudo singularity create /tmp/centos.img
sudo: singularity: command not found
```

The cause of the problem is that `sudo` sanitizes the PATH environment variable and does not include /usr/local/bin in the default search path. Considering this program path is by default owned by root, it is reasonable to extend the default sudo PATH to include this directory.

To add /usr/local/bin to the default sudo search path, run the program visudo which will edit the sudoers file, and search for the string 'secure_path'. Once found, append :/usr/local/bin to that line so it looks like this:

```bash
Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
```
{% include links.html %}
