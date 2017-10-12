---
title: instance.list
sidebar: user_docs
permalink: /docs-instance-list
folder: docs
toc: false
---

New in Singularity version 2.4 you can use the `instance` command group to run instances of containers in the background.  This is useful for running services like databases and web servers. The `instance.list` command lets you keep track of the named instances running in the background.  

{% include toc.html %}

## Overview
After initiating one or more named instances to run in the background with the `instance.start` command you can list them with the `instance.list` command.  

## Examples
These examples use a container from Singularity Hub, but you can use local containers or containers from Docker Hub as well.  For a more detailed look at `instance` usage see [Running Instances](docs-instances).

### Start a few named instances from containers on Singularity Hub
```
$ singularity instance.start shub://GodloveD/lolcow cow1
$ singularity instance.start shub://GodloveD/lolcow cow2
$ singularity instance.start shub://vsoch/hello-world hiya
```
### List running instances 
```
$ singularity instance.list
DAEMON NAME      PID      CONTAINER IMAGE
cow1             20522    /home/ubuntu/GodloveD-lolcow-master.img
cow2             20558    /home/ubuntu/GodloveD-lolcow-master.img
hiya             20595    /home/ubuntu/vsoch-hello-world-master.img
```


