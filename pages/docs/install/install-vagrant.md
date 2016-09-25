---
title: Running Singularity with Vagrant
sidebar: docs_sidebar
permalink: install-vagrant
folder: docs
---

In addition to the vagrant recipe to <a href="/install-mac">install on Mac</a>, we've provided several <a href="https://github.com/singularityware/singularity-vagrant" target="_blank">Vagrantfiles</a> that will accomplish the same thing.

- A Vagrantfile to generate a VM with <a href="https://github.com/singularityware/singularity-vagrant/tree/master/singularity" target="_blank">just Singularity</a>
- A Vagrantfile to generate a VM with <a href="https://github.com/singularityware/singularity-vagrant/tree/master/singularity-docker" href="_blank">Singularity and Docker</a>

For both of the above, you should clone the repo, cd into the folder with the Vagrantfile of choice, and then type:

```bash
vagrant up
```

You can then connect to the box with:

```bash
vagrant ssh
```

A Dockerized version of the above is <a href="{{ site.repo }}/docker2singularity" target="_blank">also available</a>.

