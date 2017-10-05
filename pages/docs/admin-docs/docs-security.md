---
title: Security
sidebar: admin_docs
permalink: docs-security
folder: docs
---
 
{% include toc.html %}

## Container security paradigms
First some background. Most container platforms operate on the premise, **trusted users running trusted containers**. This means that the primary UNIX account controlling the container platform is either "root" or user(s) that root has deputized (either via `sudo` or given access to a control socket of a root owned daemon process). 

Singularity on the other hand, operates on a different premise because it was developed for HPC type infrastructures where you have users, none of which are considered trusted. This means the paradigm is considerably different as we must support **untrusted users running untrusted containers**.

## Untrusted users running untrusted containers!
This simple phrase describes the security perspective Singularity is designed with. And if you additionally consider the fact that running containers at all typically requires some level of privilege escalation, means that attention to security is of the utmost importance.

### Privilege escalation is necessary for containerization!
As mentioned, there are several containerization system calls and functions which are considered "privileged" in that they must be executed with a certain level of capability/privilege. To do this, all container systems must employ one of the following mechanisms:

1. **Limit usage to root:** Only allow the root user (or users granted `sudo`) to run containers. This has the obvious limitation of not allowing arbitrary users the ability to run containers, nor does it allow users to run containers as themselves. Access to data, security data, and securing systems becomes difficult and perhaps impossible.
* **Root owned daemon process:** Some container systems use a root owned daemon background process which manages the containers and spawns the jobs within the container. Implementations of this typically have an IPC control socket for communicating with this root owned daemon process and if you wish to allow trusted users to control the daemon, you must give them access to the control socket. This is the Docker model.
* **SetUID:** Set UID is the "old school" UNIX method for running a particular program with escalated permission. While it is widely used due to it's legacy and POSIX requirement, it lacks the ability to manage fine grained control of what a process can and can not do; a SetUID root program runs as root with all capabilities that comes with root. For this reason, SetUID programs are traditional targets for hackers.
* **User Namespace:** The Linux kernel's user namespace may allow a user to virtually become another user and run a limited set privileged system functions. Here the privilege escalation is managed via the Linux kernel which takes the onus off of the program. This is a new kernel feature and thus requires new kernels and not all distributions have equally adopted this technology.
* **Capability Sets:** Linux handles permissions, access, and roles via capability sets. The root user has these capabilities automatically activated while non-privileged users typically do not have these capabilities enabled. You can enable and disable capabilities on a per process and per file basis (if allowed to do so).

### How does Singularity do it?
Singularity must allow users to run containers as themselves which rules out options 1 and 2 from the above list. Singularity supports the rest of the options to following degrees of functionally:

* **User Namespace:** Singularity supports the user namespace natively and can run completely unprivileged ("rootless") since version 2.2 (October 2016) but features are severely limited. You will not be able to use container "images" and will be forced to only work with directory (sandbox) based containers. Additionally, as mentioned, the user namespace is not equally supported on all distribution kernels so don't count on legacy system support and usability may vary.
* **SetUID:** This is the default usage model for Singularity because it gives the most flexibility in terms of supported features and legacy compliance. It is also the most risky from a security perspective. For that reason, Singularity has been developed with transparency in mind. The code is written with attention to simplicity and readability and Singularity increases the effective permission set only when it is necessary, and drops it immediately (as can be seen with the `--debug` run flag). There have been several independent audits of the source code, and while they are not definitive, it is a good assurance.
* **Capability Sets:** This is where Singularity is headed as an alternative to SetUID because it allows for much finer grained capability control and will support all of Singularity's features. The downside is that it is not supported equally on shared file systems.

## Where are the Singularity privileged components
When you install Singularity as root, it will automatically setup the necessary files as SetUID (as of version 2.4, this is the default run mode). The location of these files is dependent on how Singularity was installed and the options passed to the `configure` script. Assuming a default `./configure` run which installs files into `--prefix` of `/usr/local` you can find the SetUID programs as follows:

```bash
$ find /usr/local/libexec/singularity/ -perm -4000
/usr/local/libexec/singularity/bin/start-suid
/usr/local/libexec/singularity/bin/action-suid
/usr/local/libexec/singularity/bin/mount-suid
```
 
Each of the binaries is named accordingly to the action that it is suited for, and generally, each handles the required privilege escalation necessary for Singularity to operate. What specifically requires escalated privileges?
 
1. Mounting (and looping) the Singularity container image
2. Creation of the necessary namespaces in the kernel
3. Binding host paths into the container
 
Removing any of these SUID binaries or changing the permissions on them would cause Singularity to utilize the non-SUID workflows. Each file with `*-suid` also has a non-suid equivalent:
 
