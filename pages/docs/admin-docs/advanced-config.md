---
title: The Singularity Configuration File
sidebar: admin_docs
permalink: docs-config
folder: docs
---

When Singularity is running via the SUID pathway, the configuration **must** be owned by the root user otherwise Singularity will error out. This ensures that the system administrators have direct say as to what functions the users can utilize when running as root. If Singularity is installed as a non-root user, the SUID components are not installed, and the configuration file can be owned by the user (but again, this will limit functionality).

The Configuration file can be found at `$SYSCONFDIR/singularity/singularity.conf` and is generally self documenting but there are several things to pay special attention to:

## Parameters

### ALLOW SETUID (boolean, default='yes')
This parameter toggles the global ability to execute the SETUID (SUID) portion of the code if it exists. As mentioned earlier, if the SUID features are disabled, various Singularity features will not function (e.g. mounting of the Singularity image file format).

You can however disable SUID support ***iff*** (if and only if) you do not need to use the default Singularity image file format and if your kernel supports user namespaces and you choose to use user namespaces.

*note: as of the time of this writing, the user namespace is rather buggy*


### ALLOW PID NS (boolean, default='yes')
While the PID namespace is a *neat* feature, it does not have much practical usage in an HPC context so it is recommended to disable this if you are running on an HPC system where a resource manager is involved as it has been known to cause confusion on some kernels with enforcement of user limits.

Even if the PID namespace is enabled by the system administrator here, it is not implemented by default when running containers. The user will have to specify they wish to implement un-sharing of the PID namespace as it must fork a child process.


### ENABLE OVERLAY (boolean, default='no')
The overlay file system creates a writable substrate to create bind points if necessary. This feature is very useful when implementing bind points within containers where the bind point may not already exist so it helps with portability of containers. Enabling this option has been known to cause some kernels to panic as this feature maybe present within a kernel, but has not proved to be stable as of the time of this writing (e.g. the Red Hat 7.2 kernel).

### CONFIG PASSWD,GROUP,RESOLV_CONF (boolean, default='yes')
All of these options essentially do the same thing for different files within the container. This feature updates the described file (`/etc/passwd`, `/etc/group`, and `/etc/resolv.conf` respectively) to be updated dynamically as the container is executed. It uses binds and modifies temporary files such that the original files are not manipulated.

### MOUNT PROC,SYS,DEV,HOME,TMP (boolean, default='yes')
These configuration options control the mounting of these file systems within the container and of course can be overridden by the system administrator (e.g. the system admin decides not to include the /dev tree inside the container). In most useful cases, these are all best to leave enabled.

### MOUNT HOSTFS (boolean, default='no')
This feature will parse the host's mounted file systems and attempt to replicate all mount points within the container. This maybe a desirable feature for the lazy, but it is generally better to statically define what bind points you wish to encapsulate within the container by hand (using the below "bind path" feature).

### BIND PATH (string)
With this configuration directive, you can specify any number of bind points that you want to extend from the host system into the container. Bind points on the host file system must be either real files or directories (no special files supported at this time). If the overlayFS is not supported on your host, or if `enable overlay = no` in this configuration file, a bind point must exist for the file or directory within the container.

The syntax for this consists of a bind path source and an optional bind path destination separated by a colon. If not bind path destination is specified the bind path source is used also as the destination.


### USER BIND CONTROL (boolean, default='yes')
In addition to the system bind points as specified within this configuration file, you may also allow users to define their own bind points inside the container. This feature is used via multiple command line arguments (e.g. `--bind`, `--scratch`, and `--home`) so disabling user bind control will also disable those command line options.

Singularity will automatically disable this feature if the host does not support the prctl option `PR_SET_NO_NEW_PRIVS`. In addition, `enable overlay` must be set to `yes` and the host system must support overlayFS (generally kernel versions 3.18 and later) for users to bind host directories to bind points that do not already exist in the container. 

### AUTOFS BUG PATH (string)
With some versions of autofs, Singularity will fail to run with a "Too many levels of symbolic links" error. This error happens by way of a user requested bind (done with -B/--bind) or one specified via the configuration file. To handle this, you will want to specify those paths using this directive. For example:
```bash
autofs bug path = /share/PI
```

## Logging
In order to facilitate monitoring and auditing, Singularity will syslog() every action and error that takes place to the `LOCAL0` syslog facility. You can define what to do with those logs in your syslog configuration.

## Loop Devices
Singularity images have `ext3` file systems embedded within them, and thus to mount them, we need to convert the raw file system image (with variable offset) to a block device. To do this, Singularity utilizes the `/dev/loop*` block devices on the host system and manages the devices programmatically within Singularity itself. Singularity also uses the `LO_FLAGS_AUTOCLEAR` loop device `ioctl()` flag which tells the kernel to automatically free the loop device when there are no more open file descriptors to the device itself.

Earlier versions of Singularity managed the loop devices via a background watchdog process, but since version 2.2 we leverage the `LO_FLAGS_AUTOCLEAR` functionality and we forego the watchdog process. Unfortunately, this means that some older Linux distributions are no longer supported (e.g. RHEL <= 5).

Given that loop devices are consumable (there are a limited number of them on a system), Singularity attempts to be smart in how loop devices are allocated. For example, if a given user executes a specific container it will bind that image to the next available loop device automatically. If that same user executes another command on the same container, it will use the loop device that has already been allocated instead of binding to another loop device. Most Linux distributions only support 8 loop devices by default, so if you find that you have a lot of different users running Singularity containers, you may need to increase the number of loop devices that your system supports by doing the following:

Edit or create the file `/etc/modprobe.d/loop.conf` and add the following line:

```
options loop max_loop=128

```

After making this change, you should be able to reboot your system or unload/reload the loop device as root using the following commands:

```bash
# modprobe -r loop
# modprobe loop
```
