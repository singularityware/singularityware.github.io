---
title: Request Singularity
sidebar: main_sidebar
permalink: install-request
folder: docs
toc: true
---

### How do I ask for Singularity on my local resource?

Installation of a new software is no small feat for a shared cluster resource. Whether you are an administrator reading this, or a user that wants a few talking points and background to share with your administrator, this document is for you. Here we provide you with some background and resources to learn about Singularity. We hope that this information will be useful to you in making the decision to build reproducible containers with Singularity

### Information Resources

{% include toc.html %}

#### Background

 - [Frequently Asked Questions](https://singularityware.github.io) is a good first place to start for quick question and answer format.
 - [Singularity Publication](journals.plos.org/plosone/article?id=10.1371/journal.pone.0177459): Reviews the history and rationale for development of the Software, along with comparison to other container software available at the time.
 - [Documentation Background](https://singularityware.github.io/about) is useful to read about use cases, and goals of the Software.

#### Security

 - [Administrator Control](https://github.com/singularityware/singularity/blob/master/etc/singularity.conf.in): The configuratoin file template is the best source to learn about the configuration options that are under the administrator's control.
 - [Security Overview](http://singularity.lbl.gov/docs-security) discusses common security concerns

#### Presentations

 - [Contributed Content](https://singularityware.github.io/links) is a good source of presentations, tutorials, and links.

### Installation Request

Putting all of the above together, a request might look like the following:

```
Dear Research Computing,

We are interested in having an installation of the Singularity software (https://singularityware.github.io) installed on our cluster. Singularity containers will allow us to build encapsulated environments, meaning that our work is reproducible and we are empowered to choose all dependencies including libraries, operating system, and custom software. Singularity is already installed on over 50 centers internationally (http://singularity.lbl.gov/citation-registration) including TACC, NIH, and several National Labs, Universities, Hospitals. Importantly, it has a vibrant team of developers, scientists, and HPC administrators that invest heavily in the security and development of the software, and are quick to respond to the needs of the community. To help learn more about Singularity, I thought these items might be of interest:

   - Security: A discussion of security concerns is discussed at http://singularity.lbl.gov/docs-security
   - Installation: http://singularity.lbl.gov/admin-guide

If you have questions about any of the above, you can email the list (singularity@lbl.gov) or join the slack channel (singularity-container.slack.com) to get a human response. I can do my best to faciliate this interaction if help is needed. Thank you kindly for considering this request!

Best,

User
```

As is stated in the letter above, you can always <a href="/support">reach out</a> to us for additional questions or support.


{% include links.html %}
