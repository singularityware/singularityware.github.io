---
title: Running Singularity with Docker (Windows)
sidebar: main_sidebar
permalink: install-windows
folder: docs
---

It is possible to run Singularity on your Windows machine via Docker. Use the command `docker pull kaczmarj/singularity` to pull the latest, pre-built Docker image containing Singularity. You can also build a Docker image from scratch using the [Dockerfile](/Dockerfile) in this repository. The Singularity Docker image must be run in [prileged mode](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).
