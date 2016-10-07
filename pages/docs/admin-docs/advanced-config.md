---
title: The Singularity Configuration File
sidebar: admin_docs
permalink: docs-config
folder: docs
---

## Overview
The Singularity configuration file is installed into the defined configure argument --sysconfdir, --prefix, or automatically configured if you are installing via a package (such as RPM or DEB) in which case it is usually installed to /etc/singularity/singularity.conf.

For security reasons, the configuration file MUST be owned by root! This is because Singularity leverages some privileged features along its programmatic work-flow, with most of these features being toggle-able via the config file. Forcing the ownership of the configuration file to be root ensures that the system administrators get the final say as to what Singularity features are to be allowed.

### Options and formats
The Following configuration file keywords and values are supported. There are two configuration key/value types supported:

- Boolean: Configuration entries that are boolean are set or unset by either "yes" or "no" with the default being entry specific.
- String: Configuration entries that are string will be free form to the end of the line. No multi-line values are supported nor are quotations or escapes.


### allow pid ns 
<small>(boolean, default=yes)</small>
Should Singularity support separation of the NEWPID/PID namespaces? This is important because some resource managers that are not utilizing CGroups may not be able to limit resource consumption (using ulimits) when processes are running under a different namespace.

### mount proc 
<small>(boolean, default=yes)</small>
Should /proc be mounted within the container environments?

### mount sys 
<small>(boolean, default=yes)</small>
Should /sys be mounted within the container environments?

### bind path 
<small>(string)</small>
Define a list of files or directories that should be made available within a container environment. The file or directory given *must* exist on both the host and the container to properly bind. The format of this argument can be either a single path which makes the assumption that both the source and destination paths are the same, or two paths comma delimited with the source path being first, and the destination path being second. You can supply any number of 'bind path' entries in your configuration file.

### config passwd 
<small>(boolean, default=yes)</small>
If the /etc/passwd file exists within the container, this function will make a volatile copy of the file and append the appropriate information for the calling user (if not root) and then bind it back into the container.

### config group 
<small>(boolean, default=yes)</small>
If the /etc/group file exists within the container, this function will make a volatile copy of the file and append the appropriate information for the calling user (if not root) and then bind it back into the container. (options: yes/no, default=yes)
