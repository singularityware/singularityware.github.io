---
title: Security
sidebar: admin_docs
permalink: docs-security
folder: docs
---
 
{% include toc.html %}
 
## Executable Permissions
Once Singularity is ready to go in your specified `$PREFIX` base (eg, such as `/usr/local`) you may find that there are several `SETUID` root components installed (at `$PREFIX/libexec/singularity/bin/`). Let’s take a look:
 
```bash
$ find /usr/local/libexec/singularity/ -perm -4000
/usr/local/libexec/singularity/bin/create-suid
/usr/local/libexec/singularity/bin/copy-suid
/usr/local/libexec/singularity/bin/action-suid
/usr/local/libexec/singularity/bin/mount-suid
/usr/local/libexec/singularity/bin/import-suid
/usr/local/libexec/singularity/bin/export-suid
/usr/local/libexec/singularity/bin/expand-suid
```
 
Each of the binaries is named accordingly to the action that it is suited for, and generally, each handles the required privilege escalation necessary for Singularity to operate. What specifically requires escalated privileges?
 
1. Mounting (and looping) the Singularity container image
2. Creation of the necessary namespaces in the kernel
3. Binding host paths into the container
 
Removing any of these SUID binaries or changing the permissions on them would cause Singularity to utilize the non-SUID workflows. What workflows are we talking about? We tricked you a bit with the command above by limiting to a particular permission - each file with `*-suid` also has a non-suid equivalent:
 
```bash
/usr/local/libexec/singularity/bin/create
/usr/local/libexec/singularity/bin/action
/usr/local/libexec/singularity/bin/copy
/usr/local/libexec/singularity/bin/mount
/usr/local/libexec/singularity/bin/import
/usr/local/libexec/singularity/bin/expand
/usr/local/libexec/singularity/bin/export
/usr/local/libexec/singularity/bin/bootstrap
```
 
While most of these workflows will not properly function without the SUID components, we have provided these fall back executables for sites that wish to limit the SETUID capabilities to the bare essentials/minimum. Under this case, only the `action-suid` would be required (this would still allow `shell`, `exec`, `test`, and `run`). You can find the setting for `allow suid` at the top of the `singularity.conf` file, which is typically located in `$PREFIX/etc/singularity/singularity.conf` or the `etc` directory of the base repo before you install it.

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

 
## Can I install Singularity as a user?
If you have ever tried to install Singularity as a user, the install may appear to work, but it is these specific functions that require a root user that may lead to errors in this “local installation.” If we go back to the basic idea that a container requires some management of <a href="https://en.wikipedia.org/wiki/Linux_namespaces" target="_blank">linux namespaces</a>, it will make sense why a root user is required. It is generally impossible to implement any kind of container system without this level of permissions.


## A Container Permissions Strategy
As a cluster admin, you want to set up a configuration that is customized for your cluster or shared resource. In the following paragraphs, we will elaborate on this container permissions strategy, giving detail about which users are allowed to run containers, along with image curation and ownership.

 
### Can I limit usage to specific users?
In the configuration file (when installed it is located at `$PREFIX/etc/singularity/singularity.conf`) you have complete control over limiting the usage of Singularity to a specific set of users:

 
```bash
# LIMIT CONTAINER OWNERS: [STRING]
# DEFAULT: NULL
# Only allow containers to be used that are owned by a given user. If this
# configuration is undefined (commented or set to NULL), all containers are
# allowed to be used. This feature only applies when Singularity is running in
# SUID mode and the user is non-root.
#limit container owners = gmk, singularity, nobody
 
# LIMIT CONTAINER PATHS: [STRING]
# DEFAULT: NULL
# Only allow containers to be used that are located within an allowed path
# prefix. If this configuration is undefined (commented or set to NULL),
# containers will be allowed to run from anywhere on the file system. This
# feature only applies when Singularity is running in SUID mode and the user is
# non-root.
#limit container paths = /scratch, /tmp, /global
```
 