```bash
/usr/local/libexec/singularity/bin/start
/usr/local/libexec/singularity/bin/action
/usr/local/libexec/singularity/bin/mount
```
 
While most of these workflows will not properly function without the SUID components, we have provided these fall back executables for sites that wish to limit the SETUID capabilities to the bare essentials/minimum. To disable the SetUID portions of Singularity, you can either remove the above `*-suid` files, or you can edit the setting for `allow suid` at the top of the `singularity.conf` file, which is typically located in `$PREFIX/etc/singularity/singularity.conf`.

```
# ALLOW SETUID: [BOOL]
# DEFAULT: yes
# Should we allow users to utilize the setuid program flow within Singularity?
# note1: This is the default mode, and to utilize all features, this option
# will need to be enabled.
# note2: If this option is disabled, it will rely on the user namespace
# exclusively which has not been integrated equally between the different
# Linux distributions.
allow setuid = yes
```

You can also install Singularity as root without any of the SetUID components with the configure option `--disable-suid` as follows:

```bash
$ ./configure --disable-suid --prefix=/usr/local
$ make
$ sudo make install
```
 
## Can I install Singularity as a user?
Yes, but don't expect all of the functions to work. If the SetUID components are not present, Singularity will attempt to use the "user namespace". Even if the kernel you are using supports this namespace fully, you will still not be able to access all of the Singularity features.


## Container permissions and usage strategy
As a system admin, you want to set up a configuration that is customized for your cluster or shared resource. In the following paragraphs, we will elaborate on this container permissions strategy, giving detail about which users are allowed to run containers, along with image curation and ownership.

These settings can all be found in the Singularity configuration file which is installed to `$PREFIX/etc/singularity/singularity.conf`. When running in a privileged mode, the configuration file **MUST** be owned by root and thus the system administrator always has the final control.

### controlling what kind of containers are allowed
Singularity supports several different container formats:

* **squashfs:** Compressed immutable (read only) container images (default in version 2.4)
* **extfs:** Raw file system writable container images
* **dir:** Sandbox containers (*chroot* style directories)

Using the Singularity configuration file, you can control what types of containers Singularity will support:

```bash
# ALLOW CONTAINER ${TYPE}: [BOOL]
# DEFAULT: yes
# This feature limits what kind of containers that Singularity will allow
# users to use (note this does not apply for root).
allow container squashfs = yes
allow container extfs = yes
allow container dir = yes
```

### limiting usage to specific container file owners
One benefit of using container images is that they exist on the filesystem as any other file would. This means that POSIX permissions are mandatory. Here you can configure Singularity to only "trust" containers that are owned by a particular set of users.
 
```bash
# LIMIT CONTAINER OWNERS: [STRING]
# DEFAULT: NULL
# Only allow containers to be used that are owned by a given user. If this
# configuration is undefined (commented or set to NULL), all containers are
# allowed to be used. This feature only applies when Singularity is running in
# SUID mode and the user is non-root.
#limit container owners = gmk, singularity, nobody
```

