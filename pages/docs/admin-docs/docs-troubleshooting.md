---
title: Troubleshooting
sidebar: admin_docs
permalink: docs-troubleshooting
folder: docs
toc: false
---

This section will help you debug (from the system administrator's perspective) Singularity.

### Not installed correctly, or installed to a non-compatible location
Singularity must be installed by root into a location that allows for `SUID` programs to be executed (as described above in the installation section of this manual). If you fail to do that, you may have user's reporting one of the following error conditions:

```
ERROR  : Singularity must be executed in privileged mode to use images
ABORT  : Retval = 255
```
```
ERROR  : User namespace not supported, and program not running privileged.
ABORT  : Retval = 255
```
```
ABORT  : This program must be SUID root
ABORT  : Retval = 255
```
If one of these errors is reported, it is best to check the installation of Singularity and ensure that it was properly installed by the root user onto a local file system.