For example, if I were to uncomment out the last line of the first section, I could specify a set of usernames that are allowed to use, manage, create, and do anything and everything with containers. Any command issued to Singularity that does not come from one of these users would not be allowed to run.
 

### Can users have ownership of containers?
Remember that container ownership is akin to file ownership. If you set strict permissions on a container, the same rules will apply as would a file. This is only one of the many ways that Singularity allows you to control permissions.

 
## Debugging and Logging
Singularity offers a very comprehensive auditing mechanism via its debugging output that is printed to the stderr (in your terminal), and also the system log. For each command that is issued, it prints the UID, PID, and location of the command. For example, let’s see what happens if we shell into an image:
 
```
$ singularity shell nginx.img
```
 
We can then peek into the system log to see what was recorded:
 
```bash
cat /var/log/syslog
Jun 10 00:02:24 vanessa-ThinkPad-T460s kernel: [205148.055781] EXT4-fs (loop1): mounting ext3 file system using the ext4 subsystem
Jun 10 00:02:24 vanessa-ThinkPad-T460s kernel: [205148.056282] EXT4-fs (loop1): mounted filesystem with ordered data mode. Opts: errors=remount-ro
Jun 10 00:02:24 vanessa-ThinkPad-T460s Singularity: action-suid (U=1000,P=9673)> USER=vanessa, IMAGE='nginx.img', COMMAND='shell'
```
 
We can also add the `--debug` argument to the command itself to see verbose output to the terminal, without peeking into syslog (note this is extremely cut down for this example):
 
```
singularity --debug shell nginx.img
Enabling debugging
Ending argument loop
Singularity version: 2.3-master.g499419b
Exec'ing: /usr/local/libexec/singularity/cli/shell.exec
Evaluating args: 'nginx.img'
VERBOSE [U=0,P=9718]       message_init()                            Set messagelevel to: 5
VERBOSE [U=0,P=9718]       singularity_config_parse()                Initialize configuration file: /usr/local/etc/singularity/singularity.conf
DEBUG   [U=0,P=9718]       singularity_config_parse()                Starting parse of configuration file /usr/local/etc/singularity/singularity.conf
VERBOSE [U=0,P=9718]       singularity_config_parse()                Got config key allow setuid = 'yes'
VERBOSE [U=0,P=9718]       singularity_config_parse()                Got config key max loop devices = '256'
VERBOSE [U=0,P=9718]       singularity_config_parse()                Got config key allow pid ns = 'yes'
VERBOSE [U=0,P=9718]       singularity_config_parse()                Got config key config passwd = 'yes'
VERBOSE [U=0,P=9718]       singularity_config_parse()                Got config key config group = 'yes'
VERBOSE [U=0,P=9718]       singularity_config_parse()                Got config key config resolv_conf = 'yes'
VERBOSE [U=0,P=9718]       singularity_config_parse()                Got config key mount proc = 'yes'
...

DEBUG   [U=1000,P=9718]    main()                                    Attempting to chdir to CWD: /home/vanessa/Desktop
DEBUG   [U=1000,P=9718]    envar_set()                               Setting environment variable: 'SINGULARITY_CONTAINER' = 'nginx.img'
DEBUG   [U=1000,P=9718]    envar_set()                               Setting environment variable: 'SINGULARITY_NAME' = 'nginx.img'
DEBUG   [U=1000,P=9718]    singularity_registry_get()                Returning NULL on 'SHELL'
DEBUG   [U=1000,P=9718]    envar_set()                               Unsetting environment variable: SINGULARITY_SHELL
DEBUG   [U=1000,P=9718]    singularity_registry_get()                Returning value from registry: 'COMMAND' = 'shell'
DEBUG   [U=1000,P=9718]    singularity_registry_get()                Returning value from registry: 'COMMAND' = 'shell'
LOG     [U=1000,P=9718]    main()                                    USER=vanessa, IMAGE='nginx.img', COMMAND='shell'
INFO    [U=1000,P=9718]    action_shell()                            Singularity: Invoking an interactive shell within container...
 
DEBUG   [U=1000,P=9718]    action_shell()                            Exec'ing /.singularity.d/actions/shell
```
 