*note: If you are in a high risk security environment, you may want to enable this feature. Trusting container images to users could allow a malicious user to modify an image either before or while being used and cause unexpected behavior from the kernel (e.g. a [DOS attack](https://en.wikipedia.org/wiki/Denial-of-service_attack)). For more information, please see: [https://lwn.net/Articles/652468/](https://lwn.net/Articles/652468/)*

### limiting usage to specific paths
The configuration file also gives you the ability to limit containers to specific paths. This is very useful to ensure that only trusted or blessed container's are being used (it is also beneficial to ensure that containers are only being used on performant file systems). 

```bash
# LIMIT CONTAINER PATHS: [STRING]
# DEFAULT: NULL
# Only allow containers to be used that are located within an allowed path
# prefix. If this configuration is undefined (commented or set to NULL),
# containers will be allowed to run from anywhere on the file system. This
# feature only applies when Singularity is running in SUID mode and the user is
# non-root.
#limit container paths = /scratch, /tmp, /global
```
 
## Logging
Singularity offers a very comprehensive auditing mechanism via the system log. For each command that is issued, it prints the UID, PID, and location of the command. For example, let’s see what happens if we shell into an image:
 
```
$ singularity exec ubuntu true
$ singularity shell --home $HOME:/ ubuntu
Singularity: Invoking an interactive shell within container...

ERROR  : Failed to execv() /.singularity.d/actions/shell, continuing to /bin/sh: No such file or directory
ERROR  : What are you doing gmk, this is highly irregular!
ABORT  : Retval = 255
```
 
We can then peek into the system log to see what was recorded:
 
```bash
Oct  5 08:51:12 localhost Singularity: action-suid (U=1000,P=32320)> USER=gmk, IMAGE='ubuntu', COMMAND='exec'
Oct  5 08:53:13 localhost Singularity: action-suid (U=1000,P=32311)> USER=gmk, IMAGE='ubuntu', COMMAND='shell'
Oct  5 08:53:13 localhost Singularity: action-suid (U=1000,P=32311)> Failed to execv() /.singularity.d/actions/shell, continuing to /bin/sh: No such file or directory
Oct  5 08:53:13 localhost Singularity: action-suid (U=1000,P=32311)> What are you doing gmk, this is highly irregular!
Oct  5 08:53:13 localhost Singularity: action-suid (U=1000,P=32311)> Retval = 255
```

**note: All errors are logged!**

### A peek into the SetUID program flow
We can also add the `--debug` argument to any command itself at runtime to see everything that Singularity is doing. In this case we can run Singularity in debug mode and request use of the PID namespace so we can see what Singularity is doing there:
 
```
$ singularity --debug shell --pid ubuntu
Enabling debugging
Ending argument loop
Singularity version: 2.3.9-development.gc35b753
Exec'ing: /usr/local/libexec/singularity/cli/shell.exec
Evaluating args: '--pid ubuntu'
```
(snipped to PID namespace implementation)

```
DEBUG   [U=1000,P=30961]   singularity_runtime_ns_pid()              Using PID namespace: CLONE_NEWPID
DEBUG   [U=1000,P=30961]   singularity_runtime_ns_pid()              Virtualizing PID namespace
DEBUG   [U=1000,P=30961]   singularity_registry_get()                Returning NULL on 'DAEMON_START'
DEBUG   [U=1000,P=30961]   prepare_fork()                            Creating parent/child coordination pipes.
VERBOSE [U=1000,P=30961]   singularity_fork()                        Forking child process
DEBUG   [U=1000,P=30961]   singularity_priv_escalate()               Temporarily escalating privileges (U=1000)
DEBUG   [U=0,P=30961]      singularity_priv_escalate()               Clearing supplementary GIDs.
DEBUG   [U=0,P=30961]      singularity_priv_drop()                   Dropping privileges to UID=1000, GID=1000 (8 supplementary GIDs)
DEBUG   [U=0,P=30961]      singularity_priv_drop()                   Restoring supplementary groups
DEBUG   [U=1000,P=30961]   singularity_priv_drop()                   Confirming we have correct UID/GID
VERBOSE [U=1000,P=30961]   singularity_fork()                        Hello from parent process
DEBUG   [U=1000,P=30961]   install_generic_signal_handle()           Assigning generic sigaction()s
DEBUG   [U=1000,P=30961]   install_generic_signal_handle()           Creating generic signal pipes
DEBUG   [U=1000,P=30961]   install_sigchld_signal_handle()           Assigning SIGCHLD sigaction()
DEBUG   [U=1000,P=30961]   install_sigchld_signal_handle()           Creating sigchld signal pipes
DEBUG   [U=1000,P=30961]   singularity_fork()                        Dropping permissions
DEBUG   [U=0,P=30961]      singularity_priv_drop()                   Dropping privileges to UID=1000, GID=1000 (8 supplementary GIDs)
DEBUG   [U=0,P=30961]      singularity_priv_drop()                   Restoring supplementary groups
DEBUG   [U=1000,P=30961]   singularity_priv_drop()                   Confirming we have correct UID/GID
DEBUG   [U=1000,P=30961]   singularity_signal_go_ahead()             Sending go-ahead signal: 0
DEBUG   [U=1000,P=30961]   wait_child()                              Parent process is waiting on child process
DEBUG   [U=0,P=1]          singularity_priv_drop()                   Dropping privileges to UID=1000, GID=1000 (8 supplementary GIDs)
DEBUG   [U=0,P=1]          singularity_priv_drop()                   Restoring supplementary groups
DEBUG   [U=1000,P=1]       singularity_priv_drop()                   Confirming we have correct UID/GID
VERBOSE [U=1000,P=1]       singularity_fork()                        Hello from child process
DEBUG   [U=1000,P=1]       singularity_wait_for_go_ahead()           Waiting for go-ahead signal
DEBUG   [U=1000,P=1]       singularity_wait_for_go_ahead()           Received go-ahead signal: 0
VERBOSE [U=1000,P=1]       singularity_registry_set()                Adding value to registry: 'PIDNS_ENABLED' = '1'
```
(snipped to end)

```
DEBUG   [U=1000,P=1]       envar_set()                               Unsetting environment variable: SINGULARITY_APPNAME
DEBUG   [U=1000,P=1]       singularity_registry_get()                Returning value from registry: 'COMMAND' = 'shell'
LOG     [U=1000,P=1]       main()                                    USER=gmk, IMAGE='ubuntu', COMMAND='shell'
INFO    [U=1000,P=1]       action_shell()                            Singularity: Invoking an interactive shell within container...

DEBUG   [U=1000,P=1]       action_shell()                            Exec'ing /.singularity.d/actions/shell
Singularity ubuntu:~> 
```
 
Not only do I see all of the configuration options that I (probably forgot about) previously set, I can trace the entire flow of Singularity from the first execution of an action (shell) to the final shell into the container. Each line also describes what is the effective UID running the command, what is the PID, and what is the function emitting the debug message.

### A peek into the "rootless" program flow
The above snippet was using the default SetUID program flow with a container image file named "ubuntu". For comparison, if we also use the `--userns` flag, and snip in the same places, you can see how the effective UID is never escalated, but we have the same outcome using a sandbox directory (*chroot*) style container.


```
$ singularity -d shell --pid --userns ubuntu.dir/
Enabling debugging
Ending argument loop
Singularity version: 2.3.9-development.gc35b753
Exec'ing: /usr/local/libexec/singularity/cli/shell.exec
Evaluating args: '--pid --userns ubuntu.dir/'
```
(snipped to PID namespace implementation, same place as above)

```
DEBUG   [U=1000,P=32081]   singularity_runtime_ns_pid()              Using PID namespace: CLONE_NEWPID
DEBUG   [U=1000,P=32081]   singularity_runtime_ns_pid()              Virtualizing PID namespace
DEBUG   [U=1000,P=32081]   singularity_registry_get()                Returning NULL on 'DAEMON_START'
DEBUG   [U=1000,P=32081]   prepare_fork()                            Creating parent/child coordination pipes.
VERBOSE [U=1000,P=32081]   singularity_fork()                        Forking child process
DEBUG   [U=1000,P=32081]   singularity_priv_escalate()               Not escalating privileges, user namespace enabled
DEBUG   [U=1000,P=32081]   singularity_priv_drop()                   Not dropping privileges, user namespace enabled
VERBOSE [U=1000,P=32081]   singularity_fork()                        Hello from parent process
DEBUG   [U=1000,P=32081]   install_generic_signal_handle()           Assigning generic sigaction()s
DEBUG   [U=1000,P=32081]   install_generic_signal_handle()           Creating generic signal pipes
DEBUG   [U=1000,P=32081]   install_sigchld_signal_handle()           Assigning SIGCHLD sigaction()
DEBUG   [U=1000,P=32081]   install_sigchld_signal_handle()           Creating sigchld signal pipes
DEBUG   [U=1000,P=32081]   singularity_signal_go_ahead()             Sending go-ahead signal: 0
DEBUG   [U=1000,P=32081]   wait_child()                              Parent process is waiting on child process
DEBUG   [U=1000,P=1]       singularity_priv_drop()                   Not dropping privileges, user namespace enabled
VERBOSE [U=1000,P=1]       singularity_fork()                        Hello from child process
DEBUG   [U=1000,P=1]       singularity_wait_for_go_ahead()           Waiting for go-ahead signal
DEBUG   [U=1000,P=1]       singularity_wait_for_go_ahead()           Received go-ahead signal: 0
VERBOSE [U=1000,P=1]       singularity_registry_set()                Adding value to registry: 'PIDNS_ENABLED' = '1'
```
(snipped to end)

```
DEBUG   [U=1000,P=1]       envar_set()                               Unsetting environment variable: SINGULARITY_APPNAME
DEBUG   [U=1000,P=1]       singularity_registry_get()                Returning value from registry: 'COMMAND' = 'shell'
LOG     [U=1000,P=1]       main()                                    USER=gmk, IMAGE='ubuntu.dir', COMMAND='shell'
INFO    [U=1000,P=1]       action_shell()                            Singularity: Invoking an interactive shell within container...

DEBUG   [U=1000,P=1]       action_shell()                            Exec'ing /.singularity.d/actions/shell
Singularity ubuntu.dir:~> 
```

Here you can see that the output and functionality is very similar, but we never increased any privilege and none of the `*-suid` program flow was utilized. We had to use a *chroot* style directory container (as images are not supported with the user namespace, but you can clearly see that the effective UID never had to change to run this container.

*note: Singularity can natively create and manage chroot style containers just like images! The above image was created using the command: `singularity build ubuntu.dir docker://ubuntu:latest`*

## Summary
Singularity supports multiple modes of operation to meet your security needs. For most HPC centers, and general usage scenarios, the default run mode is most effective and featurefull. For the security critical implementations, the user namespace workflow maybe a better option. It becomes a balance security and functionality (the most secure systems do nothing).
