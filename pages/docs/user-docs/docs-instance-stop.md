---
title: instance.stop
sidebar: user_docs
permalink: /docs-instance-stop
folder: docs
toc: false
---

New in Singularity version 2.4 you can use the `instance` command group to run instances of containers in the background.  This is useful for running services like databases and web servers. The `instance.stop` command lets you stop instances once you are finished using them

{% include toc.html %}

## Overview
After initiating one or more named instances to run in the background with the `instance.start` command you can stop them with the `instance.stop` command.  

## Examples
These examples use a container from Singularity Hub, but you can use local containers or containers from Docker Hub as well.  For a more detailed look at `instance` usage see [Running Instances](docs-instances).

### Start a few named instances from containers on Singularity Hub
```
$ singularity instance.start shub://GodloveD/lolcow cow1
$ singularity instance.start shub://GodloveD/lolcow cow2
$ singularity instance.start shub://vsoch/hello-world hiya
```
### Stop a single instance
```
$ singularity instance.stop cow1
Stopping cow1 instance of /home/ubuntu/GodloveD-lolcow-master.img (PID=20522)
```

### Stop all running instances
```
$ singularity instance.stop \*
Stopping cow2 instance of /home/ubuntu/GodloveD-lolcow-master.img (PID=20558)
Stopping hiya instance of /home/ubuntu/vsoch-hello-world-master.img (PID=20595)
```