Not only do I see all of the configuration options that I (probably forgot about) previously set, I can trace the entire flow of Singularity from the first execution of an action (shell) to the final shell into the container. Also note that the first line shows the exact version of Singularity that I'm using, which has this format:

```
Singularity version: 2.3-master.g499419b
Singularity version: [version]-[branch].[commit]
# (The commit id only includes the first 8 characters)
```
and if you install from a release, you will likely see:

```
Singularity version: 2.3-dist
```

But not to get sidetracked, we want to look at permissions! Actually, the part that you care about is where the UID of 0 changes to 1000:

```
DEBUG   [U=0,P=9718]       singularity_priv_drop_perm()              Dropping to group ID '1000'
DEBUG   [U=0,P=9718]       singularity_priv_drop_perm()              Dropping real and effective privileges to GID = '1000'
DEBUG   [U=0,P=9718]       singularity_priv_drop_perm()              Dropping real and effective privileges to UID = '1000'
DEBUG   [U=1000,P=9718]    singularity_priv_drop_perm()              Confirming we have correct GID
DEBUG   [U=1000,P=9718]    singularity_priv_drop_perm()              Confirming we have correct UID
DEBUG   [U=1000,P=9718]    singularity_priv_drop_perm()              Setting NO_NEW_PRIVS to prevent future privilege escalations.
```

In the above output you can see that we escalate permissions to properly mount, and once this has been done, we immediately drop permissions back to the calling user. We recommend that you try a `--debug` command locally on your workstation to see the entire pathway that Singularity follows for securely shell-ing into an image.


## Why the user namespace isn't the answer to life, everything, and container permissions
Many people (possibly ignorantly) claim that the "user namespace" will solve all of the implementation problems with unprivileged containers. While it does solve some, it is currently feature limited. With time this may change, but even on kernels that have a reasonable feature list implemented, it is known to be very buggy and cause kernel panics. Additionally very few distribution vendors are shipping supported kernels that include this feature. For example, Red Hat considers this a "technology preview" and is only available via a system modification, while other kernels enable it and have been trying to keep up with the bugs it has caused. But, even in it's most stable form, the user namespace does not completely alleviate the necessity of privilege escalation unless you also give up the desire to support images (#1 above).

 
### How do other container solutions do it?
Docker and other container solutions use a root owned daemon to control the bring up, teardown, and functions of the containers. Users have the ability to control the daemon via a socket (either a UNIX domain socket or network socket). Allowing users to control a root owned daemon process which has the ability to assign network addresses, bind file systems, spawn other scripts and tools, is a large problem to solve and one of the reasons why Docker is not typically used on multi-tenant HPC resources.

 
### Security mitigations
SUID programs are common targets for attackers because they provide a direct mechanism to gain privileged command execution. These are some of the baseline security mitigations for Singularity:
 
1. Keep the escalated bits within the code as simple and transparent so it can be easily audit-able
2. Check the return value of every system call, command, and check and bomb out early if anything looks weird
3. Make sure that proper permissions of files and directories are owned by root (e.g. the config must be owned by root to work)
4. Don't trust any non-root inputs (like config values) unless they have been checked and/or sanitized
5. As much IO as possible is done via the calling user (not root)
6. Put as much system administrator control into the configuration file as possible
7. Drop permissions before running any non trusted code pathways
8. Limit all user actions within the container to that single user (disable escalation of privileges within a container)
9. Even though the user owns the image, it utilizes a POSIX like file system inside so files inside the container owned by root can only be modified by root

If you have questions about security, or want to know more about a particular issue, please <a href="https://www.github.com/singularityware/singularityware.github.io/issues" target="_blank">open an issue</a>, and we will help to answer your question right away.
