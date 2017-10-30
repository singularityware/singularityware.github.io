---
title: Host a Singularity Registry
sidebar: main_sidebar
permalink: singularity-registry
toc: false
---

In response to our users, @vsoch has developed a local registry for institutions
or users, <a href="https://github.com/singularityhub/sregistry" target="_blank">Singularity Registry</a>,
to deploy on their resources to manage and serve singularity images.  With Singularity Registry you can:

 * build to your on you local resource, or a continuous integration server
 * push images to the registry
 * manage images in collections, by tags, or metadata
 * visualize collections of images to assess size

<a href="/assets/img/diagram/container_treemap.png" target="_blank" class="no-after">
   <img style="max-width:900px" src="/assets/img/diagram/container_treemap.png">
</a>

Public images in your registry are immediately available via the Singularity command line software via the `shub://` unique resource identifier:

```
singularity pull shub://127.0.0.1/vsoch/hello-world
```

Where `127.0.0.1` would be in reference to your registry on localhost. If you don't want to build or host your own images, then you would be interested to use <a href="https://www.singularity-hub.org" target="_blank">Singularity Hub</a>,

<a target="_blank" class="btn btn-primary navbar-btn cursorNorm" style="color:white;height: 42px;padding-top: 10px;" role="button" href="https://singularityhub.github.io/sregistry">Documentation</a> 
<a target="_blank" href="https://www.github.com/singularityhub/sregistry" class="btn btn-primary navbar-btn cursorNorm no-after" role="button"><i style="color:white" class="fa fa-github fa-2x"></i></a>


